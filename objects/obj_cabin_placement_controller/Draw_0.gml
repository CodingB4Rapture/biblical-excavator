/// obj_cabin_placement_controller - Draw Event

var fence_bounds = cabin_fence_plot_bounds_at(preview_x, preview_y);

draw_set_alpha(0.20);
draw_set_color(placement_valid
    ? make_color_rgb(99, 190, 105)
    : make_color_rgb(204, 78, 69));
draw_rectangle(
    fence_bounds.min_x,
    fence_bounds.min_y,
    fence_bounds.max_x,
    fence_bounds.max_y,
    false
);
draw_set_alpha(1);
draw_rectangle(
    fence_bounds.min_x,
    fence_bounds.min_y,
    fence_bounds.max_x,
    fence_bounds.max_y,
    true
);
draw_set_alpha(0.35);
draw_sprite(spr_cabin_before, 0, preview_x, preview_y);
draw_set_alpha(1);
draw_rectangle(preview_x - 32, preview_y - 32, preview_x + 32, preview_y + 32, true);
draw_line(preview_x - 32, preview_y - 32, preview_x + 32, preview_y + 32);
draw_line(preview_x + 32, preview_y - 32, preview_x - 32, preview_y + 32);
draw_set_color(c_white);
