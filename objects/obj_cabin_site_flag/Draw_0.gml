/// obj_cabin_site_flag - Draw Event

var game_state = game_state_ensure();
var hidden = game_state.cabin_fence_marked
    || (game_state.cabin_selected_site_id != CABIN_SITE_NONE
        && game_state.cabin_selected_site_id != site_id);

if (hidden) exit;

var flag_taken = cabin_site_flag_is_taken(
    site_id,
    corner_index,
    game_state
);

if (flag_taken)
{
    draw_set_alpha(0.32);
    draw_set_color(site_colour);
    draw_circle(x, y, 6, true);
    draw_line(x - 4, y, x + 4, y);
    draw_line(x, y - 4, x, y + 4);
}
else
{
    draw_set_alpha(1);
    draw_sprite_ext(
        spr_marker,
        image_index,
        x,
        y,
        1,
        1,
        0,
        site_colour,
        1
    );
}

draw_set_font(-1);
draw_set_halign(fa_center);
draw_set_valign(fa_bottom);
draw_set_alpha(flag_taken ? 0.55 : 0.92);
draw_set_color(make_color_rgb(35, 29, 23));
draw_text_transformed(x + 1, y - 7, site_symbol, 0.45, 0.45, 0);
draw_set_color(site_colour);
draw_text_transformed(x, y - 8, site_symbol, 0.45, 0.45, 0);

if (corner_index == 0)
{
    var choice_text = "SITE " + site_symbol + " - " + site_area_name;
    if (game_state.cabin_selected_site_id == CABIN_SITE_NONE)
    {
        choice_text += " (CHOOSE ONE)";
    }
    else
    {
        choice_text += " (SELECTED)";
    }

    draw_set_alpha(0.82);
    draw_set_color(make_color_rgb(244, 232, 203));
    draw_text_transformed(x, y - 18, choice_text, 0.42, 0.42, 0);
}

draw_set_alpha(1);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(c_white);
