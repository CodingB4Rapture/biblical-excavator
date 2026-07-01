/// obj_homebase_dropoff - Draw Event

draw_set_alpha(0.34);
draw_set_color(make_color_rgb(74, 92, 58));
draw_circle(x, y, dropoff_radius, false);

draw_set_alpha(1);
draw_set_color(make_color_rgb(205, 158, 70));
draw_circle(x, y, dropoff_radius, true);

draw_set_halign(fa_center);
draw_set_valign(fa_middle);
draw_set_color(make_color_rgb(244, 232, 203));
draw_text(x, y - 4, "HOMEBASE");
draw_text(x, y + 10, "DROP-OFF");

draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(c_white);

