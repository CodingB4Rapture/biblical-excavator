/// obj_skidsteer - Step Event

if (exit_cooldown > 0)
{
    exit_cooldown -= 1;
}

if (keyboard_check_pressed(ord("E")) && has_driver && exit_cooldown <= 0)
{
    has_driver = false;
    drive_speed = 0;
    turn_speed = 0;

    if (is_crushing)
    {
        is_crushing = false;
        sprite_index = spr_skidsteer;
        image_index = 0;
        image_speed = 1;
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
    view_object[0] = obj_player;
    exit;
}

if (!has_driver)
{
    drive_speed = 0;
    turn_speed = 0;
    exit;
}

// INPUT

var throttle =
    keyboard_check(ord("W"))
    - keyboard_check(ord("S"));

var steering =
    keyboard_check(ord("D"))
    - keyboard_check(ord("A"));
// TRACK POWER

var left_track = clamp(
    throttle + steering,
    -1,
    1
);

var right_track = clamp(
    throttle - steering,
    -1,
    1
);

// TARGET MOVEMENT

var target_drive_speed =
    ((left_track + right_track) * 0.5)
    * max_drive_speed;

var target_turn_speed =
    ((right_track - left_track) * 0.5)
    * max_turn_speed;

// ACCELERATION

drive_speed = lerp(
    drive_speed,
    target_drive_speed,
    drive_acceleration
);

turn_speed = lerp(
    turn_speed,
    target_turn_speed,
    turn_acceleration
);

if (abs(drive_speed) < 0.01)
{
    drive_speed = 0;
}

if (abs(turn_speed) < 0.01)
{
    turn_speed = 0;
}

// ROTATION

image_angle += turn_speed;
// MOVEMENT

// The sprite faces north, while GameMaker's 0 degrees faces right.
var movement_direction = image_angle + 90;

// Calculate how far we want to move this Step.
var move_x = lengthdir_x(
    drive_speed,
    movement_direction
);

var move_y = lengthdir_y(
    drive_speed,
    movement_direction
);

// Calculate the proposed new position.
var next_x = x + move_x;
var next_y = y + move_y;

// Check whether that proposed position would touch a rock.
var hit_rock = instance_place(
    next_x,
    next_y,
    obj_rock
);

if (hit_rock == noone)
{
    // Nothing is blocking us.
    x = next_x;
    y = next_y;

    // Leave crushing mode.
    if (is_crushing)
    {
        is_crushing = false;

        // Return to the normal visible skidsteer.
        sprite_index = spr_skidsteer;
        image_index = 0;
        image_speed = 1;
    }
}
else
{
    // A rock is blocking us.
    drive_speed = 0;

    // Only crush while pushing forward.
    if (keyboard_check(ord("W")))
    {
        // Begin the visible contact animation once.
        if (!is_crushing)
        {
            is_crushing = true;

            sprite_index = spr_contact;
            image_index = 0;
            image_speed = 1;
        }

        // Begin the rock animation.
        with (hit_rock)
        {
            if (rock_state == 0)
            {
                rock_state = 1;

                image_index = 0;
                image_speed = 3;
            }
        }
    }
}

