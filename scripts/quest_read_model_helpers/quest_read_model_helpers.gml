/// Read-only quest status and objective models.

function quest_get_status(_quest_id, _game_state = undefined)
{
    var game_state = is_undefined(_game_state)
        ? game_state_read()
        : _game_state;
    return game_state.quest_statuses[_quest_id];
}

function quest_get_status_text(_quest_id, _game_state = undefined)
{
    switch (quest_get_status(_quest_id, _game_state))
    {
        case QuestStatus.LOCKED: return "Not Started";
        case QuestStatus.ACTIVE: return "In Progress";
        case QuestStatus.COMPLETE: return "Complete";
    }

    return "Unknown";
}

function quest_get_objectives(_quest_id, _game_state = undefined)
{
    var game_state = is_undefined(_game_state)
        ? game_state_read()
        : _game_state;

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

function quest_get_current_objective(_quest_id, _game_state = undefined)
{
    var objectives = quest_get_objectives(_quest_id, _game_state);

    for (var i = 0; i < array_length(objectives); i++)
    {
        if (!objectives[i].complete)
        {
            return objectives[i].text;
        }
    }

    return "All objectives complete";
}
