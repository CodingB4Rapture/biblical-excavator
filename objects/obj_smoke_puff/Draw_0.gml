/// obj_smoke_puff - Draw Event

var fade = life / life_max;

draw_set_alpha(fade * 0.65);
draw_set_color(c_gray);

draw_circle(
    x,
    y,
    puff_size,
    false
);

// Always reset drawing settings afterward.
draw_set_alpha(1);
draw_set_color(c_white);