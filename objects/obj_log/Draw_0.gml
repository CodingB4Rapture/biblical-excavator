/// obj_log - Draw Event

draw_set_color(make_color_rgb(99, 63, 35));
draw_rectangle(x - 26, y - 8, x + 26, y + 8, false);

draw_set_color(make_color_rgb(148, 97, 52));
draw_circle(x - 26, y, 8, false);
draw_circle(x + 26, y, 8, false);

draw_set_color(c_white);

