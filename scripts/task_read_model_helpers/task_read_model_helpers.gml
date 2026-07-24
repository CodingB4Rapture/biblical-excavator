/// Read-only task status, objective, and board-selection models.

function task_board_should_be_unlocked(_game_state)
{
    return _game_state.tutorial_board_assignment_pending
        || tutorial_stage_rank(_game_state.tutorial_stage) >= 2;
}

function task_get_status(_task_id, _game_state = undefined)
{
    var game_state = is_undefined(_game_state)
        ? game_state_read()
        : _game_state;
    if (_task_id < 0 || _task_id >= TaskId.COUNT)
        return TaskStatus.LOCKED;
    return game_state.task_statuses[_task_id];
}

function task_get_status_text(_task_id, _game_state = undefined)
{
    switch (task_get_status(_task_id, _game_state))
    {
        case TaskStatus.LOCKED: return "Locked";
        case TaskStatus.AVAILABLE: return "Available";
        case TaskStatus.ACTIVE: return "Active";
        case TaskStatus.COMPLETE: return "Complete - Reward Ready";
        case TaskStatus.CLAIMED: return "Complete";
    }

    return "Unknown";
}

function task_get_active_id(_game_state = undefined)
{
    var game_state = is_undefined(_game_state)
        ? game_state_read()
        : _game_state;

    for (var task_id = 0; task_id < TaskId.COUNT; task_id++)
    {
        if (game_state.task_statuses[task_id] == TaskStatus.ACTIVE)
            return task_id;
    }

    return -1;
}

function task_is_active(_task_id, _game_state = undefined)
{
    return task_get_active_id(_game_state) == _task_id;
}

/// Finished cabin materials become interactable only during the cabin build.
function finished_crafts_is_available(_game_state = undefined)
{
    return task_is_active(TaskId.PLACE_CABIN, _game_state);
}

function task_get_attention_id(_game_state = undefined)
{
    var game_state = is_undefined(_game_state)
        ? game_state_read()
        : _game_state;

    for (var task_id = 0; task_id < TaskId.COUNT; task_id++)
    {
        if (game_state.task_statuses[task_id] == TaskStatus.COMPLETE)
            return task_id;
    }
    for (var available_id = 0;
        available_id < TaskId.COUNT;
        available_id++)
    {
        if (game_state.task_statuses[available_id] == TaskStatus.AVAILABLE)
            return available_id;
    }

    return -1;
}

function task_get_objectives(_task_id, _game_state = undefined)
{
    var game_state = is_undefined(_game_state)
        ? game_state_read()
        : _game_state;
    var rank = tutorial_stage_rank(game_state.tutorial_stage);
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
    var task_finished = game_state.task_statuses[_task_id]
        >= TaskStatus.COMPLETE;

    switch (_task_id)
    {
        case TaskId.FIELDSTONE_BY_HAND:
            return [{
                text: "Gather 6 loose Fieldstones by hand ("
                    + string(min(
                        6,
                        game_state.tutorial_fieldstones_collected
                    ))
                    + "/6)",
                complete: task_finished
                    || game_state.tutorial_fieldstones_collected >= 6
            }];

        case TaskId.FALLEN_TREE:
            return [
                {
                    text: "Use the axe on a standing tree",
                    complete: task_finished || rank >= 4
                },
                {
                    text: "Inspect the fallen trunk and stump",
                    complete: task_finished || rank >= 5
                }
            ];

        case TaskId.STONE_HAUL:
            return [
                {
                    text: "Crush 10 Fieldrocks with the skidsteer ("
                        + string(min(
                            10,
                            game_state.tutorial_fieldrocks_crushed
                        ))
                        + "/10)",
                    complete: task_finished
                        || game_state.tutorial_fieldrocks_crushed >= 10
                },
                {
                    text: "Deliver all 16 Fieldstones ("
                        + string(min(16, home_stones)) + "/16)",
                    complete: task_finished || home_stones >= 16
                }
            ];

        case TaskId.FIT_THE_WINCH:
            return [
                {
                    text: "Collect the winch package",
                    complete: task_finished
                        || game_state.winch_attachment_state
                            == AttachmentState.STORED_AT_HOME
                        || game_state.winch_attachment_state
                            == AttachmentState.INSTALLED
                },
                {
                    text: "Install the winch on the skidsteer",
                    complete: task_finished
                        || game_state.winch_attachment_state
                            == AttachmentState.INSTALLED
                }
            ];

        case TaskId.TIMBER_DELIVERY:
            return [
                {
                    text: "Deliver the Timber Log ("
                        + string(min(1, home_logs)) + "/1)",
                    complete: task_finished || home_logs >= 1
                },
                {
                    text: "Deliver the stump as Small Lumber ("
                        + string(min(1, home_small_lumber)) + "/1)",
                    complete: task_finished || home_small_lumber >= 1
                }
            ];

        case TaskId.PLACE_CABIN:
            var carried_planks = inventory_get_amount(
                game_state.player_inventory,
                ResourceId.TIMBER_PLANK
            );
            return [
                {
                    text: "Retrieve 4 Timber Planks from Finished Crafts ("
                        + string(min(
                            CABIN_TIMBER_PLANK_COST,
                            carried_planks
                        ))
                        + "/"
                        + string(CABIN_TIMBER_PLANK_COST)
                        + ")",
                    complete: task_finished
                        || game_state.cabin_built
                        || carried_planks >= CABIN_TIMBER_PLANK_COST
                },
                {
                    text: "Build the cabin on the prepared site",
                    complete: task_finished || game_state.cabin_built
                }
            ];

        case TaskId.PARK_SKIDSTEER:
            return [
                {
                    text: "Park fully inside the pad beside the Farmer",
                    complete: task_finished || game_state.skidsteer_parked
                },
                {
                    text: "Stop, detach any load, and exit the skidsteer",
                    complete: task_finished || game_state.skidsteer_parked
                }
            ];

        case TaskId.MARK_CABIN_SITE:
            return [
                {
                    text: "Choose a clear location for the cabin stakes",
                    complete: task_finished || game_state.cabin_site_placed
                },
                {
                    text: "Build the bounded fence with one front gate",
                    complete: task_finished || game_state.cabin_fence_marked
                }
            ];
    }

    return [];
}

function task_get_preferred_selection(_game_state = undefined)
{
    var game_state = is_undefined(_game_state)
        ? game_state_read()
        : _game_state;
    var active_id = task_get_active_id(game_state);
    if (active_id >= 0) return active_id;

    var attention_id = task_get_attention_id(game_state);
    if (attention_id >= 0) return attention_id;

    var order = task_get_story_order();
    for (var order_index = array_length(order) - 1;
        order_index >= 0;
        order_index--)
    {
        var task_id = order[order_index];
        if (game_state.task_statuses[task_id] == TaskStatus.CLAIMED)
            return task_id;
    }

    return 0;
}
