/// Compatibility commands that orchestrate state, effects, and announcements.

function progression_finish_farmer_intro()
{
    var game_state = game_state_ensure();
    if (!progression_finish_farmer_intro_state(game_state))
        return false;

    progression_queue_quest_notice(
        "QUEST STARTED",
        QuestId.FIRM_FOUNDATION
    );
    return true;
}

function task_start(_task_id)
{
    var game_state = game_state_ensure();
    if (!progression_accept_task_state(_task_id, game_state))
        return false;

    progression_apply_task_start_effects(_task_id);
    progression_present_task_started(
        _task_id,
        progression_task_start_followup(_task_id, game_state)
    );
    return true;
}

function task_claim_reward(_task_id)
{
    var game_state = game_state_ensure();
    if (!progression_claim_task_state(_task_id, game_state))
        return false;

    progression_present_task_claimed(_task_id);
    return true;
}

/// Compatibility path for a version-one save captured on the final page of
/// the old stump-delivery dialogue.
function progression_unlock_cabin_from_legacy_dialogue()
{
    var game_state = game_state_ensure();
    if (!progression_unlock_cabin_from_legacy_state(game_state))
        return false;

    notification_show_hint(
        "Cabin work unlocked. Accept Park the Skidsteer at the Task Board.",
        game_get_speed(gamespeed_fps) * 6,
        false
    );
    save_write();
    return true;
}
