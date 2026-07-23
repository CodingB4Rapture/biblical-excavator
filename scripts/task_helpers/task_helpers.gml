/// Task definitions, structural state validation, rewards, and read models.
///
/// Runtime task/tutorial/quest transitions are owned by progression_helpers.

function task_get_definition(_task_id)
{
    switch (_task_id)
    {
        case TaskId.FIELDSTONE_BY_HAND:
            return {
                quest_id: QuestId.FIRM_FOUNDATION,
                title: "Fieldstone by Hand",
                summary: "Gather the first six loose Fieldstones without the work vehicle.",
                completion_summary: "Six loose Fieldstones were gathered and the axe became available.",
                reward_labels: ["Axe"],
                rewards: []
            };

        case TaskId.FALLEN_TREE:
            return {
                quest_id: QuestId.FIRM_FOUNDATION,
                title: "A Fallen Tree",
                summary: "Use the axe on a standing tree, then inspect the trunk and stump.",
                completion_summary: "The tree was felled and its heavy trunk and stump were inspected.",
                reward_labels: ["Access to Skidsteer"],
                rewards: []
            };

        case TaskId.STONE_HAUL:
            return {
                quest_id: QuestId.FIRM_FOUNDATION,
                title: "Stone Haul",
                summary: "Crush ten Fieldrocks with the skidsteer and deliver all sixteen Fieldstones.",
                completion_summary: "All sixteen foundation stones reached Home Delivery.",
                reward_labels: ["Winch attachment delivery"],
                rewards: []
            };

        case TaskId.FIT_THE_WINCH:
            return {
                quest_id: QuestId.FIRM_FOUNDATION,
                title: "Fit the Winch",
                summary: "Collect the delivered attachment and install it on the skidsteer.",
                completion_summary: "The skidsteer was fitted with a working winch.",
                reward_labels: ["Access to Skidsteer"],
                rewards: []
            };

        case TaskId.TIMBER_DELIVERY:
            return {
                quest_id: QuestId.FIRM_FOUNDATION,
                title: "Timber Delivery",
                summary: "Use the winch to bring both the log and stump to Home Delivery.",
                completion_summary: "The log and stump were recovered as Timber Log and Small Lumber.",
                reward_labels: ["Cabin Site Plan"],
                rewards: []
            };

        case TaskId.PLACE_CABIN:
            return {
                quest_id: QuestId.PLACE_OF_YOUR_OWN,
                title: "Build the Cabin",
                summary: "Raise the cabin on the site you enclosed and prepared.",
                completion_summary: "The marked site became a finished cabin and a place of your own.",
                reward_labels: ["Homestead Cabin", "First Morning Unlocked"],
                rewards: []
            };

        case TaskId.PARK_SKIDSTEER:
            return {
                quest_id: QuestId.PLACE_OF_YOUR_OWN,
                title: "Park the Skidsteer",
                summary: "Return the skidsteer to the marked pad beside the Farmer, stop, and hop out.",
                completion_summary: "The skidsteer was returned safely to its place beside the Farmer.",
                reward_labels: ["Cabin Site Survey"],
                rewards: []
            };

        case TaskId.MARK_CABIN_SITE:
            return {
                quest_id: QuestId.PLACE_OF_YOUR_OWN,
                title: "Mark the Cabin Site",
                summary: "Choose the cabin stakes, then enclose the assigned plot with one front gate.",
                completion_summary: "A bounded cabin plot and front yard were enclosed with one gate.",
                reward_labels: ["Cabin Construction"],
                rewards: []
            };
    }

    return {
        quest_id: QuestId.FIRM_FOUNDATION,
        title: "Unknown Task",
        summary: "No task details are available.",
        completion_summary: "No completion details are available.",
        reward_labels: [],
        rewards: []
    };
}

function task_get_story_order()
{
    // Persisted TaskId values are append-only, so presentation order is an
    // explicit read model rather than numeric enum order.
    return [
        TaskId.FIELDSTONE_BY_HAND,
        TaskId.FALLEN_TREE,
        TaskId.STONE_HAUL,
        TaskId.FIT_THE_WINCH,
        TaskId.TIMBER_DELIVERY,
        TaskId.PARK_SKIDSTEER,
        TaskId.MARK_CABIN_SITE,
        TaskId.PLACE_CABIN
    ];
}

function task_order_index_of(_task_id, _order = undefined)
{
    var order = is_undefined(_order) ? task_get_story_order() : _order;

    for (var index = 0; index < array_length(order); index++)
    {
        if (order[index] == _task_id) return index;
    }

    return -1;
}

function task_get_ids_for_quest(_quest_id)
{
    var result = [];
    var order = task_get_story_order();

    for (var order_index = 0;
        order_index < array_length(order);
        order_index++)
    {
        var task_id = order[order_index];
        if (task_get_definition(task_id).quest_id == _quest_id)
            array_push(result, task_id);
    }

    return result;
}

function task_status_is_valid(_status)
{
    return _status == TaskStatus.LOCKED
        || _status == TaskStatus.AVAILABLE
        || _status == TaskStatus.ACTIVE
        || _status == TaskStatus.COMPLETE
        || _status == TaskStatus.CLAIMED;
}

/// Compatibility name for callers and old tests. Never compare stage numbers.
function task_tutorial_rank(_game_state)
{
    return tutorial_stage_rank(_game_state.tutorial_stage);
}

function task_board_should_be_unlocked(_game_state)
{
    return _game_state.tutorial_board_assignment_pending
        || tutorial_stage_rank(_game_state.tutorial_stage) >= 2;
}

function task_state_ensure(_game_state)
{
    if (!variable_struct_exists(_game_state, "task_board_unlocked"))
        _game_state.task_board_unlocked = false;

    if (_game_state.tutorial_board_assignment_pending)
        _game_state.task_board_unlocked = true;

    if (!variable_struct_exists(_game_state, "task_statuses")
    || !is_array(_game_state.task_statuses))
    {
        _game_state.task_statuses =
            array_create(TaskId.COUNT, TaskStatus.LOCKED);
    }

    while (array_length(_game_state.task_statuses) < TaskId.COUNT)
        array_push(_game_state.task_statuses, TaskStatus.LOCKED);

    for (var task_id = 0; task_id < TaskId.COUNT; task_id++)
    {
        if (!task_status_is_valid(_game_state.task_statuses[task_id]))
            _game_state.task_statuses[task_id] = TaskStatus.LOCKED;
    }

    return _game_state;
}

function task_legacy_current_id(_game_state)
{
    var rank = tutorial_stage_rank(_game_state.tutorial_stage);

    if (_game_state.tutorial_board_assignment_pending)
        return TaskId.FIELDSTONE_BY_HAND;
    if (rank == 2) return TaskId.FIELDSTONE_BY_HAND;
    if (rank >= 3 && rank <= 4) return TaskId.FALLEN_TREE;
    if (rank == 5) return TaskId.STONE_HAUL;
    if (rank >= 6 && rank <= 7) return TaskId.FIT_THE_WINCH;
    if (rank >= 8 && rank <= 12) return TaskId.TIMBER_DELIVERY;
    if (rank >= 13 && !_game_state.cabin_built)
        return TaskId.PARK_SKIDSTEER;

    return -1;
}

/// One-time compatibility derivation. Runtime accessors never call this.
function task_state_migrate_from_tutorial(_game_state)
{
    _game_state.task_board_unlocked =
        task_board_should_be_unlocked(_game_state);
    _game_state.task_statuses =
        array_create(TaskId.COUNT, TaskStatus.LOCKED);

    var current_task = task_legacy_current_id(_game_state);
    if (current_task < 0)
    {
        if (_game_state.cabin_site_placed)
        {
            for (var completed_id = 0;
                completed_id < TaskId.COUNT;
                completed_id++)
            {
                _game_state.task_statuses[completed_id] = TaskStatus.CLAIMED;
            }
            _game_state.task_board_unlocked = true;
        }
        return _game_state;
    }

    _game_state.task_board_unlocked = true;
    var story_order = task_get_story_order();
    var current_order_index = task_order_index_of(current_task, story_order);
    for (var prior_index = 0;
        prior_index < current_order_index;
        prior_index++)
    {
        _game_state.task_statuses[story_order[prior_index]] =
            TaskStatus.CLAIMED;
    }

    _game_state.task_statuses[current_task] =
        _game_state.tutorial_board_assignment_pending
            ? TaskStatus.AVAILABLE
            : TaskStatus.ACTIVE;
    return _game_state;
}

function task_state_restore_from_saved(
    _game_state,
    _saved_state
)
{
    if (!variable_struct_exists(_saved_state, "task_board_unlocked")
    || !variable_struct_exists(_saved_state, "task_statuses")
    || !is_array(_saved_state.task_statuses))
    {
        return task_state_migrate_from_tutorial(_game_state);
    }

    _game_state.task_board_unlocked = _saved_state.task_board_unlocked;
    _game_state.task_statuses = save_clone_array(_saved_state.task_statuses);
    return task_state_ensure(_game_state);
}

function task_get_status(_task_id)
{
    var game_state = game_state_ensure();
    if (_task_id < 0 || _task_id >= TaskId.COUNT)
        return TaskStatus.LOCKED;
    return game_state.task_statuses[_task_id];
}

function task_get_status_text(_task_id)
{
    switch (task_get_status(_task_id))
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
        ? game_state_ensure()
        : task_state_ensure(_game_state);

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

function task_get_attention_id(_game_state = undefined)
{
    var game_state = is_undefined(_game_state)
        ? game_state_ensure()
        : task_state_ensure(_game_state);

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

function task_reward_equipment_xp(_amount, _label)
{
    return {
        type: TaskRewardType.EQUIPMENT_XP,
        amount: max(0, floor(_amount)),
        label: _label
    };
}

function task_reward_home_resource(_resource_id, _amount, _label)
{
    return {
        type: TaskRewardType.HOME_RESOURCE,
        resource_id: _resource_id,
        amount: max(0, floor(_amount)),
        label: _label
    };
}

function task_reward_is_valid(_reward)
{
    if (!is_struct(_reward)
    || !variable_struct_exists(_reward, "type")
    || !variable_struct_exists(_reward, "amount")
    || !is_real(_reward.amount)
    || _reward.amount < 0)
    {
        return false;
    }

    switch (_reward.type)
    {
        case TaskRewardType.EQUIPMENT_XP:
            return true;

        case TaskRewardType.HOME_RESOURCE:
            return variable_struct_exists(_reward, "resource_id")
                && _reward.resource_id >= 0
                && _reward.resource_id < ResourceId.COUNT;
    }

    return false;
}

function task_apply_reward(_reward, _game_state)
{
    if (!task_reward_is_valid(_reward)) return false;

    switch (_reward.type)
    {
        case TaskRewardType.EQUIPMENT_XP:
            _game_state.equipment_xp += _reward.amount;
            return true;

        case TaskRewardType.HOME_RESOURCE:
            inventory_add(
                _game_state.home_inventory,
                _reward.resource_id,
                _reward.amount
            );
            return true;
    }

    return false;
}

function task_apply_rewards_atomically(_rewards, _game_state)
{
    if (!is_array(_rewards)) return false;

    for (var validation_index = 0;
        validation_index < array_length(_rewards);
        validation_index++)
    {
        if (!task_reward_is_valid(_rewards[validation_index]))
            return false;
    }

    for (var apply_index = 0;
        apply_index < array_length(_rewards);
        apply_index++)
    {
        task_apply_reward(_rewards[apply_index], _game_state);
    }

    return true;
}

function task_get_objectives(_task_id)
{
    var game_state = game_state_ensure();
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
            return [{
                text: "Build the cabin on the prepared site",
                complete: task_finished || game_state.cabin_built
            }];

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

function task_get_preferred_selection()
{
    var game_state = game_state_ensure();
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

function task_test_expect(_condition, _message)
{
    if (_condition)
    {
        show_debug_message("TASK TEST PASS: " + _message);
        return true;
    }

    show_debug_message("TASK TEST FAIL: " + _message);
    return false;
}

function task_run_tests()
{
    var passed = true;
    var original_state = variable_global_exists("game_state")
        ? global.game_state
        : undefined;

    var legacy_state = game_state_create_default();
    legacy_state.tutorial_stage = TutorialStage.CHOP_TREE;
    legacy_state.tools.axe_owned = true;
    task_state_migrate_from_tutorial(legacy_state);
    passed = task_test_expect(
        legacy_state.task_statuses[TaskId.FIELDSTONE_BY_HAND]
            == TaskStatus.CLAIMED
        && legacy_state.task_statuses[TaskId.FALLEN_TREE]
            == TaskStatus.ACTIVE,
        "v1 tutorial progress becomes one active task without retro rewards"
    ) && passed;

    passed = task_test_expect(
        array_length(task_get_ids_for_quest(QuestId.FIRM_FOUNDATION)) == 5
        && array_length(
            task_get_ids_for_quest(QuestId.PLACE_OF_YOUR_OWN)
        ) == 3,
        "parking, site marking, and cabin building share the homestead quest"
    ) && passed;

    global.game_state = game_state_create_default();
    global.game_state.tutorial_stage = TutorialStage.TALK_TO_FARMERS_WIFE;
    var handoff_started = task_board_begin_first_assignment();
    passed = task_test_expect(
        handoff_started
        && global.game_state.tutorial_board_assignment_pending
        && global.game_state.task_statuses[TaskId.FIELDSTONE_BY_HAND]
            == TaskStatus.AVAILABLE,
        "wife handoff posts but does not start the first task"
    ) && passed;

    passed = task_test_expect(
        progression_accept_task_state(
            TaskId.FIELDSTONE_BY_HAND,
            global.game_state
        )
        && task_is_active(
            TaskId.FIELDSTONE_BY_HAND,
            global.game_state
        )
        && global.game_state.tutorial_stage
            == TutorialStage.TRIP_ONE_HAND_FIELDSTONE,
        "acceptance gates and starts the first task"
    ) && passed;

    global.game_state.task_statuses[TaskId.FALLEN_TREE] =
        TaskStatus.AVAILABLE;
    passed = task_test_expect(
        !progression_accept_task_state(
            TaskId.FALLEN_TREE,
            global.game_state
        ),
        "a second task cannot start while one is active"
    ) && passed;

    var reward_state = game_state_create_default();
    var xp_before = reward_state.equipment_xp;
    var invalid_rewards = [
        task_reward_equipment_xp(7, "Test XP"),
        { type: 999, amount: 2, label: "Invalid" }
    ];
    passed = task_test_expect(
        !task_apply_rewards_atomically(invalid_rewards, reward_state)
        && reward_state.equipment_xp == xp_before,
        "an invalid multi-reward claim applies nothing"
    ) && passed;

    var right_edge_guidance = tutorial_guidance_gui_edge(
        200,
        50,
        100,
        100,
        10
    );
    passed = task_test_expect(
        !right_edge_guidance.visible
        && abs(right_edge_guidance.x - 90) < 0.01
        && abs(right_edge_guidance.y - 50) < 0.01,
        "off-camera guidance reaches the correct screen edge"
    ) && passed;

    var v1_data = {
        format_version: 1,
        game_state: {
            tutorial_stage: TutorialStage.CHOP_TREE,
            trip_rocks_gathered: 6,
            tutorial_fieldstones_collected: 6
        },
        scene: {},
        settings: {}
    };
    var migrated = save_migrate_to_current(v1_data);
    passed = task_test_expect(
        is_struct(migrated)
        && migrated.format_version == SAVE_FORMAT_CURRENT
        && variable_struct_exists(
            migrated.game_state,
            "tutorial_fieldrocks_crushed"
        )
        && dialogue_action_normalize("start_hand_gathering")
            == DIALOGUE_ACTION_POST_FIRST_TASK,
        "v1 data and saved dialogue actions normalize to the current format"
    ) && passed;

    var migration_fixtures = [
        {
            name: "Wife handoff",
            stage: TutorialStage.TALK_TO_FARMERS_WIFE,
            board_pending: true,
            attachment: AttachmentState.LOCKED,
            cabin_placed: false,
            expected_task: TaskId.FIELDSTONE_BY_HAND,
            expected_status: TaskStatus.AVAILABLE
        },
        {
            name: "active hand gathering",
            stage: TutorialStage.TRIP_ONE_HAND_FIELDSTONE,
            board_pending: false,
            attachment: AttachmentState.LOCKED,
            cabin_placed: false,
            expected_task: TaskId.FIELDSTONE_BY_HAND,
            expected_status: TaskStatus.ACTIVE
        },
        {
            name: "stored winch package",
            stage: TutorialStage.WINCH_PACKAGE_READY,
            board_pending: false,
            attachment: AttachmentState.STORED_AT_HOME,
            cabin_placed: false,
            expected_task: TaskId.FIT_THE_WINCH,
            expected_status: TaskStatus.ACTIVE
        },
        {
            name: "post-stump before cabin",
            stage: TutorialStage.COMPLETE,
            board_pending: false,
            attachment: AttachmentState.INSTALLED,
            cabin_placed: false,
            expected_task: TaskId.PARK_SKIDSTEER,
            expected_status: TaskStatus.ACTIVE
        }
    ];
    var migration_matrix_ok = true;
    for (var fixture_index = 0;
        fixture_index < array_length(migration_fixtures);
        fixture_index++)
    {
        var fixture = migration_fixtures[fixture_index];
        var fixture_data = {
            format_version: 1,
            game_state: {
                tutorial_stage: fixture.stage,
                tutorial_board_assignment_pending:
                    fixture.board_pending,
                winch_attachment_state: fixture.attachment,
                cabin_site_placed: fixture.cabin_placed
            },
            scene: {},
            settings: {}
        };
        var fixture_result = save_migrate_to_current(fixture_data);
        var active_count = 0;
        for (var migrated_task_id = 0;
            migrated_task_id < TaskId.COUNT;
            migrated_task_id++)
        {
            if (fixture_result.game_state.task_statuses[migrated_task_id]
                == TaskStatus.ACTIVE)
            {
                active_count += 1;
            }
        }

        migration_matrix_ok = migration_matrix_ok
            && fixture_result.game_state.task_statuses[
                fixture.expected_task
            ] == fixture.expected_status
            && active_count
                == (fixture.expected_status == TaskStatus.ACTIVE ? 1 : 0);
    }
    passed = task_test_expect(
        migration_matrix_ok,
        "v1 checkpoint matrix preserves one actionable task"
    ) && passed;

    var completed_v1 = {
        format_version: 1,
        game_state: {
            tutorial_stage: TutorialStage.COMPLETE,
            winch_attachment_state: AttachmentState.INSTALLED,
            cabin_site_placed: true
        },
        scene: {},
        settings: {}
    };
    completed_v1 = save_migrate_to_current(completed_v1);
    var completed_v1_ok =
        completed_v1.game_state.quest_statuses[
            QuestId.PLACE_OF_YOUR_OWN
        ] == QuestStatus.COMPLETE;
    for (var completed_task_id = 0;
        completed_task_id < TaskId.COUNT;
        completed_task_id++)
    {
        completed_v1_ok = completed_v1_ok
            && completed_v1.game_state.task_statuses[completed_task_id]
                == TaskStatus.CLAIMED;
    }
    passed = task_test_expect(
        completed_v1_ok,
        "post-cabin v1 progress remains fully complete"
    ) && passed;

    var story_state = game_state_create_default();
    story_state.task_board_unlocked = true;
    story_state.tutorial_stage = TutorialStage.COMPLETE;
    story_state.winch_attachment_state = AttachmentState.INSTALLED;
    story_state.quest_statuses[QuestId.FIRM_FOUNDATION] =
        QuestStatus.ACTIVE;
    for (var story_prior_id = 0;
        story_prior_id < TaskId.TIMBER_DELIVERY;
        story_prior_id++)
    {
        story_state.task_statuses[story_prior_id] =
            TaskStatus.CLAIMED;
    }
    story_state.task_statuses[TaskId.TIMBER_DELIVERY] =
        TaskStatus.COMPLETE;
    var timber_claimed = progression_claim_task_state(
        TaskId.TIMBER_DELIVERY,
        story_state
    );
    var parking_accepted = progression_accept_task_state(
        TaskId.PARK_SKIDSTEER,
        story_state
    );
    var parking_completed =
        progression_complete_skidsteer_parking_state(story_state);
    var parking_claimed = progression_claim_task_state(
        TaskId.PARK_SKIDSTEER,
        story_state
    );
    var marking_accepted = progression_accept_task_state(
        TaskId.MARK_CABIN_SITE,
        story_state
    );
    var site_recorded = progression_record_cabin_site_state(
        story_state,
        "Room1",
        400,
        300
    );
    var marking_completed =
        progression_complete_cabin_fence_state(story_state);
    var marking_claimed = progression_claim_task_state(
        TaskId.MARK_CABIN_SITE,
        story_state
    );
    var cabin_accepted = progression_accept_task_state(
        TaskId.PLACE_CABIN,
        story_state
    );
    var cabin_completed = progression_build_cabin_state(story_state);
    var cabin_claimed = progression_claim_task_state(
        TaskId.PLACE_CABIN,
        story_state
    );
    passed = task_test_expect(
        timber_claimed
        && parking_accepted
        && parking_completed
        && parking_claimed
        && marking_accepted
        && site_recorded
        && marking_completed
        && marking_claimed
        && cabin_accepted
        && cabin_completed
        && cabin_claimed
        && story_state.quest_statuses[QuestId.FIRM_FOUNDATION]
            == QuestStatus.COMPLETE
        && story_state.quest_statuses[QuestId.PLACE_OF_YOUR_OWN]
            == QuestStatus.COMPLETE,
        "task claims bridge parking, marking, and construction"
    ) && passed;

    var v2_state = game_state_create_default();
    v2_state.tutorial_stage = TutorialStage.COMPLETE;
    v2_state.task_board_unlocked = true;
    v2_state.task_statuses[TaskId.FIELDSTONE_BY_HAND] =
        TaskStatus.CLAIMED;
    v2_state.task_statuses[TaskId.FALLEN_TREE] =
        TaskStatus.AVAILABLE;
    var v2_round_trip = json_parse(json_stringify({
        format_version: SAVE_FORMAT_CURRENT,
        game_state: v2_state,
        scene: {},
        settings: {}
    }));
    v2_round_trip = save_migrate_to_current(v2_round_trip);
    var hydrated_v2 = save_hydrate_game_state(
        v2_round_trip.game_state
    );
    passed = task_test_expect(
        hydrated_v2.task_statuses[TaskId.FIELDSTONE_BY_HAND]
            == TaskStatus.CLAIMED
        && hydrated_v2.task_statuses[TaskId.FALLEN_TREE]
            == TaskStatus.AVAILABLE,
        "v2 JSON hydration preserves task state without continuous sync"
    ) && passed;

    var parking_pad = instance_create_depth(
        200,
        200,
        0,
        obj_skidsteer_parking_pad
    );
    var parking_vehicle = instance_create_depth(
        200,
        200,
        -1,
        obj_skidsteer
    );
    var centered_inside = skidsteer_parking_pad_contains(
        parking_pad,
        parking_vehicle
    );
    parking_vehicle.x = 260;
    var edge_outside = !skidsteer_parking_pad_contains(
        parking_pad,
        parking_vehicle
    );
    passed = task_test_expect(
        centered_inside
        && edge_outside
        && skidsteer_is_nearly_stopped(parking_vehicle)
        && skidsteer_has_no_tow_target(parking_vehicle),
        "parking requires the whole stopped skidsteer inside the pad with no tow"
    ) && passed;
    with (parking_vehicle) instance_destroy();
    with (parking_pad) instance_destroy();

    if (!is_undefined(original_state))
        global.game_state = original_state;

    show_debug_message(
        passed ? "TASK TEST RESULT: PASS" : "TASK TEST RESULT: FAIL"
    );
    return passed;
}
