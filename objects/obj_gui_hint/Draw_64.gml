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
var dialogue_layout = dialogue_get_active_layout();
var available_height = gui_h - margin * 2;
var resolved_panel_width = min(panel_width, gui_w - margin * 2);

if (!is_undefined(dialogue_layout))
{
    panel_right = dialogue_layout.panel_right;
    panel_bottom = dialogue_layout.panel_top - 12;
    available_height = max(48, panel_bottom - margin);
    resolved_panel_width = min(
        390,
        max(230, dialogue_layout.panel_right - dialogue_layout.panel_left)
    );
}

var horizontal_padding = 14;
var vertical_padding = 14;
var text_scale = clamp(
    min(gui_w / 1280, gui_h / 720),
    0.72,
    1
);
// Leave clear breathing room between wrapped notification lines. This panel
// often sits beside/above dialogue, where the previous tight leading made
// multi-line instructions look compressed.
var text_line_sep = 19;
var text_width = max(
    1,
    (resolved_panel_width - horizontal_padding * 2) / text_scale
);
var text_height = string_height_ext(
    message_text,
    text_line_sep,
    text_width
);

while (text_scale > 0.68
&& text_height * text_scale + vertical_padding * 2 > available_height)
{
    text_scale -= 0.04;
    text_width = max(
        1,
        (resolved_panel_width - horizontal_padding * 2) / text_scale
    );
    text_height = string_height_ext(
        message_text,
        text_line_sep,
        text_width
    );
}

var resolved_panel_height = min(
    available_height,
    max(
        panel_height,
        text_height * text_scale + vertical_padding * 2
    )
);
var panel_left = panel_right - resolved_panel_width;
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
draw_text_ext_transformed(
    panel_left + horizontal_padding,
    panel_top + vertical_padding,
    message_text,
    text_line_sep,
    text_width,
    text_scale,
    text_scale,
    0
);

draw_set_alpha(1);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(c_white);
