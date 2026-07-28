/// Draw-only presentation for the current area-entry event.

function world_area_draw_enter_banner(_controller)
{
    if (cutscene_is_active()) return false;

    if (_controller.banner_timer <= 0) return;

    var gui_w = display_get_gui_width();
    var total = _controller.banner_duration;
    var age = total - _controller.banner_timer;
    var enter_frames = 24;
    var fade_frames = 70;
    var enter_amount = clamp(age / enter_frames, 0, 1);
    var eased_enter = 1 - power(1 - enter_amount, 3);
    var fade_amount = clamp(
        _controller.banner_timer / fade_frames,
        0,
        1
    );
    var banner_alpha = min(enter_amount, fade_amount);

    draw_set_font(-1);
    var title_width = string_width(_controller.banner_area_name);
    var panel_width = max(300, title_width + 112);
    var panel_height = 42;
    var panel_left = (gui_w - panel_width) * 0.5;
    var panel_top = lerp(-panel_height - 8, 20, eased_enter);
    if (_controller.banner_timer < fade_frames)
    {
        panel_top -= (1 - fade_amount) * 5;
    }
    var panel_right = panel_left + panel_width;
    var panel_bottom = panel_top + panel_height;

    draw_set_alpha(banner_alpha * 0.28);
    draw_set_color(c_black);
    draw_roundrect(
        panel_left + 4,
        panel_top + 5,
        panel_right + 4,
        panel_bottom + 5,
        false
    );

    draw_set_alpha(banner_alpha);
    draw_set_color(make_color_rgb(91, 61, 32));
    draw_roundrect(panel_left, panel_top, panel_right, panel_bottom, false);
    draw_set_color(make_color_rgb(218, 184, 116));
    draw_roundrect(
        panel_left + 3,
        panel_top + 3,
        panel_right - 3,
        panel_bottom - 3,
        false
    );
    draw_set_color(make_color_rgb(242, 219, 163));
    draw_roundrect(
        panel_left + 7,
        panel_top + 7,
        panel_right - 7,
        panel_bottom - 7,
        false
    );

    draw_set_color(make_color_rgb(180, 139, 74));
    draw_roundrect(
        panel_left - 9,
        panel_top + 10,
        panel_left + 9,
        panel_bottom - 10,
        false
    );
    draw_roundrect(
        panel_right - 9,
        panel_top + 10,
        panel_right + 9,
        panel_bottom - 10,
        false
    );

    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_set_color(make_color_rgb(45, 38, 28));
    draw_text(
        gui_w * 0.5,
        panel_top + panel_height * 0.5,
        _controller.banner_area_name
    );

    draw_set_alpha(1);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    draw_set_color(c_white);
}
