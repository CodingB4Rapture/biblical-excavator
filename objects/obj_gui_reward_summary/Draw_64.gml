/// obj_gui_reward_summary - Draw GUI Event

var fade_in = min(1, age / 14);
var fade_out = min(1, life / 28);
var panel_alpha = min(fade_in, fade_out) * 0.94;

var gui_w = display_get_gui_width();

var panel_right = gui_w - 22;
var panel_top = 22;
var panel_left = panel_right - panel_width;
var panel_bottom = panel_top + panel_height;

var panel_color = make_color_rgb(25, 29, 28);
var panel_edge = make_color_rgb(82, 63, 32);
var panel_gold = make_color_rgb(212, 164, 67);
var text_color = make_color_rgb(244, 232, 203);
var xp_color = make_color_rgb(255, 220, 92);

draw_set_alpha(panel_alpha);

draw_set_color(panel_edge);
draw_roundrect(panel_left, panel_top, panel_right, panel_bottom, false);

draw_set_color(panel_gold);
draw_roundrect(panel_left + 2, panel_top + 2, panel_right - 2, panel_bottom - 2, true);

draw_set_alpha(panel_alpha * 0.96);
draw_set_color(panel_color);
draw_roundrect(panel_left + 4, panel_top + 4, panel_right - 4, panel_bottom - 4, false);

draw_set_alpha(panel_alpha);
draw_set_halign(fa_left);
draw_set_valign(fa_top);

draw_set_color(text_color);
draw_text(panel_left + 12, panel_top + 10, line_one);

draw_set_color(xp_color);
draw_text(panel_left + 12, panel_top + 32, line_two);

draw_set_alpha(1);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(c_white);
