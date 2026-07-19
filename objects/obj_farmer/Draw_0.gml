/// obj_farmer - Draw Event

draw_set_font(-1);

world_draw_location_marker(x, y + 10, "FARMER", make_color_rgb(205, 158, 70));

draw_set_color(make_color_rgb(81, 72, 54));
draw_circle(x, y - 7, 5, false);
draw_roundrect(x - 6, y - 2, x + 6, y + 11, false);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(c_white);
