/// Quest command compatibility adapters and announcement requests.

function quest_show_notice(_heading, _quest_id, _show_rewards = false)
{
    progression_queue_quest_notice(
        _heading,
        _quest_id,
        _show_rewards
    );
    return true;
}

function quest_start(_quest_id)
{
    var game_state = game_state_ensure();

    if (game_state.quest_statuses[_quest_id] != QuestStatus.LOCKED)
    {
        return false;
    }

    progression_set_quest_status(
        game_state,
        _quest_id,
        QuestStatus.ACTIVE
    );
    quest_show_notice("QUEST STARTED", _quest_id);
    return true;
}

function quest_complete(_quest_id)
{
    var game_state = game_state_ensure();

    if (game_state.quest_statuses[_quest_id] == QuestStatus.COMPLETE)
    {
        return false;
    }

    progression_set_quest_status(
        game_state,
        _quest_id,
        QuestStatus.COMPLETE
    );
    quest_show_notice("QUEST COMPLETED", _quest_id, true);
    return true;
}
