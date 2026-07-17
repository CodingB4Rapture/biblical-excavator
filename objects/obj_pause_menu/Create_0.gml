/// obj_pause_menu - Create Event

pause_snapshot = save_build_snapshot();
pause_screen = "main";
pause_message = "Game paused";
hovered_button = -1;
pause_design_width = 1280;
pause_design_height = 720;
pause_button_x = 82;
pause_button_y = 150;
pause_button_gap = 82;

pause_show_main = function()
{
    pause_screen = "main";
    pause_buttons = [
        {label: "CONTINUE", description: "Return to the homestead.", action: "continue"},
        {label: "SAVE", description: "Save your current progress.", action: "save"},
        {label: "SETTINGS", description: "Adjust fullscreen and master volume.", action: "settings"},
        {label: "MAIN MENU", description: "Save and return to the title screen.", action: "main_menu"}
    ];
};

pause_show_settings = function()
{
    var settings = settings_ensure();
    pause_screen = "settings";
    pause_buttons = [
        {label: "FULLSCREEN: " + (settings.fullscreen ? "ON" : "OFF"), description: "Toggle fullscreen display.", action: "fullscreen"},
        {label: "VOLUME: " + string(round(settings.master_volume * 100)) + "%", description: "Cycle through five master-volume levels.", action: "volume"},
        {label: "BACK", description: "Return to the pause menu.", action: "back"}
    ];
};

pause_resume_game = function()
{
    gameplay_set_paused(false);
    instance_destroy();
};

pause_show_main();
gameplay_set_paused(true);
