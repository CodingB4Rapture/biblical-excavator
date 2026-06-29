/// obj_skidsteer - Step Event

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
    // Nothing is blocking us, so movement is allowed.
    x = next_x;
    y = next_y;
}
else
{
    // A rock is blocking us.
    // Stop forward motion while crushing it.
    drive_speed = 0;

    // Only begin crushing when driving forward.
    if (move_x != 0 || move_y != 0)
    {
        if (keyboard_check(ord("W")))
        {
            with (hit_rock)
            {
                // Only start once.
                if (rock_state == 0)
                {
                    rock_state = 1;

                    // Begin the crushing animation.
                    image_index = 0;
                    image_speed = 3;
                }
            }
        }
    }
}