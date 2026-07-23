/// Readable first-pass winch behavior.
/// The cable is a distance rule and a drawn line, not rope physics.

function winch_get_hitch_x(_vehicle)
{
    return _vehicle.x + lengthdir_x(_vehicle.winch_hitch_distance, _vehicle.image_angle - 90);
}

function winch_get_hitch_y(_vehicle)
{
    return _vehicle.y + lengthdir_y(_vehicle.winch_hitch_distance, _vehicle.image_angle - 90);
}

function winch_player_is_near_hitch(_vehicle, _actor)
{
    return point_distance(
        _actor.x,
        _actor.y,
        winch_get_hitch_x(_vehicle),
        winch_get_hitch_y(_vehicle)
    ) <= _vehicle.winch_hitch_interact_radius;
}

function winch_find_vehicle_with_cable(_actor)
{
    for (var i = 0; i < instance_number(obj_skidsteer); i++)
    {
        var vehicle = instance_find(obj_skidsteer, i);

        if (vehicle.winch_state == WinchState.CABLE_IN_HAND
        && vehicle.winch_handler == _actor)
        {
            return vehicle;
        }
    }

    return noone;
}

function winch_install_attachment(_vehicle)
{
    var game_state = game_state_ensure();

    if (!progression_install_winch_state(game_state))
        return false;

    _vehicle.winch_state = WinchState.STOWED;

    progress_show_reward_summary(
        "Vehicle Attachment",
        "Winch installed"
    );

    notification_show_hint(
        "Fit the Winch complete - return to the Task Board.",
        game_get_speed(gamespeed_fps) * 6,
        false
    );

    save_write();

    return true;
}

function winch_take_cable(_vehicle, _actor)
{
    if (_vehicle.winch_state != WinchState.STOWED)
    {
        return false;
    }

    _vehicle.winch_state = WinchState.CABLE_IN_HAND;
    _vehicle.winch_handler = _actor;

    var game_state = game_state_ensure();
    if (task_is_active(TaskId.TIMBER_DELIVERY, game_state)
    && (
        game_state.tutorial_stage == TutorialStage.TAKE_WINCH_CABLE
        || game_state.tutorial_stage == TutorialStage.INSPECT_FIRST_LOG
    ))
    {
        progression_set_tutorial_stage(
            game_state,
            TutorialStage.ATTACH_CABLE_TO_LOG
        );
    }

    notification_show_hint(
        "Carry the cable to a downed tree or stump and press E.",
        game_get_speed(gamespeed_fps) * 5,
        false
    );

    return true;
}

function winch_stow_cable(_vehicle)
{
    if (_vehicle.winch_state != WinchState.CABLE_IN_HAND)
    {
        return false;
    }

    _vehicle.winch_handler = noone;
    _vehicle.winch_state = WinchState.STOWED;

    var game_state = game_state_ensure();
    if (game_state.tutorial_stage == TutorialStage.ATTACH_CABLE_TO_LOG)
    {
        progression_set_tutorial_stage(
            game_state,
            TutorialStage.TAKE_WINCH_CABLE
        );
    }
    return true;
}

function winch_attach_target(_vehicle, _target, _actor)
{
    if (_vehicle.winch_state != WinchState.CABLE_IN_HAND
    || _vehicle.winch_handler != _actor)
    {
        return false;
    }

    if (!resource_get_definition(_target.resource_id).can_winch)
    {
        notification_show_hint(
            resource_get_world_name(_target.resource_id) + " cannot be attached to the winch.",
            game_get_speed(gamespeed_fps) * 2,
            false
        );
        return false;
    }

    var cable_distance = point_distance(
        winch_get_hitch_x(_vehicle),
        winch_get_hitch_y(_vehicle),
        _target.x,
        _target.y
    );

    if (cable_distance > _vehicle.winch_cable_length)
    {
        notification_show_hint(
            "The winch cable will not reach that target.",
            game_get_speed(gamespeed_fps) * 3,
            false
        );

        return false;
    }

    _vehicle.winch_handler = noone;
    _vehicle.winch_target = _target;
    _vehicle.winch_state = WinchState.ATTACHED;

    _target.tow_vehicle = _vehicle;
    _target.pullable_state = PullableState.ATTACHED;

    var game_state = game_state_ensure();
    if (task_is_active(TaskId.TIMBER_DELIVERY, game_state)
    && game_state.tutorial_stage == TutorialStage.ATTACH_CABLE_TO_LOG
    && _target.resource_id == ResourceId.TIMBER_LOG)
    {
        progression_set_tutorial_stage(
            game_state,
            TutorialStage.HAUL_FIRST_LOG
        );
        save_write();
    }

    notification_show_hint(
        "Winch attached. Return to the vehicle and drive slowly.",
        game_get_speed(gamespeed_fps) * 5,
        false
    );

    return true;
}

function winch_detach_target(_vehicle)
{
    if (instance_exists(_vehicle.winch_target))
    {
        var target = _vehicle.winch_target;
        target.tow_vehicle = noone;

        if (target.pullable_state != PullableState.DELIVERED)
        {
            target.pullable_state = PullableState.FREE;
        }
    }

    _vehicle.winch_target = noone;
    _vehicle.winch_handler = noone;

    var game_state = game_state_ensure();
    _vehicle.winch_state = (game_state.winch_attachment_state == AttachmentState.INSTALLED)
        ? WinchState.STOWED
        : WinchState.UNAVAILABLE;

}

function winch_get_drive_multiplier(_vehicle)
{
    if (_vehicle.winch_state == WinchState.ATTACHED
    && instance_exists(_vehicle.winch_target))
    {
        var target = _vehicle.winch_target;
        return variable_instance_exists(target, "tow_vehicle_speed_multiplier")
            ? target.tow_vehicle_speed_multiplier
            : _vehicle.winch_tow_speed_multiplier;
    }

    return 1;
}

function winch_update_tow(_vehicle)
{
    if (_vehicle.winch_state != WinchState.ATTACHED)
    {
        return;
    }

    if (!instance_exists(_vehicle.winch_target))
    {
        winch_detach_target(_vehicle);
        return;
    }

    var target = _vehicle.winch_target;
    var hitch_x = winch_get_hitch_x(_vehicle);
    var hitch_y = winch_get_hitch_y(_vehicle);
    var target_distance = point_distance(target.x, target.y, hitch_x, hitch_y);
    var cable_tension = target_distance - _vehicle.winch_tow_length;

    if (cable_tension <= 0)
    {
        return;
    }

    var pull_direction = point_direction(target.x, target.y, hitch_x, hitch_y);
    var pull_amount = min(cable_tension, target.tow_pull_speed);

    target.x += lengthdir_x(pull_amount, pull_direction);
    target.y += lengthdir_y(pull_amount, pull_direction);
}

function winch_limit_cable_holder(_actor)
{
    var vehicle = winch_find_vehicle_with_cable(_actor);

    if (!instance_exists(vehicle))
    {
        return;
    }

    var hitch_x = winch_get_hitch_x(vehicle);
    var hitch_y = winch_get_hitch_y(vehicle);
    var cable_distance = point_distance(hitch_x, hitch_y, _actor.x, _actor.y);

    if (cable_distance <= vehicle.winch_cable_length)
    {
        return;
    }

    var cable_direction = point_direction(hitch_x, hitch_y, _actor.x, _actor.y);
    _actor.x = hitch_x + lengthdir_x(vehicle.winch_cable_length, cable_direction);
    _actor.y = hitch_y + lengthdir_y(vehicle.winch_cable_length, cable_direction);
}

function winch_get_target_prompt(_target, _actor)
{
    var resource_name = resource_get_world_name(_target.resource_id);

    if (_target.pullable_state == PullableState.ATTACHED
    && instance_exists(_target.tow_vehicle))
    {
        return "Detach winch from " + resource_name;
    }

    var cable_vehicle = winch_find_vehicle_with_cable(_actor);

    if (instance_exists(cable_vehicle))
    {
        var cable_distance = point_distance(
            winch_get_hitch_x(cable_vehicle),
            winch_get_hitch_y(cable_vehicle),
            _target.x,
            _target.y
        );

        if (cable_distance <= cable_vehicle.winch_cable_length)
        {
            return "Attach winch to " + resource_name;
        }

        return "Winch cable will not reach";
    }

    return "Inspect " + resource_name;
}

function winch_interact_with_target(_target, _actor)
{
    var game_state = game_state_ensure();
    if (task_is_active(TaskId.TIMBER_DELIVERY, game_state)
    && game_state.tutorial_stage == TutorialStage.INSPECT_FIRST_LOG
    && _target.resource_id == ResourceId.TIMBER_LOG)
    {
        progression_set_tutorial_stage(
            game_state,
            TutorialStage.TAKE_WINCH_CABLE
        );
        notification_show_hint(
            "The log needs the winch. Take the cable from the skidsteer's rear hitch.",
            game_get_speed(gamespeed_fps) * 5,
            false
        );
        save_write();
        return;
    }

    if (_target.pullable_state == PullableState.ATTACHED
    && instance_exists(_target.tow_vehicle))
    {
        winch_detach_target(_target.tow_vehicle);

        if (game_state.tutorial_stage == TutorialStage.HAUL_FIRST_LOG)
        {
            progression_set_tutorial_stage(
                game_state,
                TutorialStage.TAKE_WINCH_CABLE
            );
            save_write();
        }

        notification_show_hint(
            "Winch detached.",
            game_get_speed(gamespeed_fps) * 2,
            false
        );

        return;
    }

    var cable_vehicle = winch_find_vehicle_with_cable(_actor);

    if (instance_exists(cable_vehicle))
    {
        winch_attach_target(cable_vehicle, _target, _actor);
        return;
    }

    var message = "This is too large to carry by hand.";

    switch (game_state.winch_attachment_state)
    {
        case AttachmentState.LOCKED:
            message = "This is too heavy to carry. A pulling attachment would help.";
            break;

        case AttachmentState.MAIL_READY:
            message = "This needs a winch. You should check in at Homebase.";
            break;

        case AttachmentState.STORED_AT_HOME:
            message = "The winch is at Homebase. Install it on the vehicle first.";
            break;

        case AttachmentState.INSTALLED:
            message = "Take the cable from the rear of the vehicle, then bring it here.";
            break;
    }

    notification_show_dialogue(
        message,
        _target,
        game_get_speed(gamespeed_fps) * 4,
        NotificationStyle.PROMPT
    );
}

function winch_draw_for_vehicle(_vehicle)
{
    var game_state = game_state_ensure();

    if (game_state.winch_attachment_state != AttachmentState.INSTALLED)
    {
        return;
    }

    var hitch_x = winch_get_hitch_x(_vehicle);
    var hitch_y = winch_get_hitch_y(_vehicle);
    var cable_target = noone;

    if (_vehicle.winch_state == WinchState.CABLE_IN_HAND
    && instance_exists(_vehicle.winch_handler))
    {
        cable_target = _vehicle.winch_handler;
    }
    else if (_vehicle.winch_state == WinchState.ATTACHED
    && instance_exists(_vehicle.winch_target))
    {
        cable_target = _vehicle.winch_target;
    }

    if (instance_exists(cable_target))
    {
        draw_set_color(make_color_rgb(42, 35, 28));
        draw_line_width(hitch_x, hitch_y, cable_target.x, cable_target.y, 2);
    }

    // Placeholder hitch until the attachment art is available.
    draw_set_color(make_color_rgb(215, 164, 56));
    draw_circle(hitch_x, hitch_y, 3, false);
    draw_set_color(c_white);
}
