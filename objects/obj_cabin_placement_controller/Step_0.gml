/// obj_cabin_placement_controller - Step Event

var active_camera = view_camera[0];
var view_x = camera_get_view_x(active_camera);
var view_y = camera_get_view_y(active_camera);
var view_w = camera_get_view_width(active_camera);
var view_h = camera_get_view_height(active_camera);
var mouse_view_x = window_mouse_get_x() / max(1, window_get_width());
var mouse_view_y = window_mouse_get_y() / max(1, window_get_height());

preview_x = round((view_x + mouse_view_x * view_w) / grid_size) * grid_size;
preview_y = round((view_y + mouse_view_y * view_h) / grid_size) * grid_size;
placement_valid = cabin_placement_is_valid(preview_x, preview_y);

if (keyboard_check_pressed(vk_escape) || mouse_check_button_pressed(mb_right))
{
    gameplay_set_paused(false);
    instance_destroy();
    notification_show_hint("Cabin placement cancelled. Press B when you are ready.", game_get_speed(gamespeed_fps) * 3, false);
    exit;
}

if (mouse_check_button_pressed(mb_left))
{
    if (cabin_place_site(preview_x, preview_y))
    {
        gameplay_set_paused(false);
        instance_destroy();
        notification_show_hint("Cabin site placed. The future crafting system will build it in stages.", game_get_speed(gamespeed_fps) * 5, false);
    }
    else
    {
        notification_show_hint("That space is blocked. Choose a clear 64 x 64 area.", game_get_speed(gamespeed_fps) * 2, false);
    }
}
