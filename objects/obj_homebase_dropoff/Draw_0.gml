/// obj_homebase_dropoff - Draw Event

draw_set_font(-1);

var circle_fill = vehicle_inside_dropoff
    ? make_color_rgb(93, 134, 83)
    : make_color_rgb(92, 126, 70);
var circle_edge = vehicle_inside_dropoff
    ? make_color_rgb(235, 197, 88)
    : make_color_rgb(205, 158, 70);

draw_set_alpha(vehicle_inside_dropoff ? 0.24 : 0.16);
draw_set_color(circle_fill);
draw_circle(x, y, dropoff_radius, false);

draw_set_alpha(vehicle_inside_dropoff ? 0.9 : 0.72);
draw_set_color(circle_edge);
draw_circle(x, y, dropoff_radius, true);

// Keep the parking circle beneath the physical delivery point. The second
// chest frame remains open until the interacting player leaves the zone.
var chest_frame = chest_open ? 1 : 0;
draw_sprite_ext(
    spr_chest,
    chest_frame,
    chest_draw_x,
    chest_draw_y,
    chest_scale_x,
    chest_scale_y,
    0,
    c_white,
    1
);

draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_alpha(1);
draw_set_color(c_white);

