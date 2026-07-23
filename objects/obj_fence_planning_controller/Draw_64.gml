/// obj_fence_planning_controller - Draw GUI Event

var gui_w = display_get_gui_width();
var gui_h = display_get_gui_height();
var panel_w = min(390, gui_w - 32);
var panel_h = cabin_tutorial_mode ? 164 : 132;
var panel_right = gui_w - 18;
var panel_left = panel_right - panel_w;
var panel_bottom = gui_h - 18;
var panel_top = panel_bottom - panel_h;
var panel_fill = make_color_rgb(35, 29, 23);
var panel_edge = make_color_rgb(122, 87, 44);
var warm_text = make_color_rgb(244, 225, 188);
var gold_text = make_color_rgb(255, 207, 105);

draw_set_font(-1);
draw_set_alpha(0.94);
draw_set_color(panel_edge);
draw_roundrect(panel_left, panel_top, panel_right, panel_bottom, false);
draw_set_color(panel_fill);
draw_roundrect(
    panel_left + 3,
    panel_top + 3,
    panel_right - 3,
    panel_bottom - 3,
    false
);

draw_set_alpha(1);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(gold_text);
draw_text(
    panel_left + 14,
    panel_top + 12,
    cabin_tutorial_mode ? "MARK THE CABIN SITE" : "FENCE PLANNING"
);

draw_set_color(warm_text);

if (cabin_tutorial_mode)
{
    draw_text(
        panel_left + 14,
        panel_top + 36,
        "1. Fence the highlighted cabin and front yard."
    );
    draw_text(
        panel_left + 14,
        panel_top + 54,
        "2. Press G and put one gate on the front side."
    );
    draw_text(
        panel_left + 14,
        panel_top + 78,
        "Left Click: choose/install    Right Click: undo"
    );
    draw_text(
        panel_left + 14,
        panel_top + 96,
        "G: " + (gate_mode ? "Gate mode ON" : "Gate mode OFF")
            + "    F: finish    Esc: cancel"
    );
}
else
{
    draw_text(
        panel_left + 14,
        panel_top + 38,
        "Left Click: corners/install    Right Click: remove"
    );
    draw_text(
        panel_left + 14,
        panel_top + 58,
        "G: " + (gate_mode ? "Gate mode ON" : "Gate mode OFF")
            + "    F: save and exit    Esc: cancel"
    );
}

draw_set_color(layout_status.valid
    ? make_color_rgb(132, 232, 151)
    : make_color_rgb(255, 184, 92));
draw_text_ext(
    panel_left + 14,
    cabin_tutorial_mode ? panel_top + 120 : panel_top + 84,
    status_message,
    16,
    panel_w - 28
);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(c_white);
