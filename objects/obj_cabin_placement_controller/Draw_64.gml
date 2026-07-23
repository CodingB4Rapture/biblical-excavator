/// obj_cabin_placement_controller - Draw GUI Event

draw_set_font(-1);
var gui_w = display_get_gui_width();
var gui_h = display_get_gui_height();
var panel_w = min(370, gui_w - 32);
var panel_left = gui_w - panel_w - 18;
var panel_top = gui_h - 100;
var panel_right = gui_w - 18;
var panel_bottom = gui_h - 18;

draw_set_alpha(0.94);
draw_set_color(make_color_rgb(122, 87, 44));
draw_roundrect(panel_left, panel_top, panel_right, panel_bottom, false);
draw_set_color(make_color_rgb(35, 29, 23));
draw_roundrect(panel_left + 3, panel_top + 3, panel_right - 3, panel_bottom - 3, false);
draw_set_alpha(1);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(make_color_rgb(255, 207, 105));
draw_text(panel_left + 14, panel_top + 12, "CHOOSE THE CABIN SITE");
draw_set_color(make_color_rgb(244, 225, 188));
draw_text(panel_left + 14, panel_top + 36, "The outline includes the cabin and its front yard.");
draw_text(panel_left + 14, panel_top + 58, "Left Click: choose    Right Click / Esc: cancel");
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(c_white);
