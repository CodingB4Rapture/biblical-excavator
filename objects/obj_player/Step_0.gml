/// obj_player - Step Event

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

if (instance_exists(vehicle))
{
    if (keyboard_check_pressed(ord("E")) && point_distance(x, y, vehicle.x, vehicle.y) <= enter_distance)
    {
        with (vehicle)
        {
            has_driver = true;
            driver_instance = noone;
            exit_cooldown = 8;
        }

        view_object[0] = obj_skidsteer;
        instance_destroy();
    }
}
else
{
    vehicle = instance_nearest(x, y, obj_skidsteer);
}
