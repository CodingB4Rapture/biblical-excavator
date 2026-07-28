/// Explicit skill transactions and player-facing results.

function skill_levelup_queue_reset()
{
    global.skill_levelup_queue = [];
}

function skill_levelup_queue_ensure()
{
    if (!variable_global_exists("skill_levelup_queue")
    || !is_array(global.skill_levelup_queue))
    {
        skill_levelup_queue_reset();
    }
    return global.skill_levelup_queue;
}

function skill_queue_levelup(_skill_id, _level)
{
    if (is_undefined(skill_definition(_skill_id))
    || _level < 2
    || _level > SKILL_MASTERY_LEVEL_CAP)
    {
        return false;
    }

    var queue = skill_levelup_queue_ensure();
    array_push(
        queue,
        {
            skill_id: _skill_id,
            level: _level
        }
    );
    global.skill_levelup_queue = queue;
    return true;
}

function skill_queue_levelup_result(_skill_id, _result)
{
    if (!is_struct(_result)
    || !_result.changed
    || _result.new_level <= _result.old_level)
    {
        return false;
    }

    for (var level = _result.old_level + 1;
        level <= _result.new_level;
        level++)
    {
        skill_queue_levelup(_skill_id, level);
    }
    return true;
}

function skill_levelup_queue_contains(_skill_id, _level)
{
    var queue = skill_levelup_queue_ensure();
    for (var queue_index = 0;
        queue_index < array_length(queue);
        queue_index++)
    {
        if (queue[queue_index].skill_id == _skill_id
        && queue[queue_index].level == _level)
        {
            return true;
        }
    }
    return false;
}

function skill_queue_pending_level_prompts()
{
    if (dialogue_is_active()) return false;

    var game_state = game_state_read();
    if (!variable_struct_exists(game_state, "tools")
    || !is_struct(game_state.tools)
    || !variable_struct_exists(
        game_state.tools,
        "axe_notching_prompt_pending"
    )
    || !game_state.tools.axe_notching_prompt_pending
    || !variable_struct_exists(
        game_state.tools,
        "axe_notching_preference"
    )
    || game_state.tools.axe_notching_preference
        != AxeNotchingPreference.UNDECIDED
    || skill_levelup_queue_contains(SkillId.TOOLMANSHIP, 2))
    {
        return false;
    }

    return skill_queue_levelup(SkillId.TOOLMANSHIP, 2);
}

function skill_capture_levels_state(_game_state)
{
    var levels = array_create(SkillId.COUNT, 1);
    for (var skill_id = 0; skill_id < SkillId.COUNT; skill_id++)
    {
        levels[skill_id] = skill_level_from_xp(
            skill_id,
            skill_get_xp(skill_id, _game_state)
        );
    }
    return levels;
}

function skill_queue_level_changes_state(_before_levels, _game_state)
{
    if (!is_array(_before_levels)) return false;

    var changed = false;
    for (var skill_id = 0; skill_id < SkillId.COUNT; skill_id++)
    {
        var old_level = skill_id < array_length(_before_levels)
            ? _before_levels[skill_id]
            : 1;
        var new_level = skill_level_from_xp(
            skill_id,
            skill_get_xp(skill_id, _game_state)
        );
        changed = skill_queue_levelup_result(
            skill_id,
            {
                changed: new_level > old_level,
                old_level: old_level,
                new_level: new_level
            }
        ) || changed;
    }
    return changed;
}

function skill_levelup_update()
{
    skill_queue_pending_level_prompts();
    var queue = skill_levelup_queue_ensure();
    if (array_length(queue) == 0
    || cutscene_is_active()
    || dialogue_is_active()
    || instance_exists(obj_task_board_menu)
    || instance_exists(obj_quest_menu)
    || instance_exists(obj_inventory_menu)
    || instance_exists(obj_skills_menu)
    || instance_exists(obj_map_menu)
    || instance_exists(obj_finished_crafts_menu)
    || instance_exists(obj_build_menu)
    || instance_exists(obj_production_menu)
    || instance_exists(obj_pause_menu)
    || instance_exists(obj_gui_quest_notice))
    {
        return false;
    }

    var levelup = queue[0];
    var remaining = [];
    for (var queue_index = 1;
        queue_index < array_length(queue);
        queue_index++)
    {
        array_push(remaining, queue[queue_index]);
    }
    global.skill_levelup_queue = remaining;

    notification_show_dialogue(
        skill_levelup_pages(levelup.skill_id, levelup.level),
        noone,
        0,
        NotificationStyle.XP,
        "SKILL LEVEL UP"
    );
    return true;
}

function skill_set_axe_notching_preference(_enabled)
{
    var game_state = game_state_ensure();
    var preference = _enabled
        ? AxeNotchingPreference.ENABLED
        : AxeNotchingPreference.DISABLED;
    if (!skill_set_axe_notching_preference_state(
        game_state,
        preference
    ))
    {
        return false;
    }

    progress_show_reward_summary(
        "Axe Notching",
        _enabled
            ? "Future felled trees will be notched"
            : "The axe will remain unnotched"
    );
    save_write();
    return true;
}

function skill_award_xp(_skill_id, _amount)
{
    var game_state = game_state_ensure();
    var result = skill_award_xp_state(
        game_state,
        _skill_id,
        _amount
    );
    if (!result.changed) return false;

    var definition = skill_definition(_skill_id);
    progress_show_reward_summary(
        "+" + string(result.amount) + " " + definition.display_name + " XP",
        result.new_level > result.old_level
            ? "Level up: " + string(result.new_level)
            : "Level " + string(result.new_level)
    );
    skill_queue_levelup_result(_skill_id, result);
    save_write();
    return true;
}
