/// obj_gui_trip_status - Draw GUI Event

progress_ensure_inventory();

var panel_left = 22;
var panel_top = 22;
var panel_right = panel_left + panel_width;
var panel_bottom = panel_top + panel_height;

var panel_color = make_color_rgb(21, 25, 24);
var panel_edge = make_color_rgb(74, 57, 30);
var panel_gold = make_color_rgb(196, 145, 49);
var text_color = make_color_rgb(235, 224, 198);
var accent_color = make_color_rgb(255, 220, 92);

draw_set_alpha(0.92);

draw_set_color(panel_edge);
draw_roundrect(panel_left, panel_top, panel_right, panel_bottom, false);

draw_set_color(panel_gold);
draw_roundrect(panel_left + 2, panel_top + 2, panel_right - 2, panel_bottom - 2, true);

draw_set_alpha(0.88);
draw_set_color(panel_color);
draw_roundrect(panel_left + 4, panel_top + 4, panel_right - 4, panel_bottom - 4, false);

draw_set_alpha(1);
draw_set_halign(fa_left);
draw_set_valign(fa_top);

draw_set_color(accent_color);
draw_text(panel_left + 12, panel_top + 10, "Trip Haul");

draw_set_color(text_color);
draw_text(panel_left + 12, panel_top + 32, "Rocks: " + string(global.carried_rocks) + " / " + string(global.rock_carry_max));
draw_text(panel_left + 12, panel_top + 50, "Logs: " + string(global.carried_logs) + " / " + string(global.log_carry_max));
draw_text(panel_left + 12, panel_top + 70, "Rocks Depleted: " + string(global.trip_rocks_depleted));
draw_text(panel_left + 12, panel_top + 88, "XP Gained: " + string(global.trip_xp_gained));

draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(c_white);

