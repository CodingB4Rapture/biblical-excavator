/// obj_player - Draw Event

draw_set_color(c_navy);
draw_circle(x, y, 6, false);

draw_set_color(c_white);

player_draw_interaction(id);
draw_circle(x, y - 2, 2, false);

draw_set_color(c_white);

