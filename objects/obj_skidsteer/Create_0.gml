/// obj_skidsteer - Create Event

mask_index = spr_contact;

drive_speed = 0;
turn_speed  = 0;

max_drive_speed = 1.4;
max_turn_speed  = 0.8;

drive_acceleration = 0.08;
turn_acceleration  = 0.22;

// The artwork already faces north correctly.
image_angle = 0;

is_crushing = false;

has_driver = true;
driver_instance = noone;
exit_cooldown = 0;
last_blocking_log = noone;
carry_full_hint_cooldown = 0;

skidsteer_state = SkidsteerState.DRIVING;
skidsteer_input = {
    throttle: 0,
    steering: 0,
    exit_pressed: false
};
