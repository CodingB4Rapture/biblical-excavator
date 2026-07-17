/// obj_camera_controller - Create Event
/// One owner for gameplay follow, zoom, and future dialogue cutscenes.

camera_mode = CameraMode.FOLLOW_GAMEPLAY;
camera_focus_instance = noone;
camera_focus_x = 0;
camera_focus_y = 0;
camera_zoom = 1;
camera_target_zoom = 1;
camera_follow_smoothing = 0.16;
camera_zoom_smoothing = 0.12;
camera_cutscene_timer = 0;

// Preserve Room1's intended starting composition: 480 x 240 game pixels.
camera_base_width = 480;
camera_base_height = 240;

view_enabled = true;
view_visible[0] = true;
view_object[0] = noone;

camera_set_view_size(view_camera[0], camera_base_width, camera_base_height);
