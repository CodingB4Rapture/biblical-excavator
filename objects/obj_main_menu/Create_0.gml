/// obj_main_menu - Create Event

var run_fence_tests = environment_get_variable("BIBLICAL_FENCE_TESTS") == "1";

for (var argument_index = 1;
    argument_index <= parameter_count();
    argument_index++)
{
    if (parameter_string(argument_index) == "--fence-tests")
    {
        run_fence_tests = true;
    }
}

if (run_fence_tests)
{
    fence_planning_run_tests();
    game_end();
    exit;
}

gameplay_set_paused(false);

// Persistent gameplay controllers are useful between playable rooms, but the
// title screen is a clean boundary between sessions.
with (obj_game_controller) instance_destroy();
with (obj_camera_controller) instance_destroy();
with (obj_dialogue_bubble) instance_destroy();

settings_ensure();
settings_apply();

menu_title = "HOMESTEAD RESTORATION";
menu_footer = "A life of restoration begins with faithful work.";
menu_message = "";
selected_button = -1;
hovered_button = -1;
menu_screen = "main";

menu_button_x = 82;
menu_button_y = 150;
menu_button_gap = 82;

menu_show_main = function()
{
    menu_screen = "main";
    menu_buttons = [
        {label: "NEW GAME", description: "Begin a fresh farmhand application.", action: "new_game"},
        {label: "CONTINUE", description: save_slot_exists() ? "Continue from the last save." : "No save exists yet.", action: "continue"},
        {label: "SETTINGS", description: "Adjust fullscreen and master volume.", action: "settings"},
        {label: "QUIT", description: "Close the game.", action: "quit"}
    ];
};

menu_show_settings = function()
{
    var settings = settings_ensure();
    menu_screen = "settings";
    menu_buttons = [
        {label: "FULLSCREEN: " + (settings.fullscreen ? "ON" : "OFF"), description: "Toggle fullscreen display.", action: "fullscreen"},
        {label: "VOLUME: " + string(round(settings.master_volume * 100)) + "%", description: "Cycle master volume through five levels.", action: "volume"},
        {label: "BACK", description: "Return to the main menu.", action: "back"}
    ];
};

menu_show_main();
