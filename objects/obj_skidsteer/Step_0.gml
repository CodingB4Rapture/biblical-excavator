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
// Add 90 because the original sprite faces north.
var movement_direction = image_angle + 90;

x += lengthdir_x(
    drive_speed,
    movement_direction
);

y += lengthdir_y(
    drive_speed,
    movement_direction
);