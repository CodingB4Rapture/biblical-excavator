/// obj_main_menu - Draw GUI Event

draw_sprite(menu_background, 0, 0, 0);
draw_sprite(menu_UI_Left_Panel, 0, 60, 136);
draw_sprite(menu_UI_Right_Panel, 0, 624, 136);

draw_set_font(Header_font);
draw_set_halign(fa_center);
draw_set_valign(fa_top);
draw_set_color(c_dkgray);
draw_text(642, 46, menu_title);
draw_set_color(c_silver);
draw_text(640, 44, menu_title);

for (var i = 0; i < array_length(menu_buttons); i++)
{
    var button = menu_buttons[i];
    var button_y = menu_button_y + i * menu_button_gap;
    var is_hovered = (i == hovered_button);
    var frame = is_hovered ? 1 : 0;

    draw_sprite(menu_UI_Button, frame, menu_button_x, button_y - (is_hovered ? 4 : 0));
    draw_set_font(UI_font);
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_set_color(c_black);
    draw_text(menu_button_x + 212, button_y + 38, button.label);
    draw_set_color(c_silver);
    draw_text(menu_button_x + 210, button_y + 36, button.label);
}

var description = (menu_screen == "main")
    ? "Choose New Game or Continue."
    : "Settings apply immediately.";

if (hovered_button != -1)
{
    description = menu_buttons[hovered_button].description;
}

draw_set_font(description_font);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(c_silver);
draw_text_ext(720, 190, description, font_get_size(description_font) + 3, 440);

if (menu_message != "")
{
    draw_set_color(make_color_rgb(255, 214, 117));
    draw_text_ext(720, 330, menu_message, font_get_size(description_font) + 3, 440);
}

draw_set_font(UI_font);
draw_set_halign(fa_center);
draw_set_valign(fa_bottom);
draw_set_color(c_silver);
draw_text(640, 674, menu_footer);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(c_white);
draw_set_font(-1);
