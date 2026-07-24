/// obj_farmer - Draw Event

draw_set_font(-1);

world_draw_location_marker(
    x,
    y + 16,
    "FARMER",
    make_color_rgb(205, 158, 70)
);
draw_self();

draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(c_white);
