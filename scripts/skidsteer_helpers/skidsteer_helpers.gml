/// Helper functions for obj_skidsteer.

function skidsteer_parking_pad_contains(_pad, _vehicle)
{
    if (!instance_exists(_pad) || !instance_exists(_vehicle))
    {
        return false;
    }

    var inset = 4;
    var left = _pad.x - _pad.pad_width * 0.5 + inset;
    var right = _pad.x + _pad.pad_width * 0.5 - inset;
    var top = _pad.y - _pad.pad_height * 0.5 + inset;
    var bottom = _pad.y + _pad.pad_height * 0.5 - inset;

    return _vehicle.bbox_left >= left
        && _vehicle.bbox_right <= right
        && _vehicle.bbox_top >= top
        && _vehicle.bbox_bottom <= bottom;
}

function skidsteer_is_nearly_stopped(_vehicle)
{
    return instance_exists(_vehicle)
        && abs(_vehicle.drive_speed) <= 0.05
        && abs(_vehicle.turn_speed) <= 0.05;
}

function skidsteer_has_no_tow_target(_vehicle)
{
    return instance_exists(_vehicle)
        && _vehicle.winch_state != WinchState.ATTACHED
        && !instance_exists(_vehicle.winch_target);
}

function skidsteer_reset_contact_visual()
{
    is_crushing = false;
    sprite_index = spr_skidsteer;
    image_index = 0;
    image_speed = 1;
}

function skidsteer_start_contact_visual(_state)
{
    skidsteer_state = _state;

    if (!is_crushing)
    {
        is_crushing = true;
        sprite_index = spr_contact;
        image_index = 0;
        image_speed = 1;
    }
}

function skidsteer_update_cooldowns()
{
    if (exit_cooldown > 0)
    {
        exit_cooldown -= 1;
    }

    if (carry_full_hint_cooldown > 0)
    {
        carry_full_hint_cooldown -= 1;
    }
}

function skidsteer_exit_vehicle()
{
    has_driver = false;
    skidsteer_state = SkidsteerState.EMPTY;
    drive_speed = 0;
    turn_speed = 0;

    if (is_crushing)
    {
        skidsteer_reset_contact_visual();
    }

    var exit_direction = image_angle - 90;

    driver_instance = instance_create_depth(
        x + lengthdir_x(18, exit_direction),
        y + lengthdir_y(18, exit_direction),
        depth - 1,
        obj_player
    );

    driver_instance.vehicle = id;
    exit_cooldown = 8;

    if (instance_exists(last_blocking_log))
    {
        notification_show_hint(
            last_blocking_log.inspect_hint,
            last_blocking_log.notice_time,
            true
        );
    }
}

function skidsteer_apply_axis_deadzone(_value, _deadzone)
{
    var axis = clamp(_value, -1, 1);
    var deadzone = clamp(_deadzone, 0, 0.95);
    var magnitude = abs(axis);

    if (magnitude <= deadzone)
    {
        return 0;
    }

    return sign(axis) * ((magnitude - deadzone) / (1 - deadzone));
}

function skidsteer_read_input()
{
    // Movement consumes normalized axes, not keyboard keys directly. The
    // input helpers can therefore add controller axes without changing any
    // vehicle movement code.
    return {
        throttle: skidsteer_apply_axis_deadzone(
            input_vehicle_throttle(),
            vehicle_input_deadzone
        ),
        steering: skidsteer_apply_axis_deadzone(
            input_vehicle_steering(),
            vehicle_input_deadzone
        ),
        exit_pressed: input_interact_pressed()
    };
}

function skidsteer_approach_value(_current, _target, _amount)
{
    var amount = max(0, _amount);

    if (_current < _target)
    {
        return min(_current + amount, _target);
    }

    if (_current > _target)
    {
        return max(_current - amount, _target);
    }

    return _target;
}

function skidsteer_update_tracks(_input)
{
    var left_track = clamp(_input.throttle + _input.steering, -1, 1);
    var right_track = clamp(_input.throttle - _input.steering, -1, 1);
    var drive_input = (left_track + right_track) * 0.5;
    var turn_input = (right_track - left_track) * 0.5;
    var tow_speed_multiplier = winch_get_drive_multiplier(id);
    var drive_limit = drive_input >= 0
        ? max_forward_speed
        : max_reverse_speed;
    var target_drive_speed = drive_input
        * drive_limit
        * tow_speed_multiplier;
    var is_opposite_input = (drive_speed > 0 && drive_input < 0)
        || (drive_speed < 0 && drive_input > 0);

    if (is_opposite_input)
    {
        // Opposite input is a brake until the current direction reaches zero.
        // Reverse/forward acceleration begins on a later step, so speed never
        // jumps directly through zero.
        drive_speed = skidsteer_approach_value(
            drive_speed,
            0,
            brake_deceleration
        );
    }
    else if (drive_input == 0)
    {
        drive_speed = skidsteer_approach_value(
            drive_speed,
            0,
            coast_deceleration
        );
    }
    else
    {
        var drive_acceleration = drive_input > 0
            ? forward_acceleration
            : reverse_acceleration;
        var is_reducing_same_direction = sign(drive_speed) == sign(target_drive_speed)
            && abs(drive_speed) > abs(target_drive_speed);

        drive_speed = skidsteer_approach_value(
            drive_speed,
            target_drive_speed,
            is_reducing_same_direction
                ? coast_deceleration
                : drive_acceleration
        );
    }

    var speed_ratio = clamp(
        abs(drive_speed) / max(max_forward_speed, 0.001),
        0,
        1
    );
    var steering_speed_multiplier = lerp(
        1,
        high_speed_turn_multiplier,
        speed_ratio
    );
    var target_turn_speed = turn_input
        * max_turn_speed
        * steering_speed_multiplier;

    turn_speed = skidsteer_approach_value(
        turn_speed,
        target_turn_speed,
        turn_input == 0 ? turn_deceleration : turn_acceleration
    );

    if (abs(drive_speed) < 0.01) drive_speed = 0;
    if (abs(turn_speed) < 0.01) turn_speed = 0;
}

function skidsteer_update_stump_approach_hint(_vehicle)
{
    var context_key = "tutorial.stump_attach";
    var current_hint = instance_find(obj_gui_hint, 0);
    var owns_hint = instance_exists(current_hint)
        && variable_instance_exists(current_hint, "context_key")
        && current_hint.context_key == context_key;
    var game_state = game_state_ensure();

    if (!task_is_active(TaskId.TIMBER_DELIVERY, game_state)
    || game_state.tutorial_stage != TutorialStage.PULL_STUMP
    || _vehicle.winch_state != WinchState.STOWED)
    {
        if (owns_hint) with (current_hint) instance_destroy();
        return;
    }

    var stump = instance_nearest(_vehicle.x, _vehicle.y, obj_stump);
    var stump_in_reach = instance_exists(stump)
        && point_distance(
            winch_get_hitch_x(_vehicle),
            winch_get_hitch_y(_vehicle),
            stump.x,
            stump.y
        ) <= _vehicle.winch_cable_length;

    if (!stump_in_reach)
    {
        if (owns_hint) with (current_hint) instance_destroy();
        return;
    }

    if (!instance_exists(current_hint))
    {
        var approach_hint = notification_show_hint(
            "Close enough. Press E to hop out, take the rear winch cable, then attach it to the stump.",
            game_get_speed(gamespeed_fps) * 8,
            true
        );
        approach_hint.context_key = context_key;
        approach_hint.panel_width = 300;
        approach_hint.panel_height = 52;
    }
}

function skidsteer_find_log_contact(_next_x, _next_y)
{
    var hit_log = noone;
    var nearest_distance = 1000000;

    for (var i = 0; i < instance_number(obj_log); i++)
    {
        var candidate = instance_find(obj_log, i);

        // The attached target must not block the vehicle towing it.
        if (candidate.tow_vehicle == id)
        {
            continue;
        }

        // Use the vehicle and log masks instead of a circular radius. The
        // downed-tree art is long and shallow, so a circle blocks empty space
        // above and below the visible tree.
        if (instance_place(_next_x, _next_y, candidate) == noone)
        {
            continue;
        }

        var candidate_distance = point_distance(
            _next_x,
            _next_y,
            candidate.x,
            candidate.y
        );

        if (candidate_distance < nearest_distance)
        {
            hit_log = candidate;
            nearest_distance = candidate_distance;
        }
    }

    return hit_log;
}

function skidsteer_handle_log_contact(_log)
{
    drive_speed = 0;
    skidsteer_start_contact_visual(SkidsteerState.CONTACT_BLOCKED);
    last_blocking_log = _log;

    var game_state = game_state_ensure();
    if (task_is_active(TaskId.TIMBER_DELIVERY, game_state)
    && game_state.tutorial_stage == TutorialStage.INSPECT_FIRST_LOG)
    {
        progression_set_tutorial_stage(
            game_state,
            TutorialStage.TAKE_WINCH_CABLE
        );
        save_write();
    }

    if (_log.notice_cooldown <= 0)
    {
        notification_show_dialogue(
            _log.blocked_message,
            id,
            _log.notice_time,
            NotificationStyle.MEMORY
        );

        notification_show_hint(
            _log.blocked_hint,
            _log.notice_time,
            true
        );

        _log.notice_cooldown = _log.notice_time;
    }
}

function skidsteer_handle_fieldrock_contact(_fieldrock, _input)
{
    drive_speed = 0;

    if (_input.throttle > 0)
    {
        if (!progress_can_crush_resource(_fieldrock.resource_id)
        && _fieldrock.fieldrock_state == FieldrockState.WAITING)
        {
            skidsteer_start_contact_visual(SkidsteerState.CONTACT_BLOCKED);

            if (carry_full_hint_cooldown <= 0)
            {
                notification_show_hint(
                    "Fieldstone cargo is full. Drop off at Homebase.",
                    game_get_speed(gamespeed_fps) * 3,
                    false
                );

                carry_full_hint_cooldown = game_get_speed(gamespeed_fps) * 2;
            }

            return;
        }

        skidsteer_start_contact_visual(SkidsteerState.CRUSHING);

        with (_fieldrock)
        {
            if (fieldrock_state == FieldrockState.WAITING)
            {
                fieldrock_state = FieldrockState.STRUGGLING;
                fieldrock_reward_source = other.id;
                fieldrock_stage = 0;
                fieldrock_tick_timer = fieldrock_tick_time;
                image_index = 0;
                image_speed = 0;
            }
        }
    }
    else
    {
        skidsteer_state = SkidsteerState.CONTACT_BLOCKED;
    }
}

/// A vehicle already overlapping a rearranged world object may reverse out.
/// New collisions still block normally.
function skidsteer_object_blocks_escape(_next_x, _next_y, _object)
{
    var next_hit = instance_place(_next_x, _next_y, _object);
    if (!instance_exists(next_hit)) return false;

    var current_hit = instance_place(x, y, _object);
    if (!instance_exists(current_hit)) return true;

    var current_distance = point_distance(x, y, current_hit.x, current_hit.y);
    var next_distance = point_distance(_next_x, _next_y, current_hit.x, current_hit.y);
    return next_distance <= current_distance;
}

function skidsteer_log_blocks_escape(_log, _next_x, _next_y)
{
    if (instance_place(_next_x, _next_y, _log) == noone) return false;
    if (instance_place(x, y, _log) == noone) return true;

    var current_distance = point_distance(x, y, _log.x, _log.y);
    return point_distance(_next_x, _next_y, _log.x, _log.y) <= current_distance;
}

function skidsteer_try_move()
{
    image_angle += turn_speed;

    // The sprite faces north, while GameMaker's 0 degrees faces right.
    var movement_direction = image_angle + 90;
    var move_x = lengthdir_x(drive_speed, movement_direction);
    var move_y = lengthdir_y(drive_speed, movement_direction);
    var next_x = x + move_x;
    var next_y = y + move_y;

    var hit_log = skidsteer_find_log_contact(next_x, next_y);
    if (hit_log != noone && skidsteer_log_blocks_escape(hit_log, next_x, next_y))
    {
        skidsteer_handle_log_contact(hit_log);
        return;
    }

    var hit_fieldrock = instance_place(next_x, next_y, obj_fieldrock);
    if (hit_fieldrock != noone
    && skidsteer_object_blocks_escape(next_x, next_y, obj_fieldrock))
    {
        skidsteer_handle_fieldrock_contact(hit_fieldrock, skidsteer_input);
        return;
    }

    if (skidsteer_object_blocks_escape(next_x, next_y, obj_pond))
    {
        drive_speed = 0;
        skidsteer_start_contact_visual(SkidsteerState.CONTACT_BLOCKED);
        return;
    }

    x = next_x;
    y = next_y;

    if (skidsteer_state != SkidsteerState.DRIVING || is_crushing)
    {
        skidsteer_state = SkidsteerState.DRIVING;
        skidsteer_reset_contact_visual();
    }
}

function skidsteer_update_driving()
{
    skidsteer_input = skidsteer_read_input();
    skidsteer_update_stump_approach_hint(id);

    if (skidsteer_input.exit_pressed && exit_cooldown <= 0)
    {
        skidsteer_exit_vehicle();
        return;
    }

    skidsteer_update_tracks(skidsteer_input);
    skidsteer_try_move();
    winch_update_tow(id);
}

function skidsteer_update_empty()
{
    drive_speed = 0;
    turn_speed = 0;
}

function skidsteer_enter_vehicle(_vehicle, _actor)
{
    _actor.player_state = PlayerState.ENTERING_VEHICLE;

    _vehicle.has_driver = true;
    _vehicle.skidsteer_state = SkidsteerState.DRIVING;
    _vehicle.driver_instance = noone;
    _vehicle.exit_cooldown = 8;

    with (_actor)
    {
        instance_destroy();
    }
}

function skidsteer_get_interaction_prompt(_vehicle, _actor)
{
    var game_state = game_state_ensure();

    if (!tutorial_can_use_skidsteer())
    {
        return game_state.tutorial_stage == TutorialStage.CHOP_TREE
            ? "Chop a standing tree first"
            : "Finish hand-gathering first";
    }

    if (game_state.winch_attachment_state == AttachmentState.STORED_AT_HOME)
    {
        return "Install winch attachment";
    }

    if (_vehicle.winch_state == WinchState.CABLE_IN_HAND
    && _vehicle.winch_handler == _actor)
    {
        if (winch_player_is_near_hitch(_vehicle, _actor))
        {
            return "Stow winch cable";
        }

        return "Return cable to rear hitch";
    }

    if (game_state.winch_attachment_state == AttachmentState.INSTALLED
    && _vehicle.winch_state == WinchState.STOWED
    && winch_player_is_near_hitch(_vehicle, _actor))
    {
        return "Take winch cable";
    }

    return "Enter vehicle";
}

function skidsteer_run_interaction(_vehicle, _actor)
{
    var game_state = game_state_ensure();

    if (!tutorial_can_use_skidsteer())
    {
        var blocked_message = game_state.tutorial_stage == TutorialStage.CHOP_TREE
            ? "Use your new axe on a standing tree before taking the skidsteer."
            : "Finish the first six hand-gathered Fieldstones before using the skidsteer.";
        notification_show_hint(blocked_message, game_get_speed(gamespeed_fps) * 3, false);
        return;
    }

    if (game_state.winch_attachment_state == AttachmentState.STORED_AT_HOME)
    {
        winch_install_attachment(_vehicle);
        return;
    }

    if (_vehicle.winch_state == WinchState.CABLE_IN_HAND
    && _vehicle.winch_handler == _actor)
    {
        if (winch_player_is_near_hitch(_vehicle, _actor))
        {
            winch_stow_cable(_vehicle);
        }
        else
        {
            notification_show_hint(
                "Bring the cable back to the rear hitch before entering.",
                game_get_speed(gamespeed_fps) * 3,
                false
            );
        }

        return;
    }

    if (game_state.winch_attachment_state == AttachmentState.INSTALLED
    && _vehicle.winch_state == WinchState.STOWED
    && winch_player_is_near_hitch(_vehicle, _actor))
    {
        winch_take_cable(_vehicle, _actor);
        return;
    }

    skidsteer_enter_vehicle(_vehicle, _actor);
}
