/// obj_farmers_wife - Draw Event

draw_set_font(-1);
/// Placeholder character art. Safe to replace with a sprite later.

world_draw_location_marker(x, y + 10, "FARMER'S WIFE", make_color_rgb(190, 128, 196));

draw_set_color(make_color_rgb(91, 58, 96));
draw_circle(x, y - 7, 5, false);
draw_roundrect(x - 6, y - 2, x + 6, y + 11, false);

draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(c_white);
