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
                completion_summary: "You secured sixteen Fieldstones, a Timber Log, and Small Lumber; learned the skidsteer and winch; and received a cabin site plan.",
                rewards: [
                    "Cabin Site Plan",
                    "Cabin Placement Unlocked"
                ]
            };
        }

        case QuestId.PLACE_OF_YOUR_OWN:
        {
            return {
                title: "A Place of Your Own",
                summary: "Park the work vehicle, mark a bounded cabin plot with one gate, and build a place of your own.",
                completion_summary: "You parked the skidsteer, enclosed the cabin and front yard, and raised the finished cabin.",
                rewards: [
                    "Homestead Site Established",
                    "First Morning Unlocked"
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

function quest_get_objectives(_quest_id)
{
    var game_state = game_state_ensure();

    if (_quest_id == QuestId.PLACE_OF_YOUR_OWN)
    {
        return [
            {
                text: "Park the skidsteer beside the Farmer",
                complete: game_state.skidsteer_parked
            },
            {
                text: "Choose the cabin site",
                complete: game_state.cabin_site_placed
            },
            {
                text: "Enclose the cabin and front yard with one gate",
                complete: game_state.cabin_fence_marked
            },
            {
                text: "Build the cabin",
                complete: game_state.cabin_built
            }
        ];
    }

    if (_quest_id != QuestId.FIRM_FOUNDATION) return [];

    var home_stones = inventory_get_amount(
        game_state.home_inventory,
        ResourceId.FIELDSTONE
    );
    var home_logs = inventory_get_amount(
        game_state.home_inventory,
        ResourceId.TIMBER_LOG
    );
    var home_small_lumber = inventory_get_amount(
        game_state.home_inventory,
        ResourceId.SMALL_LUMBER
    );
    var quest_finished = quest_get_status(_quest_id) == QuestStatus.COMPLETE;

    return [
        {
            text: "Speak with the Farmer",
            complete: quest_finished
                || tutorial_stage_rank(game_state.tutorial_stage) >= 1
        },
        {
            text: "Receive the first task from the Farmer's Wife",
            complete: quest_finished
                || game_state.task_statuses[TaskId.FIELDSTONE_BY_HAND]
                    >= TaskStatus.AVAILABLE
        },
        {
            text: "Collect 6 Fieldstones by hand ("
                + string(min(game_state.tutorial_fieldstones_collected, 6)) + "/6)",
            complete: quest_finished || game_state.tutorial_fieldstones_collected >= 6
        },
        {
            text: "Receive the gifted axe",
            complete: quest_finished || game_state.tools.axe_owned
        },
        {
            text: "Use the axe on a standing tree",
            complete: quest_finished
                || game_state.task_statuses[TaskId.FALLEN_TREE]
                    >= TaskStatus.COMPLETE
                || tutorial_stage_rank(game_state.tutorial_stage) >= 4
        },
        {
            text: "Inspect the fallen tree and stump",
            complete: quest_finished
                || game_state.task_statuses[TaskId.FALLEN_TREE]
                    >= TaskStatus.COMPLETE
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
        },
        {
            text: "Pull and deliver the stump as Small Lumber ("
                + string(min(home_small_lumber, 1)) + "/1)",
            complete: quest_finished || home_small_lumber >= 1
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
