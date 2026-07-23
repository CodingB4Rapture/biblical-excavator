/// obj_skidsteer - Create Event

var game_state = game_state_ensure();

mask_index = spr_contact;

drive_speed = 0;
turn_speed  = 0;

// Driving feel tuning. Speed values are pixels per step; acceleration and
// deceleration values are speed changes per step.
max_forward_speed = 1.4;
max_reverse_speed = 0.9;
forward_acceleration = 0.045;
reverse_acceleration = 0.035;
coast_deceleration = 0.025;
brake_deceleration = 0.11;

max_turn_speed = 0.8;
turn_acceleration = 0.14;
turn_deceleration = 0.18;
high_speed_turn_multiplier = 0.72;

// Keyboard input remains digital. Keeping the vehicle axes normalized and
// deadzoned here leaves a clean seam for analog controller input later.
vehicle_input_deadzone = 0.12;

// The artwork already faces north correctly.
image_angle = 0;

is_crushing = false;

has_driver = false;
driver_instance = noone;
exit_cooldown = 0;
last_blocking_log = noone;
carry_full_hint_cooldown = 0;

// Loose material carried by the vehicle is separate from player pockets.
cargo_inventory = inventory_create(10);

// The hitch and cable are drawn placeholders until attachment art exists.
winch_hitch_distance = 18;
winch_hitch_interact_radius = 22;
winch_cable_length = 96;
winch_tow_length = 34;
winch_tow_speed_multiplier = 0.62;
winch_handler = noone;
winch_target = noone;
winch_state = (game_state.winch_attachment_state == AttachmentState.INSTALLED)
    ? WinchState.STOWED
    : WinchState.UNAVAILABLE;

interaction_enabled = true;
interaction_radius = 28;
interaction_priority = 30;

interaction_get_prompt = function(_actor)
{
    return skidsteer_get_interaction_prompt(id, _actor);
};

interaction_run = function(_actor)
{
    skidsteer_run_interaction(id, _actor);
};

skidsteer_state = SkidsteerState.EMPTY;
skidsteer_input = {
    throttle: 0,
    steering: 0,
    exit_pressed: false
};
