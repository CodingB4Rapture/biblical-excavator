/// obj_skidsteer_parking_pad - Draw Event

var pad_status = task_get_status(TaskId.PARK_SKIDSTEER);

if (pad_status == TaskStatus.LOCKED)
{
    exit;
}

var left = x - pad_width * 0.5;
var right = x + pad_width * 0.5;
var top = y - pad_height * 0.5;
var bottom = y + pad_height * 0.5;
var vehicle = instance_find(obj_skidsteer, 0);
var occupied = instance_exists(vehicle)
    && skidsteer_parking_pad_contains(id, vehicle);
var fill_colour = occupied
    ? make_color_rgb(103, 132, 72)
    : make_color_rgb(112, 91, 58);

draw_set_alpha(0.58);
draw_set_color(fill_colour);
draw_rectangle(left, top, right, bottom, false);

draw_set_alpha(0.82);
draw_set_color(make_color_rgb(73, 58, 39));
draw_rectangle(left, top, right, bottom, true);
draw_line(left + 8, top + 12, right - 8, top + 12);
draw_line(left + 8, bottom - 12, right - 8, bottom - 12);

draw_set_alpha(0.72);
draw_set_color(make_color_rgb(214, 184, 112));
draw_line(left + 8, y, right - 8, y);
draw_set_alpha(1);
draw_set_color(c_white);
