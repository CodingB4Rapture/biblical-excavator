/// obj_tutorial_guidance - Draw Event
/// Draw the in-world marker only while the target is inside Camera 0.

if (gameplay_is_paused()
|| dialogue_is_active()
|| instance_exists(obj_task_board_menu)
|| instance_exists(obj_quest_menu)
|| instance_exists(obj_inventory_menu)
|| instance_exists(obj_pause_menu)
|| instance_exists(obj_cabin_placement_controller))
{
    exit;
}

var guidance = tutorial_guidance_target();
if (!guidance.valid
|| guidance.room_name != room_get_name(room))
{
    exit;
}

var active_camera = view_camera[0];
if (active_camera == -1
|| !point_in_rectangle(
    guidance.x,
    guidance.y,
    camera_get_view_x(active_camera),
    camera_get_view_y(active_camera),
    camera_get_view_x(active_camera)
        + camera_get_view_width(active_camera),
    camera_get_view_y(active_camera)
        + camera_get_view_height(active_camera)
))
{
    exit;
}

var bob = sin(current_time * 0.008) * 3;
var arrow_x = guidance.x;
var arrow_tip_y = guidance.y - 20 + bob;
var arrow_top_y = arrow_tip_y - 14;

draw_set_alpha(0.45);
draw_set_color(make_color_rgb(92, 65, 12));
draw_triangle(
    arrow_x - 7,
    arrow_top_y + 2,
    arrow_x + 7,
    arrow_top_y + 2,
    arrow_x,
    arrow_tip_y + 2,
    false
);

draw_set_alpha(1);
draw_set_color(make_color_rgb(255, 216, 64));
draw_triangle(
    arrow_x - 7,
    arrow_top_y,
    arrow_x + 7,
    arrow_top_y,
    arrow_x,
    arrow_tip_y,
    false
);
draw_set_color(c_white);
