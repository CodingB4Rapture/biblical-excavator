/// obj_cabin_placement_controller - Draw GUI Event

draw_set_font(-1);
var gui_w = display_get_gui_width();
var gui_h = display_get_gui_height();
draw_set_halign(fa_center);
draw_set_valign(fa_bottom);
draw_set_color(make_color_rgb(255, 236, 188));
draw_text(gui_w * 0.5, gui_h - 18, "Place Cabin Site: Left Click confirm | Right Click or Escape cancel");
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(c_white);
