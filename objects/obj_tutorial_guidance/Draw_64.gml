/// obj_tutorial_guidance - Draw GUI Event

var game_controller = instance_find(obj_game_controller, 0);
var guidance_hidden = gameplay_is_paused()
    || dialogue_is_active()
    || instance_exists(obj_task_board_menu)
    || instance_exists(obj_quest_menu)
    || instance_exists(obj_inventory_menu)
    || instance_exists(obj_pause_menu)
    || instance_exists(obj_cabin_placement_controller)
    || (
        instance_exists(game_controller)
        && game_controller.day_transition_active
    );

if (guidance_hidden) exit;

var guidance = tutorial_guidance_target();
var active_camera = view_camera[0];

if (!guidance.valid
|| guidance.room_name != room_get_name(room)
|| active_camera == -1)
{
    exit;
}

var guidance_gui_w = display_get_gui_width();
var guidance_gui_h = display_get_gui_height();
var view_x = camera_get_view_x(active_camera);
var view_y = camera_get_view_y(active_camera);
var view_w = max(1, camera_get_view_width(active_camera));
var view_h = max(1, camera_get_view_height(active_camera));
var target_gui_x = (guidance.x - view_x) * (guidance_gui_w / view_w);
var target_gui_y = (guidance.y - view_y) * (guidance_gui_h / view_h);
var edge = tutorial_guidance_gui_edge(
    target_gui_x,
    target_gui_y,
    guidance_gui_w,
    guidance_gui_h,
    44
);

if (edge.visible) exit;

var pulse = sin(current_time * 0.008) * 2;
var arrow_length = 17 + pulse;
var arrow_half_width = 8;
var arrow_tip_x = edge.x;
var arrow_tip_y = edge.y;
var arrow_base_x = arrow_tip_x
    - lengthdir_x(arrow_length, edge.direction);
var arrow_base_y = arrow_tip_y
    - lengthdir_y(arrow_length, edge.direction);
var arrow_left_x = arrow_base_x
    + lengthdir_x(arrow_half_width, edge.direction + 90);
var arrow_left_y = arrow_base_y
    + lengthdir_y(arrow_half_width, edge.direction + 90);
var arrow_right_x = arrow_base_x
    + lengthdir_x(arrow_half_width, edge.direction - 90);
var arrow_right_y = arrow_base_y
    + lengthdir_y(arrow_half_width, edge.direction - 90);

draw_set_alpha(0.5);
draw_set_color(make_color_rgb(75, 48, 11));
draw_triangle(
    arrow_tip_x + 2,
    arrow_tip_y + 2,
    arrow_left_x + 2,
    arrow_left_y + 2,
    arrow_right_x + 2,
    arrow_right_y + 2,
    false
);

draw_set_alpha(1);
draw_set_color(make_color_rgb(255, 216, 64));
draw_triangle(
    arrow_tip_x,
    arrow_tip_y,
    arrow_left_x,
    arrow_left_y,
    arrow_right_x,
    arrow_right_y,
    false
);

var label_x = arrow_tip_x - lengthdir_x(43, edge.direction);
var label_y = arrow_tip_y - lengthdir_y(43, edge.direction);
var label_text = guidance.label;

if (label_text != "")
{
    draw_set_font(-1);
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    var label_half_width = string_width(label_text) * 0.5 + 7;

    draw_set_alpha(0.82);
    draw_set_color(make_color_rgb(42, 30, 18));
    draw_roundrect(
        label_x - label_half_width,
        label_y - 9,
        label_x + label_half_width,
        label_y + 9,
        false
    );
    draw_set_alpha(1);
    draw_set_color(make_color_rgb(255, 228, 151));
    draw_text(label_x, label_y, label_text);
}

draw_set_alpha(1);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(c_white);
draw_set_font(-1);
