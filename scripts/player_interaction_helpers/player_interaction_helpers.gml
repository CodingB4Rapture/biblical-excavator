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
    var prompt_y = target.y - 20;

    draw_set_halign(fa_center);
    draw_set_valign(fa_bottom);

    draw_set_color(make_color_rgb(35, 27, 18));
    draw_text(target.x + 1, prompt_y + 1, "[E] " + _actor.interaction_prompt);

    draw_set_color(make_color_rgb(255, 226, 126));
    draw_text(target.x, prompt_y, "[E] " + _actor.interaction_prompt);

    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    draw_set_color(c_white);
}
