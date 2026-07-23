/// obj_gui_reward_summary - Draw GUI Event

draw_set_font(-1);

var fade_in = min(1, age / 14);
var fade_out = min(1, life / 28);
var panel_alpha = min(fade_in, fade_out) * 0.94;

var gui_w = display_get_gui_width();
var horizontal_padding = 14;
var vertical_padding = 10;
var line_gap = 5;
var line_separation = 14;
var max_panel_width = max(120, gui_w - 44);
var min_panel_width = min(230, max_panel_width);
var desired_panel_width = max(
    string_width(line_one),
    string_width(line_two)
) + horizontal_padding * 2;

// Most reward summaries remain on one line. Long delivery summaries grow up
// to a sensible cap, then wrap and increase the panel height instead of
// escaping through its right edge.
panel_width = clamp(
    desired_panel_width,
    min_panel_width,
    min(440, max_panel_width)
);

var content_width = max(1, panel_width - horizontal_padding * 2);
var line_one_height = string_height_ext(
    line_one,
    line_separation,
    content_width
);
var line_two_height = string_height_ext(
    line_two,
    line_separation,
    content_width
);

panel_height = max(
    58,
    vertical_padding
    + line_one_height
    + line_gap
    + line_two_height
    + vertical_padding
);

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
draw_text_ext(
    panel_left + horizontal_padding,
    panel_top + vertical_padding,
    line_one,
    line_separation,
    content_width
);

draw_set_color(xp_color);
draw_text_ext(
    panel_left + horizontal_padding,
    panel_top + vertical_padding + line_one_height + line_gap,
    line_two,
    line_separation,
    content_width
);

draw_set_alpha(1);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(c_white);
