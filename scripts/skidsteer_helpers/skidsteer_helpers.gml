/// Helper functions for obj_skidsteer.

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

function skidsteer_read_input()
{
    return {
        throttle: keyboard_check(ord("W")) - keyboard_check(ord("S")),
        steering: keyboard_check(ord("D")) - keyboard_check(ord("A")),
        exit_pressed: keyboard_check_pressed(ord("E"))
    };
}

function skidsteer_update_tracks(_input)
{
    var left_track = clamp(_input.throttle + _input.steering, -1, 1);
    var right_track = clamp(_input.throttle - _input.steering, -1, 1);

    var tow_speed_multiplier = winch_get_drive_multiplier(id);

    var target_drive_speed = ((left_track + right_track) * 0.5)
        * max_drive_speed
        * tow_speed_multiplier;
    var target_turn_speed = ((right_track - left_track) * 0.5) * max_turn_speed;

    drive_speed = lerp(drive_speed, target_drive_speed, drive_acceleration);
    turn_speed = lerp(turn_speed, target_turn_speed, turn_acceleration);

    if (abs(drive_speed) < 0.01) drive_speed = 0;
    if (abs(turn_speed) < 0.01) turn_speed = 0;
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

        var candidate_distance = point_distance(
            _next_x,
            _next_y,
            candidate.x,
            candidate.y
        );

        if (candidate_distance <= candidate.block_radius
        && candidate_distance < nearest_distance)
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
    if (game_state.tutorial_stage == TutorialStage.INSPECT_FIRST_LOG)
    {
        game_state.tutorial_stage = TutorialStage.TAKE_WINCH_CABLE;
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

function skidsteer_handle_rock_contact(_rock, _input)
{
    drive_speed = 0;

    if (_input.throttle > 0)
    {
        if (!progress_can_collect_rocks(1) && _rock.rock_state == RockState.WAITING)
        {
            skidsteer_start_contact_visual(SkidsteerState.CONTACT_BLOCKED);

            if (carry_full_hint_cooldown <= 0)
            {
                notification_show_hint(
                    "Rock carry is full. Drop off at Homebase.",
                    game_get_speed(gamespeed_fps) * 3,
                    false
                );

                carry_full_hint_cooldown = game_get_speed(gamespeed_fps) * 2;
            }

            return;
        }

        skidsteer_start_contact_visual(SkidsteerState.CRUSHING);

        with (_rock)
        {
            if (rock_state == RockState.WAITING)
            {
                rock_state = RockState.STRUGGLING;
                rock_reward_source = other.id;
                rock_stage = 0;
                rock_tick_timer = rock_tick_time;
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
    if (hit_log != noone)
    {
        skidsteer_handle_log_contact(hit_log);
        return;
    }

    var hit_rock = instance_place(next_x, next_y, obj_rock);
    if (hit_rock != noone)
    {
        skidsteer_handle_rock_contact(hit_rock, skidsteer_input);
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

    if (game_state.tutorial_stage < TutorialStage.TRIP_TWO_VEHICLE_FIELDSTONE)
    {
        return "Finish hand-gathering first";
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

    if (game_state.tutorial_stage < TutorialStage.TRIP_TWO_VEHICLE_FIELDSTONE)
    {
        notification_show_hint("Finish the first six hand-gathered fieldstones before using the skidsteer.", game_get_speed(gamespeed_fps) * 3, false);
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
