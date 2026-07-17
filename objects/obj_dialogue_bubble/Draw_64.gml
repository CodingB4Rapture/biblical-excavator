/// obj_dialogue_bubble - Draw GUI Event
/// Asset-free portrait placeholder: replace this drawing with character art later.

draw_set_font(-1);

var gui_w = display_get_gui_width();
var gui_h = display_get_gui_height();
var margin = 20;
var panel_height = 160;
var panel_left = margin;
var panel_right = gui_w - margin;
var panel_bottom = gui_h - margin;
var panel_top = panel_bottom - panel_height;
var portrait_size = panel_height - 24;
var portrait_left = panel_left + 12;
var portrait_top = panel_top + 12;
var text_left = portrait_left + portrait_size + 18;
var text_right = panel_right - 22;

var panel_color = make_color_rgb(35, 29, 23);
var border_dark = make_color_rgb(74, 48, 21);
var border_gold = make_color_rgb(220, 170, 70);
var text_color = make_color_rgb(255, 240, 208);

draw_set_color(border_dark);
draw_roundrect(panel_left, panel_top, panel_right, panel_bottom, false);
draw_set_color(border_gold);
draw_roundrect(panel_left + 3, panel_top + 3, panel_right - 3, panel_bottom - 3, false);
draw_set_color(panel_color);
draw_roundrect(panel_left + 7, panel_top + 7, panel_right - 7, panel_bottom - 7, false);

// Temporary face card.
draw_set_color(make_color_rgb(105, 79, 48));
draw_rectangle(portrait_left, portrait_top, portrait_left + portrait_size, portrait_top + portrait_size, false);
draw_set_color(make_color_rgb(224, 183, 132));
draw_circle(portrait_left + portrait_size * 0.5, portrait_top + portrait_size * 0.46, portrait_size * 0.25, false);
draw_set_color(make_color_rgb(77, 52, 34));
draw_circle(portrait_left + portrait_size * 0.5, portrait_top + portrait_size * 0.31, portrait_size * 0.28, false);
draw_set_color(make_color_rgb(44, 32, 25));
draw_circle(portrait_left + portrait_size * 0.42, portrait_top + portrait_size * 0.46, 3, false);
draw_circle(portrait_left + portrait_size * 0.58, portrait_top + portrait_size * 0.46, 3, false);
draw_set_color(make_color_rgb(95, 57, 40));
draw_rectangle(portrait_left + portrait_size * 0.35, portrait_top + portrait_size * 0.62, portrait_left + portrait_size * 0.65, portrait_top + portrait_size * 0.66, false);
draw_set_color(make_color_rgb(70, 102, 81));
draw_triangle(portrait_left + 16, portrait_top + portrait_size, portrait_left + portrait_size - 16, portrait_top + portrait_size, portrait_left + portrait_size * 0.5, portrait_top + portrait_size * 0.63, false);

draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(border_gold);
draw_text(text_left, panel_top + 20, speaker_name);
draw_set_color(text_color);
draw_text_ext(text_left, panel_top + 47, pages[page_index], 10, text_right - text_left);

draw_set_halign(fa_right);
draw_set_valign(fa_bottom);
draw_set_color(make_color_rgb(232, 209, 158));
draw_text(panel_right - 20, panel_bottom - 16, "Click, [E], Enter, or Space to continue");

draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(c_white);
