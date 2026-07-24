/// obj_player - Step Event

if (gameplay_is_paused()) exit;

if (dialogue_is_active())
{
    exit;
}

switch (player_state)
{
    case PlayerState.WALKING:
    {
        var move_x = input_move_x();
        var move_y = input_move_y();

        if (move_x != 0 || move_y != 0)
        {
            var move_direction = point_direction(0, 0, move_x, move_y);
            var next_x = x + lengthdir_x(move_speed, move_direction);
            var next_y = y + lengthdir_y(move_speed, move_direction);

            if (!player_movement_is_blocked(id, next_x, next_y, 6, obj_fieldrock)
            && !player_movement_is_blocked(id, next_x, next_y, 6, obj_tree)
            && !player_movement_is_blocked(id, next_x, next_y, 6, obj_log)
            && !player_movement_is_blocked(id, next_x, next_y, 6, obj_stump)
            && !player_movement_is_blocked(id, next_x, next_y, 6, obj_pond)
            && !player_movement_is_blocked(id, next_x, next_y, 6, obj_world_collision_blocker)
            && !player_movement_is_blocked(id, next_x, next_y, 6, obj_task_board))
            {
                x = clamp(next_x, 0, room_width);
                y = clamp(next_y, 0, room_height);
            }
        }

        if (!instance_exists(vehicle))
        {
            vehicle = instance_nearest(x, y, obj_skidsteer);
        }

        // Keep a carried winch cable within its readable maximum length.
        winch_limit_cable_holder(id);

        // Rocks, logs, the vehicle, and the wife all use this one E action.
        player_update_interaction(id);

        break;
    }
}

