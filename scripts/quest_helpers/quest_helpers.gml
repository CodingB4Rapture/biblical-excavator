/// Small, repeatable quest helpers.
///
/// A quest definition explains the work. Durable progress stays in
/// global.game_state, while the existing tutorial stages drive objectives.

function quest_get_definition(_quest_id)
{
    switch (_quest_id)
    {
        case QuestId.FIRM_FOUNDATION:
        {
            return {
                title: "A Firm Foundation",
                summary: "Meet the homesteaders and gather the first stone and timber for the cabin foundation.",
                completion_summary: "You helped the homesteaders secure sixteen fieldstones and a timber log, learned to operate the skidsteer and winch, and unlocked a place to build your own cabin.",
                rewards: [
                    "Cabin Site Plan",
                    "Cabin Placement Unlocked"
                ]
            };
        }
    }

    return {
        title: "Unknown Quest",
        summary: "No quest details are available.",
        completion_summary: "No completion details are available.",
        rewards: []
    };
}

function quest_get_status(_quest_id)
{
    return game_state_ensure().quest_statuses[_quest_id];
}

function quest_get_status_text(_quest_id)
{
    switch (quest_get_status(_quest_id))
    {
        case QuestStatus.LOCKED: return "Not Started";
        case QuestStatus.ACTIVE: return "In Progress";
        case QuestStatus.COMPLETE: return "Complete";
    }

    return "Unknown";
}

function quest_show_notice(_heading, _quest_id, _show_rewards = false)
{
    var notice = instance_find(obj_gui_quest_notice, 0);

    if (!instance_exists(notice))
    {
        notice = instance_create_depth(0, 0, -1400, obj_gui_quest_notice);
    }

    notice.notice_heading = _heading;
    notice.quest_title = quest_get_definition(_quest_id).title;
    notice.reward_lines = _show_rewards
        ? quest_get_definition(_quest_id).rewards
        : [];
    notice.age = 0;
    notice.life = notice.life_max;
    return notice;
}

function quest_start(_quest_id)
{
    var game_state = game_state_ensure();

    if (game_state.quest_statuses[_quest_id] != QuestStatus.LOCKED)
    {
        return false;
    }

    game_state.quest_statuses[_quest_id] = QuestStatus.ACTIVE;
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

    game_state.quest_statuses[_quest_id] = QuestStatus.COMPLETE;
    quest_show_notice("QUEST COMPLETED", _quest_id, true);
    return true;
}

function quest_get_objectives(_quest_id)
{
    var game_state = game_state_ensure();

    if (_quest_id != QuestId.FIRM_FOUNDATION)
    {
        return [];
    }

    var home_stones = inventory_get_amount(
        game_state.home_inventory,
        ResourceId.FIELDSTONE
    );
    var home_logs = inventory_get_amount(
        game_state.home_inventory,
        ResourceId.TIMBER_LOG
    );
    var quest_finished = quest_get_status(_quest_id) == QuestStatus.COMPLETE;

    return [
        {
            text: "Speak with the Farmer",
            complete: quest_finished || game_state.tutorial_stage >= TutorialStage.TALK_TO_FARMERS_WIFE
        },
        {
            text: "Receive the first task from the Farmer's Wife",
            complete: quest_finished || game_state.tutorial_stage >= TutorialStage.TRIP_ONE_HAND_FIELDSTONE
        },
        {
            text: "Deliver 6 small fieldstones by hand (" + string(min(home_stones, 6)) + "/6)",
            complete: quest_finished || home_stones >= 6
        },
        {
            text: "Deliver 10 more fieldstones by work vehicle (" + string(min(home_stones, 16)) + "/16 total)",
            complete: quest_finished || home_stones >= 16
        },
        {
            text: "Collect the mailed winch attachment",
            complete: quest_finished || game_state.winch_attachment_state == AttachmentState.STORED_AT_HOME
                || game_state.winch_attachment_state == AttachmentState.INSTALLED
        },
        {
            text: "Install the winch attachment",
            complete: quest_finished || game_state.winch_attachment_state == AttachmentState.INSTALLED
        },
        {
            text: "Winch and deliver the timber log (" + string(min(home_logs, 1)) + "/1)",
            complete: quest_finished || home_logs >= 1
        }
    ];
}

function quest_get_current_objective(_quest_id)
{
    var objectives = quest_get_objectives(_quest_id);

    for (var i = 0; i < array_length(objectives); i++)
    {
        if (!objectives[i].complete)
        {
            return objectives[i].text;
        }
    }

    return "All objectives complete";
}
