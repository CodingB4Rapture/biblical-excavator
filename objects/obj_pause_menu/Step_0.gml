/// obj_pause_menu - Step Event

if (keyboard_check_pressed(vk_escape))
{
    if (pause_screen == "settings")
    {
        pause_show_main();
    }
    else
    {
        pause_resume_game();
    }

    exit;
}

var gui_w = display_get_gui_width();
var gui_h = display_get_gui_height();
var button_w = sprite_get_width(menu_UI_Button);
var button_h = sprite_get_height(menu_UI_Button);
var gui_mouse_x = window_mouse_get_x() * (gui_w / max(1, window_get_width()));
var gui_mouse_y = window_mouse_get_y() * (gui_h / max(1, window_get_height()));
var layout_scale = min(
    gui_w / pause_design_width,
    gui_h / pause_design_height
);
var layout_left = (gui_w - pause_design_width * layout_scale) * 0.5;
var layout_top = (gui_h - pause_design_height * layout_scale) * 0.5;
var menu_mouse_x = (gui_mouse_x - layout_left) / max(0.001, layout_scale);
var menu_mouse_y = (gui_mouse_y - layout_top) / max(0.001, layout_scale);
hovered_button = -1;

for (var i = 0; i < array_length(pause_buttons); i++)
{
    var button_y = pause_button_y + i * pause_button_gap;

    if (point_in_rectangle(menu_mouse_x, menu_mouse_y, pause_button_x, button_y,
        pause_button_x + button_w, button_y + button_h))
    {
        hovered_button = i;
        break;
    }
}

if (hovered_button == -1 || !mouse_check_button_pressed(mb_left))
{
    exit;
}

var action = pause_buttons[hovered_button].action;

if (action == "continue")
{
    pause_resume_game();
}
else if (action == "save")
{
    pause_snapshot.settings.master_volume = settings_ensure().master_volume;
    pause_snapshot.settings.fullscreen = settings_ensure().fullscreen;
    pause_message = save_write_snapshot(pause_snapshot) ? "Game saved" : "Save failed";
}
else if (action == "settings")
{
    pause_show_settings();
}
else if (action == "fullscreen")
{
    var settings = settings_ensure();
    settings.fullscreen = !settings.fullscreen;
    settings_apply();
    pause_show_settings();
}
else if (action == "volume")
{
    var settings = settings_ensure();
    settings.master_volume -= 0.25;
    if (settings.master_volume < 0) settings.master_volume = 1;
    settings_apply();
    pause_show_settings();
}
else if (action == "back")
{
    pause_show_main();
}
else if (action == "main_menu")
{
    pause_snapshot.settings.master_volume = settings_ensure().master_volume;
    pause_snapshot.settings.fullscreen = settings_ensure().fullscreen;
    save_write_snapshot(pause_snapshot);
    gameplay_set_paused(false);
    room_goto(rm_main_menu);
}
