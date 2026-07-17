/// obj_skidsteer - Create Event

var game_state = game_state_ensure();

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

skidsteer_state = SkidsteerState.DRIVING;
skidsteer_input = {
    throttle: 0,
    steering: 0,
    exit_pressed: false
};
