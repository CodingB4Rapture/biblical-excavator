/// Shared conversation helpers.

function dialogue_is_active()
{
    return instance_exists(obj_dialogue_bubble);
}

function dialogue_advance_pressed()
{
    // Mouse and keyboard are equal ways to advance a conversation.
    return mouse_check_button_pressed(mb_left)
        || input_interact_pressed()
        || keyboard_check_pressed(vk_enter)
        || keyboard_check_pressed(vk_space);
}

function dialogue_get_speaker_name(_speaker)
{
    if (instance_exists(_speaker))
    {
        if (_speaker.object_index == obj_farmers_wife) return "FARMER'S WIFE";
        if (_speaker.object_index == obj_farmer) return "FARMER";
        if (_speaker.object_index == obj_player) return "YOU";
    }

    return "HOMESTEAD";
}

function dialogue_get_palette(_speaker_name)
{
    var palette = {
        panel_color: make_color_rgb(43, 31, 23),
        panel_shadow: make_color_rgb(12, 10, 8),
        border_dark: make_color_rgb(82, 51, 25),
        border_gold: make_color_rgb(226, 164, 72),
        text_color: make_color_rgb(255, 229, 190),
        prompt_color: make_color_rgb(242, 195, 128),
        portrait_bg: make_color_rgb(105, 79, 48),
        skin: make_color_rgb(224, 183, 132),
        hair: make_color_rgb(77, 52, 34),
        shirt: make_color_rgb(70, 102, 81)
    };

    switch (_speaker_name)
    {
        case "FARMER":
        {
            palette.hair = make_color_rgb(78, 58, 42);
            palette.shirt = make_color_rgb(83, 111, 87);
            break;
        }

        case "FARMER'S WIFE":
        {
            palette.hair = make_color_rgb(96, 66, 45);
            palette.shirt = make_color_rgb(112, 82, 105);
            break;
        }

        case "YOU":
        {
            palette.hair = make_color_rgb(58, 46, 36);
            palette.shirt = make_color_rgb(86, 106, 125);
            break;
        }
    }

    return palette;
}

function dialogue_get_layout(_body_text)
{
    var gui_w = display_get_gui_width();
    var gui_h = display_get_gui_height();
    var margin = 22;
    var trip_hud = instance_find(obj_gui_trip_status, 0);
    var info_width = instance_exists(trip_hud)
        ? trip_hud.trip_panel_width
        : 300;
    var info_height = instance_exists(trip_hud)
        ? trip_hud.trip_panel_height
        : 172;
    var panel_gap = instance_exists(trip_hud)
        ? trip_hud.panel_gap
        : 12;
    // A few extra pixels above the trip card preserve three comfortable body
    // lines while remaining much smaller than the former full-width panel.
    var panel_height = min(184, info_height + 12);
    var panel_left = margin + info_width + panel_gap;
    var panel_right = gui_w - margin;
    var panel_bottom = gui_h - margin;
    var panel_top = panel_bottom - panel_height;
    var inner_padding = 14;

    // The standard 1280 x 720 layout places conversation immediately to the
    // right of Current Trip. On a genuinely narrow GUI, move it above the
    // information card rather than crushing the text into an unreadable strip.
    if (panel_right - panel_left < 540)
    {
        panel_left = margin;
        panel_right = gui_w - margin;
        panel_height = max(
            132,
            min(
                panel_height,
                gui_h - margin * 2 - info_height - panel_gap
            )
        );
        panel_bottom = gui_h - margin - info_height - panel_gap;
        panel_top = panel_bottom - panel_height;
    }

    var portrait_size = min(108, panel_height - inner_padding * 2);
    var portrait_left = panel_left + inner_padding;
    var portrait_top = panel_top + (panel_height - portrait_size) * 0.5;
    var text_left = portrait_left + portrait_size + 18;
    var text_right = panel_right - inner_padding;
    var speaker_top = panel_top + inner_padding + 2;
    var speaker_height = 20;
    var prompt_height = 18;
    var body_top = speaker_top + speaker_height + 10;
    var body_bottom = panel_bottom - inner_padding - prompt_height - 8;
    var body_width = max(220, text_right - text_left);
    var body_line_sep = font_get_size(description_font) + 8;

    draw_set_font(description_font);
    var body_height = string_height_ext(_body_text, body_line_sep, body_width);
    var body_space = max(0, body_bottom - body_top);
    var body_y = body_top + max(0, (body_space - body_height) * 0.5);

    return {
        gui_w: gui_w,
        gui_h: gui_h,
        panel_left: panel_left,
        panel_top: panel_top,
        panel_right: panel_right,
        panel_bottom: panel_bottom,
        inner_padding: inner_padding,
        portrait_left: portrait_left,
        portrait_top: portrait_top,
        portrait_size: portrait_size,
        text_left: text_left,
        text_right: text_right,
        speaker_top: speaker_top,
        speaker_height: speaker_height,
        body_y: body_y,
        body_width: body_width,
        body_line_sep: body_line_sep,
        prompt_y: panel_bottom - inner_padding
    };
}

function dialogue_draw_panel(_layout, _palette)
{
    draw_set_alpha(0.35);
    draw_set_color(_palette.panel_shadow);
    draw_roundrect(
        _layout.panel_left + 4,
        _layout.panel_top + 5,
        _layout.panel_right + 4,
        _layout.panel_bottom + 5,
        false
    );

    draw_set_alpha(0.98);
    draw_set_color(_palette.border_dark);
    draw_roundrect(
        _layout.panel_left,
        _layout.panel_top,
        _layout.panel_right,
        _layout.panel_bottom,
        false
    );
    draw_set_color(_palette.border_gold);
    draw_roundrect(
        _layout.panel_left + 3,
        _layout.panel_top + 3,
        _layout.panel_right - 3,
        _layout.panel_bottom - 3,
        false
    );
    draw_set_color(_palette.panel_color);
    draw_roundrect(
        _layout.panel_left + 8,
        _layout.panel_top + 8,
        _layout.panel_right - 8,
        _layout.panel_bottom - 8,
        false
    );
    draw_set_alpha(1);
}

function dialogue_draw_portrait_placeholder(_layout, _palette)
{
    var left = _layout.portrait_left;
    var top = _layout.portrait_top;
    var size = _layout.portrait_size;

    draw_set_color(_palette.border_dark);
    draw_rectangle(left - 3, top - 3, left + size + 3, top + size + 3, false);
    draw_set_color(_palette.portrait_bg);
    draw_rectangle(left, top, left + size, top + size, false);

    draw_set_color(_palette.skin);
    draw_circle(left + size * 0.5, top + size * 0.46, size * 0.25, false);
    draw_set_color(_palette.hair);
    draw_circle(left + size * 0.5, top + size * 0.31, size * 0.28, false);
    draw_set_color(make_color_rgb(44, 32, 25));
    draw_circle(left + size * 0.42, top + size * 0.46, 3, false);
    draw_circle(left + size * 0.58, top + size * 0.46, 3, false);
    draw_set_color(make_color_rgb(95, 57, 40));
    draw_rectangle(
        left + size * 0.35,
        top + size * 0.62,
        left + size * 0.65,
        top + size * 0.66,
        false
    );
    draw_set_color(_palette.shirt);
    draw_triangle(
        left + 16,
        top + size,
        left + size - 16,
        top + size,
        left + size * 0.5,
        top + size * 0.63,
        false
    );
}

function dialogue_run_completion_action(_action)
{
    switch (_action)
    {
        case "finish_farmer_intro":
        {
            var game_state = game_state_ensure();

            if (game_state.tutorial_stage == TutorialStage.TALK_TO_FARMER)
            {
                game_state.tutorial_stage = TutorialStage.TALK_TO_FARMERS_WIFE;
            }

            quest_start(QuestId.FIRM_FOUNDATION);
            break;
        }

        case "start_hand_gathering":
        {
            var game_state = game_state_ensure();

            if (game_state.tutorial_stage == TutorialStage.TALK_TO_FARMERS_WIFE)
            {
                game_state.tutorial_stage = TutorialStage.TRIP_ONE_HAND_FIELDSTONE;
                tutorial_spawn_hand_fieldstones();
                save_write();
            }

            break;
        }

        case "unlock_cabin_placement":
        {
            cabin_unlock_placement();
            break;
        }

        case "begin_cabin_placement":
        {
            cabin_begin_placement(false);
            break;
        }

        case "move_cabin_site":
        {
            cabin_begin_placement(true);
            break;
        }
    }
}
