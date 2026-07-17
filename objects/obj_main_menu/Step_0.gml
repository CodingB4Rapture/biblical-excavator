/// obj_main_menu - Step Event

var gui_mouse_x = window_mouse_get_x() * (1280 / max(1, window_get_width()));
var gui_mouse_y = window_mouse_get_y() * (720 / max(1, window_get_height()));
hovered_button = -1;

if (keyboard_check_pressed(vk_escape) && menu_screen == "settings")
{
    menu_show_main();
    exit;
}

for (var i = 0; i < array_length(menu_buttons); i++)
{
    var button_y = menu_button_y + i * menu_button_gap;

    if (point_in_rectangle(gui_mouse_x, gui_mouse_y, menu_button_x, button_y,
        menu_button_x + sprite_get_width(menu_UI_Button),
        button_y + sprite_get_height(menu_UI_Button)))
    {
        hovered_button = i;
        break;
    }
}

if (hovered_button == -1 || !mouse_check_button_pressed(mb_left))
{
    exit;
}

selected_button = hovered_button;
var action = menu_buttons[selected_button].action;

if (action == "new_game")
{
    save_new_game();
    room_goto(Room1);
}
else if (action == "continue")
{
    if (save_load())
    {
        room_goto(save_get_restore_room(Room1));
    }
    else
    {
        menu_message = "No readable save was found. Start a New Game first.";
    }
}
else if (action == "settings")
{
    menu_show_settings();
}
else if (action == "fullscreen")
{
    var settings = settings_ensure();
    settings.fullscreen = !settings.fullscreen;
    settings_apply();
    save_update_settings();
    menu_show_settings();
}
else if (action == "volume")
{
    var settings = settings_ensure();
    settings.master_volume -= 0.25;
    if (settings.master_volume < 0) settings.master_volume = 1;
    settings_apply();
    save_update_settings();
    menu_show_settings();
}
else if (action == "back")
{
    menu_show_main();
}
else if (action == "quit")
{
    game_end();
}
