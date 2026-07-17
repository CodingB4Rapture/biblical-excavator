/// obj_camera_controller - Step Event

if (gameplay_is_paused()) exit;

// Never let the room's legacy object-follow setting fight this controller.
view_object[0] = noone;

if (camera_mode == CameraMode.CUTSCENE)
{
    if (instance_exists(camera_focus_instance))
    {
        camera_focus_x = camera_focus_instance.x;
        camera_focus_y = camera_focus_instance.y;
    }

    if (camera_cutscene_timer > 0)
    {
        camera_cutscene_timer -= 1;

        if (camera_cutscene_timer <= 0)
        {
            camera_follow_gameplay();
        }
    }
}

if (camera_mode == CameraMode.FOLLOW_GAMEPLAY)
{
    var player = instance_find(obj_player, 0);

    if (instance_exists(player))
    {
        camera_focus_x = player.x;
        camera_focus_y = player.y;
    }
    else
    {
        var vehicle = instance_find(obj_skidsteer, 0);

        if (instance_exists(vehicle))
        {
            camera_focus_x = vehicle.x;
            camera_focus_y = vehicle.y;
        }
    }
}

camera_zoom = lerp(camera_zoom, camera_target_zoom, camera_zoom_smoothing);

var view_width = camera_base_width / camera_zoom;
var view_height = camera_base_height / camera_zoom;
var desired_x = clamp(camera_focus_x - (view_width * 0.5), 0, max(0, room_width - view_width));
var desired_y = clamp(camera_focus_y - (view_height * 0.5), 0, max(0, room_height - view_height));
var current_x = camera_get_view_x(view_camera[0]);
var current_y = camera_get_view_y(view_camera[0]);

camera_set_view_size(view_camera[0], view_width, view_height);
camera_set_view_pos(
    view_camera[0],
    lerp(current_x, desired_x, camera_follow_smoothing),
    lerp(current_y, desired_y, camera_follow_smoothing)
);
