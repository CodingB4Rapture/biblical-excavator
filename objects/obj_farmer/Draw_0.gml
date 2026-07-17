/// obj_farmer - Draw Event

draw_set_font(-1);

draw_set_color(make_color_rgb(81, 72, 54));
draw_circle(x, y - 7, 5, false);
draw_roundrect(x - 6, y - 2, x + 6, y + 11, false);
draw_set_halign(fa_center);
draw_set_valign(fa_bottom);
draw_set_color(make_color_rgb(244, 232, 203));
draw_text(x, y - 14, "FARMER");
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(c_white);
