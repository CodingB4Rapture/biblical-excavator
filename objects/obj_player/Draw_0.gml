/// obj_player - Draw Event

draw_set_font(-1);

draw_set_color(c_navy);
draw_circle(x, y, 6, false);

draw_set_color(c_white);

if (!cutscene_is_active())
    player_draw_interaction(id);
draw_circle(x, y - 2, 2, false);

draw_set_color(c_white);

