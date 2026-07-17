/// obj_player - Step Event

if (dialogue_is_active())
{
    exit;
}

switch (player_state)
{
    case PlayerState.WALKING:
    {
        var move_x = keyboard_check(ord("D")) - keyboard_check(ord("A"));
        var move_y = keyboard_check(ord("S")) - keyboard_check(ord("W"));

        if (move_x != 0 || move_y != 0)
        {
            var move_direction = point_direction(0, 0, move_x, move_y);
            var next_x = x + lengthdir_x(move_speed, move_direction);
            var next_y = y + lengthdir_y(move_speed, move_direction);

            if (!collision_circle(next_x, next_y, 6, obj_rock, false, true))
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

