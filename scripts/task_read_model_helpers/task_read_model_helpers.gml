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

/// Finished crafts become interactable when production is part of the active
/// tutorial or after free building has been earned.
function finished_crafts_is_available(_game_state = undefined)
{
    var game_state = is_undefined(_game_state)
        ? game_state_read()
        : _game_state;
    return task_is_active(TaskId.BUILD_CABIN_FENCE, game_state)
        || game_state.free_build_unlocked
        || game_state.cabin_built;
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
            return [
                {
                    text: "Raise the cabin inside the finished boundary",
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
                    text: "Choose one predefined site and take one of its flags",
                    complete: task_finished || game_state.cabin_site_placed
                }
            ];

        case TaskId.BUILD_CABIN_FENCE:
            var blueprint = cabin_blueprint_status(game_state);
            var missing_straight =
                production_tutorial_missing_output(
                    ResourceId.FENCE_STRAIGHT,
                    game_state
                );
            var missing_corners =
                production_tutorial_missing_output(
                    ResourceId.FENCE_CORNER,
                    game_state
                );
            var missing_gate =
                production_tutorial_missing_output(
                    ResourceId.FENCE_GATE,
                    game_state
                );
            var finished_piece_count =
                production_tutorial_usable_piece_count(
                    game_state.finished_crafts_inventory,
                    game_state
                );
            var fence_crafting_started =
                game_state.production_completed_batches[
                    ProductionRecipeId.CUT_STRAIGHT_FENCE
                ] > 0
                || game_state.production_completed_batches[
                    ProductionRecipeId.CUT_FENCE_CORNERS
                ] > 0
                || game_state.production_completed_batches[
                    ProductionRecipeId.CUT_FENCE_GATE
                ] > 0
                || blueprint.filled > 0;
            return [
                {
                    text: "Saw 1 Timber Log into 4 Timber Planks",
                    complete: task_finished
                        || production_tutorial_recipe_remaining_batches(
                            ProductionRecipeId.SAW_TIMBER_PLANKS,
                            game_state
                        ) <= 0
                },
                {
                    text: "Collect the milled Timber Planks from the middle Finished Crafts chest",
                    complete: task_finished
                        || (
                            game_state.production_completed_batches[
                                ProductionRecipeId.SAW_TIMBER_PLANKS
                            ] > 0
                            && inventory_get_amount(
                                game_state.finished_crafts_inventory,
                                ResourceId.TIMBER_PLANK
                            ) <= 0
                        )
                },
                {
                    text: "Cut the remaining Straight Fence pieces ("
                        + string(max(0, 10 - missing_straight))
                        + "/10 covered)",
                    complete: task_finished || missing_straight <= 0
                },
                {
                    text: "Cut Fence Corners and the Fence Gate ("
                        + string(max(0, 4 - missing_corners))
                        + "/4 corners, "
                        + string(max(0, 1 - missing_gate))
                        + "/1 gate covered)",
                    complete: task_finished
                        || (missing_corners <= 0 && missing_gate <= 0)
                },
                {
                    text: "Collect completed fence pieces from the middle Finished Crafts chest",
                    complete: task_finished
                        || (
                            fence_crafting_started
                            && finished_piece_count <= 0
                        )
                },
                {
                    text: "Fill the cabin boundary silhouette ("
                        + string(blueprint.filled)
                        + "/"
                        + string(blueprint.total)
                        + ")",
                    complete: task_finished || blueprint.complete
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
