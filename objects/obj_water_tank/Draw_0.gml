/// obj_water_tank - Draw Event

var game_state = game_state_read();
var tank_amount = clamp(
    game_state.water_tank_amount,
    0,
    WATER_TANK_CAPACITY
);

// Frame 0 is empty; frame 1 shows water through the sight window.
image_index = tank_amount > 0 ? 1 : 0;
draw_self();

var counter_text = string(tank_amount)
    + "/"
    + string(WATER_TANK_CAPACITY);
draw_set_alpha(0.82);
draw_set_color(make_color_rgb(25, 20, 16));
draw_roundrect(x + 3, y + 35, x + 29, y + 48, false);
draw_set_alpha(1);
draw_set_font(UI_font);
draw_set_halign(fa_center);
draw_set_valign(fa_middle);
draw_set_color(c_black);
draw_text_transformed(
    x + 17,
    y + 42,
    counter_text,
    0.22,
    0.22,
    0
);
draw_set_color(make_color_rgb(243, 229, 190));
draw_text_transformed(
    x + 16,
    y + 41,
    counter_text,
    0.22,
    0.22,
    0
);
draw_set_font(-1);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(c_white);
