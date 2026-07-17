/// obj_cabin_placement_controller - Draw Event

draw_set_alpha(0.34);
draw_set_color(placement_valid
    ? make_color_rgb(99, 190, 105)
    : make_color_rgb(204, 78, 69));
draw_rectangle(preview_x - 32, preview_y - 32, preview_x + 32, preview_y + 32, false);
draw_set_alpha(1);
draw_rectangle(preview_x - 32, preview_y - 32, preview_x + 32, preview_y + 32, true);
draw_line(preview_x - 32, preview_y - 32, preview_x + 32, preview_y + 32);
draw_line(preview_x + 32, preview_y - 32, preview_x - 32, preview_y + 32);
draw_set_color(c_white);
