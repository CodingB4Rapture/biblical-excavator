/// obj_cabin_placement_controller - Step Event

if (gameplay_is_paused()
|| dialogue_is_active()
|| instance_exists(obj_quest_menu)
|| instance_exists(obj_inventory_menu)
|| instance_exists(obj_pause_menu))
{
    exit;
}

var active_camera = view_camera[0];
var view_x = camera_get_view_x(active_camera);
var view_y = camera_get_view_y(active_camera);
var view_w = camera_get_view_width(active_camera);
var view_h = camera_get_view_height(active_camera);
var mouse_view_x = window_mouse_get_x() / max(1, window_get_width());
var mouse_view_y = window_mouse_get_y() / max(1, window_get_height());

preview_x = fence_snap_to_grid(view_x + mouse_view_x * view_w);
preview_y = fence_snap_to_grid(view_y + mouse_view_y * view_h);
placement_valid = cabin_placement_is_valid(preview_x, preview_y, placement_relocating);

if (input_lock_frames > 0)
{
    input_lock_frames -= 1;
    exit;
}

if (keyboard_check_pressed(vk_escape) || mouse_check_button_pressed(mb_right))
{
    instance_destroy();
    notification_show_hint("Site selection cancelled. Press B when you are ready.", game_get_speed(gamespeed_fps) * 3, false);
    exit;
}

if (mouse_check_button_pressed(mb_left))
{
    if (cabin_place_site(preview_x, preview_y, placement_relocating))
    {
        instance_destroy();
    }
    else
    {
        notification_show_hint("That cabin-and-yard area is blocked. Choose another clear space.", game_get_speed(gamespeed_fps) * 2, false);
    }
}
