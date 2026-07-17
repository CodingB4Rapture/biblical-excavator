/// obj_gui_quest_notice - Draw GUI Event

draw_set_font(-1);

var gui_w = display_get_gui_width();
var gui_h = display_get_gui_height();
var panel_width = min(gui_w - 32, 320);
var showing_rewards = array_length(reward_lines) > 0;
var panel_height = showing_rewards ? 112 : 64;
var panel_left = (gui_w - panel_width) * 0.5;
var panel_top = gui_h * 0.42 - panel_height * 0.5;
var panel_right = panel_left + panel_width;
var panel_bottom = panel_top + panel_height;
var fade_in = min(1, age / 12);
var fade_out = min(1, life / 24);
var notice_alpha = min(fade_in, fade_out) * 0.96;

draw_set_alpha(notice_alpha);
draw_set_color(make_color_rgb(71, 50, 25));
draw_roundrect(panel_left, panel_top, panel_right, panel_bottom, false);
draw_set_color(make_color_rgb(222, 174, 77));
draw_roundrect(panel_left + 2, panel_top + 2, panel_right - 2, panel_bottom - 2, true);
draw_set_color(make_color_rgb(28, 25, 21));
draw_roundrect(panel_left + 5, panel_top + 5, panel_right - 5, panel_bottom - 5, false);

draw_set_halign(fa_center);
draw_set_valign(fa_top);
draw_set_color(make_color_rgb(255, 220, 92));
draw_text(gui_w * 0.5, panel_top + 10, notice_heading);
draw_set_color(make_color_rgb(247, 236, 207));
draw_text(gui_w * 0.5, panel_top + 32, quest_title);

if (showing_rewards)
{
    draw_set_halign(fa_left);
    draw_set_color(make_color_rgb(255, 220, 92));
    draw_text(panel_left + 14, panel_top + 54, "REWARDS");

    draw_set_color(make_color_rgb(224, 214, 190));

    for (var i = 0; i < array_length(reward_lines); i++)
    {
        draw_text(panel_left + 18, panel_top + 72 + i * 16, "- " + reward_lines[i]);
    }
}

draw_set_alpha(1);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(c_white);
