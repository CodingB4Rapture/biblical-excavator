/// Presentation-side progression queue consumption and compatibility adapters.

function progression_update_announcements()
{
    var queue = progression_announcement_ensure();

    if (array_length(queue) == 0
    || instance_exists(obj_task_board_menu)
    || instance_exists(obj_quest_menu)
    || instance_exists(obj_inventory_menu)
    || instance_exists(obj_finished_crafts_menu)
    || instance_exists(obj_pause_menu)
    || instance_exists(obj_gui_quest_notice)
    || dialogue_is_active())
    {
        return false;
    }

    var announcement = queue[0];
    var remaining = [];
    for (var queue_index = 1;
        queue_index < array_length(queue);
        queue_index++)
    {
        array_push(remaining, queue[queue_index]);
    }
    global.progression_announcement_queue = remaining;

    var notice = instance_create_depth(
        0,
        0,
        -1400,
        obj_gui_quest_notice
    );
    notice.notice_heading = announcement.heading;
    notice.quest_title = announcement.title;
    notice.reward_lines = announcement.reward_lines;
    notice.age = 0;
    notice.life = notice.life_max;

    if (announcement.followup_hint != "")
    {
        notification_show_hint(
            announcement.followup_hint,
            game_get_speed(gamespeed_fps) * 6,
            false
        );
    }

    return true;
}

function progression_present_task_started(_task_id, _followup_hint = "")
{
    progression_queue_task_started(_task_id, _followup_hint);
}

function progression_present_task_claimed(_task_id)
{
    // The board may claim one task and accept the next before closing.
    // Keep completion banners free of "accept next" hints that could already
    // be stale by the time the queued presentation reaches the world.
    progression_queue_task_completed(_task_id);

    switch (_task_id)
    {
        case TaskId.TIMBER_DELIVERY:
            progression_queue_quest_notice(
                "QUEST COMPLETED",
                QuestId.FIRM_FOUNDATION,
                true
            );
            progression_queue_quest_notice(
                "QUEST STARTED",
                QuestId.PLACE_OF_YOUR_OWN
            );
            break;

        case TaskId.PLACE_CABIN:
            progression_queue_quest_notice(
                "QUEST COMPLETED",
                QuestId.PLACE_OF_YOUR_OWN,
                true
            );
            break;
    }
}

