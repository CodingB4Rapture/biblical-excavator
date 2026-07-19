/// obj_winch_package - Draw Event

draw_set_color(make_color_rgb(80, 53, 25));
draw_rectangle(x - 11, y - 8, x + 11, y + 8, false);
draw_set_color(make_color_rgb(205, 153, 61));
draw_rectangle(x - 9, y - 6, x + 9, y + 6, false);
draw_set_color(make_color_rgb(245, 220, 120));
draw_rectangle(x - 2, y - 8, x + 2, y + 8, false);
draw_set_color(make_color_rgb(48, 112, 60));
draw_line_width(x - 5, y, x - 1, y + 4, 2);
draw_line_width(x - 1, y + 4, x + 7, y - 4, 2);
draw_set_color(c_white);
