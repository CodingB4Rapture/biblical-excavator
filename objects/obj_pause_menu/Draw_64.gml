/// obj_pause_menu - Draw GUI Event

var gui_w = display_get_gui_width();
var gui_h = display_get_gui_height();
var layout_scale = min(
    gui_w / pause_design_width,
    gui_h / pause_design_height
);
var layout_left = (gui_w - pause_design_width * layout_scale) * 0.5;
var layout_top = (gui_h - pause_design_height * layout_scale) * 0.5;

// Keep the frozen homestead visible beneath the same panels used by the title.
draw_set_alpha(0.48);
draw_set_color(make_color_rgb(18, 16, 13));
draw_rectangle(0, 0, gui_w, gui_h, false);
draw_set_alpha(1);

draw_sprite_ext(
    menu_UI_Left_Panel,
    0,
    layout_left + 60 * layout_scale,
    layout_top + 136 * layout_scale,
    layout_scale,
    layout_scale,
    0,
    c_white,
    1
);
draw_sprite_ext(
    menu_UI_Right_Panel,
    0,
    layout_left + 624 * layout_scale,
    layout_top + 136 * layout_scale,
    layout_scale,
    layout_scale,
    0,
    c_white,
    1
);

draw_set_font(Header_font);
draw_set_halign(fa_center);
draw_set_valign(fa_top);
draw_set_color(c_dkgray);
draw_text_transformed(
    layout_left + 642 * layout_scale,
    layout_top + 46 * layout_scale,
    pause_screen == "main" ? "PAUSED" : "SETTINGS",
    layout_scale,
    layout_scale,
    0
);
draw_set_color(c_silver);
draw_text_transformed(
    layout_left + 640 * layout_scale,
    layout_top + 44 * layout_scale,
    pause_screen == "main" ? "PAUSED" : "SETTINGS",
    layout_scale,
    layout_scale,
    0
);

for (var i = 0; i < array_length(pause_buttons); i++)
{
    var button_y = pause_button_y + i * pause_button_gap;
    var is_hovered = (i == hovered_button);
    draw_sprite_ext(
        menu_UI_Button,
        is_hovered ? 1 : 0,
        layout_left + pause_button_x * layout_scale,
        layout_top + (button_y - (is_hovered ? 4 : 0)) * layout_scale,
        layout_scale,
        layout_scale,
        0,
        c_white,
        1
    );

    draw_set_font(UI_font);
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_set_color(c_black);
    draw_text_transformed(
        layout_left + (pause_button_x + 212) * layout_scale,
        layout_top + (button_y + 38) * layout_scale,
        pause_buttons[i].label,
        layout_scale,
        layout_scale,
        0
    );
    draw_set_color(c_silver);
    draw_text_transformed(
        layout_left + (pause_button_x + 210) * layout_scale,
        layout_top + (button_y + 36) * layout_scale,
        pause_buttons[i].label,
        layout_scale,
        layout_scale,
        0
    );
}

var description = (pause_screen == "main")
    ? "The homestead is paused."
    : "Settings apply immediately.";

if (hovered_button != -1)
{
    description = pause_buttons[hovered_button].description;
}

draw_set_font(description_font);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(c_silver);
draw_text_transformed(
    layout_left + 720 * layout_scale,
    layout_top + 190 * layout_scale,
    description,
    layout_scale,
    layout_scale,
    0
);

draw_set_color(make_color_rgb(255, 230, 174));
draw_text_transformed(
    layout_left + 720 * layout_scale,
    layout_top + 330 * layout_scale,
    pause_message,
    layout_scale,
    layout_scale,
    0
);

draw_set_font(UI_font);
draw_set_halign(fa_center);
draw_set_valign(fa_bottom);
draw_set_color(make_color_rgb(255, 230, 174));
var escape_hint = (pause_screen == "settings")
    ? "Escape returns"
    : "Escape resumes";
draw_text_transformed(
    layout_left + 640 * layout_scale,
    layout_top + 674 * layout_scale,
    escape_hint,
    layout_scale,
    layout_scale,
    0
);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(c_white);
draw_set_font(-1);
