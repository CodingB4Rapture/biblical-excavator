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
var text_line_sep = 12;
var text_width = panel_width - 28;
var text_height = string_height_ext(
    message_text,
    text_line_sep,
    text_width
);
var resolved_panel_height = max(panel_height, text_height + 24);
var dialogue_layout = dialogue_get_active_layout();

if (!is_undefined(dialogue_layout))
{
    panel_right = dialogue_layout.panel_right;
    panel_bottom = dialogue_layout.panel_top - 12;
}

var panel_left = panel_right - panel_width;
var panel_top = panel_bottom - resolved_panel_height;

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
    text_line_sep,
    text_width
);

draw_set_alpha(1);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(c_white);
