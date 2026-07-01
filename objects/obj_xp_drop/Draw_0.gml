/// obj_xp_drop - Draw Event

var drop_alpha = min(1, life / 18);
var text = "+" + string(xp_amount) + " XP";

draw_set_alpha(drop_alpha);
draw_set_halign(fa_center);
draw_set_valign(fa_middle);

draw_set_color(c_black);
draw_text(x + 1, y + 1, text);

draw_set_color(make_color_rgb(255, 220, 92));
draw_text(x, y, text);

draw_set_alpha(1);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(c_white);

