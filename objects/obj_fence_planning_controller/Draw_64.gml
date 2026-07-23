/// obj_fence_planning_controller - Draw GUI Event

var gui_w = display_get_gui_width();
var gui_h = display_get_gui_height();

draw_set_font(-1);
draw_set_halign(fa_center);
draw_set_valign(fa_bottom);
draw_set_color(make_color_rgb(255, 236, 188));
draw_text(
    gui_w * 0.5,
    gui_h - 34,
    "Fence Plan: Left Click choose corners/install gate | Right Click remove/cancel | G gate "
        + (gate_mode ? "ON" : "OFF")
        + " | F save/exit | Escape cancel"
);
draw_set_color(layout_status.valid
    ? make_color_rgb(132, 232, 151)
    : make_color_rgb(255, 184, 92));
draw_text(gui_w * 0.5, gui_h - 16, status_message);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(c_white);
