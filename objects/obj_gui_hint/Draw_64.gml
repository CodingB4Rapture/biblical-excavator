/// obj_gui_hint - Draw GUI Event

draw_set_font(-1);

var gui_w = display_get_gui_width();
var gui_h = display_get_gui_height();

var fade_in = min(1, age / 18);
var fade_out = sticky ? 1 : min(1, life / 28);
var hint_alpha = min(fade_in, fade_out) * 0.92;

var margin = 22;
var panel_right = gui_w - margin;
var panel_bottom = gui_h - margin;
var panel_left = panel_right - panel_width;
var panel_top = panel_bottom - panel_height;

var panel_color = make_color_rgb(27, 31, 30);
var panel_edge = make_color_rgb(103, 82, 42);
var panel_gold = make_color_rgb(212, 164, 67);
var text_color = make_color_rgb(244, 232, 203);

draw_set_alpha(hint_alpha);

draw_set_color(panel_edge);
draw_roundrect(panel_left, panel_top, panel_right, panel_bottom, false);

draw_set_color(panel_gold);
draw_roundrect(panel_left + 2, panel_top + 2, panel_right - 2, panel_bottom - 2, true);

draw_set_alpha(hint_alpha * 0.96);
draw_set_color(panel_color);
draw_roundrect(panel_left + 4, panel_top + 4, panel_right - 4, panel_bottom - 4, false);

draw_set_alpha(hint_alpha);
draw_set_color(text_color);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_text_ext(
    panel_left + 14,
    panel_top + 12,
    message_text,
    12,
    panel_width - 28
);

draw_set_alpha(1);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(c_white);
