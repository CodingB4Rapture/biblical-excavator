/// Plain progression-announcement descriptors and their transient queue.

function progression_announcement_reset()
{
    global.progression_announcement_queue = [];
}

function progression_announcement_ensure()
{
    if (!variable_global_exists("progression_announcement_queue")
    || !is_array(global.progression_announcement_queue))
    {
        progression_announcement_reset();
    }

    return global.progression_announcement_queue;
}

function progression_queue_announcement(
    _heading,
    _title,
    _reward_lines = undefined,
    _followup_hint = ""
)
{
    var reward_lines = is_array(_reward_lines) ? _reward_lines : [];
    var queue = progression_announcement_ensure();
    array_push(
        queue,
        {
            heading: _heading,
            title: _title,
            reward_lines: reward_lines,
            followup_hint: _followup_hint
        }
    );
    global.progression_announcement_queue = queue;
}

function progression_queue_task_started(_task_id, _followup_hint = "")
{
    progression_queue_announcement(
        "TASK STARTED",
        task_get_definition(_task_id).title,
        [],
        _followup_hint
    );
}

function progression_queue_task_completed(_task_id, _followup_hint = "")
{
    var definition = task_get_definition(_task_id);
    progression_queue_announcement(
        "TASK COMPLETE",
        definition.title,
        definition.reward_labels,
        _followup_hint
    );
}

function progression_queue_quest_notice(
    _heading,
    _quest_id,
    _show_rewards = false,
    _followup_hint = ""
)
{
    var definition = quest_get_definition(_quest_id);
    progression_queue_announcement(
        _heading,
        definition.title,
        _show_rewards ? definition.rewards : [],
        _followup_hint
    );
}
