/// obj_farmers_wife - Draw Event

draw_set_font(-1);

world_draw_location_marker(
    x,
    y + 16,
    "FARMER'S WIFE",
    make_color_rgb(190, 128, 196)
);
draw_self();

draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(c_white);
