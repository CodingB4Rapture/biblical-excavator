/// Shared contextual interaction behavior for the on-foot player.

function player_find_interactable(_actor)
{
    var best_target = noone;
    var best_priority = -1000000;
    var best_distance = 1000000;
    var target_count = instance_number(obj_interactable_parent);

    for (var i = 0; i < target_count; i++)
    {
        var target = instance_find(obj_interactable_parent, i);

        if (!instance_exists(target) || target == _actor)
        {
            continue;
        }

        if (!target.interaction_enabled)
        {
            continue;
        }

        var target_distance = point_distance(_actor.x, _actor.y, target.x, target.y);
        var allowed_distance = min(_actor.interact_distance, target.interaction_radius);

        if (target_distance > allowed_distance)
        {
            continue;
        }

        var target_prompt = target.interaction_get_prompt(_actor);

        if (target_prompt == "")
        {
            continue;
        }

        if (target.interaction_priority > best_priority
        || (target.interaction_priority == best_priority && target_distance < best_distance))
        {
            best_target = target;
            best_priority = target.interaction_priority;
            best_distance = target_distance;
        }
    }

    return best_target;
}

function player_update_interaction(_actor)
{
    _actor.interaction_target = player_find_interactable(_actor);
    _actor.interaction_prompt = "";

    if (!instance_exists(_actor.interaction_target))
    {
        return;
    }

    var target = _actor.interaction_target;
    _actor.interaction_prompt = target.interaction_get_prompt(_actor);

    if (keyboard_check_pressed(ord("E")))
    {
        target.interaction_run(_actor);
    }
}

function player_draw_interaction(_actor)
{
    if (!instance_exists(_actor.interaction_target) || _actor.interaction_prompt == "")
    {
        return;
    }

    var target = _actor.interaction_target;
    var prompt_text = _actor.interaction_prompt;
    var text_scale = 0.5;
    var key_scale = 0.5;
    var panel_padding = 4;
    var prompt_width = string_width(prompt_text) * text_scale;
    var prompt_height = string_height(prompt_text) * text_scale;
    var key_width = string_width("E") * key_scale + panel_padding * 2;
    var key_height = string_height("E") * key_scale;
    var panel_height = max(prompt_height, key_height) + panel_padding * 2;
    var panel_width = panel_padding * 3 + key_width + prompt_width;
    var panel_center_x = clamp(target.x, panel_width * 0.5 + 2, room_width - panel_width * 0.5 - 2);
    var panel_bottom = max(panel_height + 4, target.y - 22);
    var panel_top = panel_bottom - panel_height;
    var panel_left = panel_center_x - panel_width * 0.5;
    var panel_right = panel_center_x + panel_width * 0.5;
    var pointer_x = clamp(target.x, panel_left + 8, panel_right - 8);

    // A compact version of the dialogue palette keeps interaction prompts in
    // the same visual language without competing with full conversations.
    draw_set_alpha(0.96);
    draw_set_color(make_color_rgb(74, 48, 21));
    draw_roundrect(panel_left, panel_top, panel_right, panel_bottom, false);
    draw_triangle(pointer_x - 3, panel_bottom, pointer_x + 3, panel_bottom, pointer_x, panel_bottom + 4, false);

    draw_set_color(make_color_rgb(220, 170, 70));
    draw_roundrect(panel_left + 1, panel_top + 1, panel_right - 1, panel_bottom - 1, false);
    draw_set_color(make_color_rgb(35, 29, 23));
    draw_roundrect(panel_left + 2, panel_top + 2, panel_right - 2, panel_bottom - 2, false);

    var key_left = panel_left + panel_padding;
    var key_top = panel_top + 2;
    var key_bottom = panel_bottom - 2;
    var key_text_y = panel_top + (panel_height - key_height) * 0.5;
    var prompt_text_y = panel_top + (panel_height - prompt_height) * 0.5;
    draw_set_color(make_color_rgb(105, 79, 48));
    draw_roundrect(key_left, key_top, key_left + key_width, key_bottom, false);

    draw_set_halign(fa_center);
    draw_set_valign(fa_top);
    draw_set_color(make_color_rgb(255, 226, 126));
    draw_text_transformed(key_left + key_width * 0.5, key_text_y, "E", key_scale, key_scale, 0);

    draw_set_halign(fa_left);
    draw_set_color(make_color_rgb(255, 240, 208));
    draw_text_transformed(
        key_left + key_width + panel_padding,
        prompt_text_y,
        prompt_text,
        text_scale,
        text_scale,
        0
    );

    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    draw_set_alpha(1);
    draw_set_color(c_white);
}

/// Small ground marker used for named people and important world locations.
function world_draw_location_marker(_x, _y, _label, _accent, _radius = 7)
{
    draw_set_font(-1);

    draw_set_alpha(0.22);
    draw_set_color(_accent);
    draw_circle(_x, _y, _radius, false);

    draw_set_alpha(0.9);
    draw_set_color(_accent);
    draw_circle(_x, _y, _radius, true);
    draw_set_color(make_color_rgb(35, 29, 23));
    draw_circle(_x, _y, 2, false);

    var label_y = _y + _radius + 2;
    var label_scale = 0.45;
    draw_set_halign(fa_center);
    draw_set_valign(fa_top);
    draw_set_color(make_color_rgb(35, 29, 23));
    draw_text_transformed(_x + 1, label_y + 1, _label, label_scale, label_scale, 0);
    draw_set_color(make_color_rgb(244, 232, 203));
    draw_text_transformed(_x, label_y, _label, label_scale, label_scale, 0);

    draw_set_alpha(1);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    draw_set_color(c_white);
}
