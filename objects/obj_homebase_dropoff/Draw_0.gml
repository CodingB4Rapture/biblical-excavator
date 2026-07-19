/// obj_homebase_dropoff - Draw Event

draw_set_font(-1);

draw_set_alpha(0.16);
draw_set_color(make_color_rgb(92, 126, 70));
draw_circle(x, y, dropoff_radius, false);

draw_set_alpha(0.72);
draw_set_color(make_color_rgb(205, 158, 70));
draw_circle(x, y, dropoff_radius, true);
draw_set_color(make_color_rgb(115, 151, 83));
draw_circle(x, y, dropoff_radius - 3, true);

world_draw_location_marker(x, y, "HOME DELIVERY", make_color_rgb(226, 178, 73), 9);

draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(c_white);

