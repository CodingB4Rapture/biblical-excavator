/// obj_cabin_site - Draw Event
/// Temporary 64 x 64 construction marker until cabin-stage art exists.

draw_set_font(-1);
draw_set_alpha(0.42);
draw_set_color(make_color_rgb(171, 127, 69));
draw_rectangle(x - 32, y - 32, x + 32, y + 32, false);
draw_set_alpha(1);
draw_set_color(make_color_rgb(236, 199, 119));
draw_rectangle(x - 32, y - 32, x + 32, y + 32, true);
draw_line(x - 32, y - 32, x + 32, y + 32);
draw_line(x + 32, y - 32, x - 32, y + 32);
draw_set_halign(fa_center);
draw_set_valign(fa_bottom);
draw_text(x, y - 38, "CABIN SITE");
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(c_white);
