/// obj_game_controller - Create Event
/// Durable player, household, and progression state lives outside obj_player.

// A playable room always begins live. The pause overlay sets this back to true
// only while it actually exists.
gameplay_set_paused(false);

if (instance_number(obj_game_controller) > 1)
{
    instance_destroy();
    exit;
}

var game_state = game_state_ensure();

// Lets a hot-reloaded project state receive this new tutorial flag safely.
if (!variable_struct_exists(game_state, "tutorial_intro_seen"))
{
    game_state.tutorial_intro_seen = false;
}

if (!variable_struct_exists(game_state, "tutorial_stage"))
{
    game_state.tutorial_stage = TutorialStage.TALK_TO_FARMER;
    game_state.tutorial_hand_stones_spawned = false;
}

// The camera controller chooses the active gameplay target automatically.
// It stays alive between rooms so future interiors and cutscenes use one camera.
if (!instance_exists(obj_camera_controller))
{
    instance_create_depth(0, 0, -100000, obj_camera_controller);
}

// First playable beat: free movement, with a gentle direction toward the Farmer.
if (!game_state.tutorial_intro_seen)
{
    game_state.tutorial_intro_seen = true;
    notification_show_hint("Talk to the Farmer near Home Delivery. Press Q for your Quest Journal.", game_get_speed(gamespeed_fps) * 6, false);
}
