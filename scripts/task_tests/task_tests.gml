/// Deterministic task, progression, migration, and save regression coverage.

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

    var wife_intro_state = game_state_create_default();
    var wife_intro_response = farmers_wife_get_response(
        noone,
        noone,
        wife_intro_state
    );
    passed = task_test_expect(
        array_length(wife_intro_response.pages) == 0
        && wife_intro_response.hint == "Speak with the Farmer first."
        && wife_intro_response.effect_id == FARMERS_WIFE_EFFECT_NONE,
        "wife intro response is read-only presentation data"
    ) && passed;

    wife_intro_state.tutorial_stage =
        TutorialStage.TALK_TO_FARMERS_WIFE;
    var wife_handoff_response = farmers_wife_get_response(
        noone,
        noone,
        wife_intro_state
    );
    passed = task_test_expect(
        is_array(wife_handoff_response.pages)
        && array_length(wife_handoff_response.pages) == 3
        && wife_handoff_response.completion_action
            == DIALOGUE_ACTION_POST_FIRST_TASK,
        "wife handoff response preserves its stable completion action"
    ) && passed;

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

    var capacity_state = game_state_create_default();
    var player_stones_added = inventory_add(
        capacity_state.player_inventory,
        ResourceId.FIELDSTONE,
        99
    );
    var player_planks_added = inventory_add(
        capacity_state.player_inventory,
        ResourceId.TIMBER_PLANK,
        99
    );
    var vehicle_capacity_test = inventory_create_vehicle();
    var vehicle_stones_added = inventory_add(
        vehicle_capacity_test,
        ResourceId.FIELDSTONE,
        99
    );
    passed = task_test_expect(
        player_stones_added == PLAYER_FIELDSTONE_CAPACITY
        && player_planks_added == PLAYER_TIMBER_PLANK_CAPACITY
        && inventory_get_amount(
            capacity_state.player_inventory,
            ResourceId.FIELDSTONE
        ) == PLAYER_FIELDSTONE_CAPACITY
        && inventory_get_amount(
            capacity_state.player_inventory,
            ResourceId.TIMBER_PLANK
        ) == PLAYER_TIMBER_PLANK_CAPACITY
        && vehicle_stones_added == VEHICLE_FIELDSTONE_CAPACITY,
        "player and vehicle enforce independent resource capacities"
    ) && passed;

    var chest_state = game_state_create_default();
    var chest_locked_before_cabin_task =
        !finished_crafts_is_available(chest_state);
    var chest_planks_moved = finished_crafts_take(
        chest_state,
        ResourceId.TIMBER_PLANK,
        CABIN_TIMBER_PLANK_COST
    );
    passed = task_test_expect(
        chest_locked_before_cabin_task
        && chest_planks_moved == CABIN_TIMBER_PLANK_COST
        && inventory_get_amount(
            chest_state.finished_crafts_inventory,
            ResourceId.TIMBER_PLANK
        ) == 0
        && inventory_get_amount(
            chest_state.player_inventory,
            ResourceId.TIMBER_PLANK
        ) == CABIN_TIMBER_PLANK_COST,
        "finished crafts stay reserved until cabin work, then transfer once"
    ) && passed;

    inventory_set_resource_capacity(
        chest_state.player_inventory,
        ResourceId.TIMBER_PLANK,
        PLAYER_TIMBER_PLANK_CAPACITY + 2
    );
    var chest_round_trip = json_parse(json_stringify({
        player_inventory: save_copy_amounts(
            chest_state.player_inventory
        ),
        player_resource_capacities: save_copy_resource_capacities(
            chest_state.player_inventory
        ),
        finished_crafts_inventory: save_copy_amounts(
            chest_state.finished_crafts_inventory
        )
    }));
    var hydrated_chest_state = save_hydrate_game_state(chest_round_trip);
    passed = task_test_expect(
        inventory_get_amount(
            hydrated_chest_state.finished_crafts_inventory,
            ResourceId.TIMBER_PLANK
        ) == 0
        && inventory_get_amount(
            hydrated_chest_state.player_inventory,
            ResourceId.TIMBER_PLANK
        ) == CABIN_TIMBER_PLANK_COST
        && inventory_get_resource_capacity(
            hydrated_chest_state.player_inventory,
            ResourceId.TIMBER_PLANK
        ) == PLAYER_TIMBER_PLANK_CAPACITY + 2,
        "chest stock, carried planks, and future capacity upgrades survive JSON hydration"
    ) && passed;

    var additive_save_state = save_hydrate_game_state({});
    passed = task_test_expect(
        inventory_get_amount(
            additive_save_state.finished_crafts_inventory,
            ResourceId.TIMBER_PLANK
        ) == CABIN_TIMBER_PLANK_COST
        && inventory_get_resource_capacity(
            additive_save_state.player_inventory,
            ResourceId.FIELDSTONE
        ) == PLAYER_FIELDSTONE_CAPACITY
        && inventory_get_resource_capacity(
            additive_save_state.player_inventory,
            ResourceId.TIMBER_PLANK
        ) == PLAYER_TIMBER_PLANK_CAPACITY,
        "older saves receive chest stock and the new per-item limits"
    ) && passed;

    var completed_additive_save_state = save_hydrate_game_state({
        cabin_built: true
    });
    passed = task_test_expect(
        inventory_get_amount(
            completed_additive_save_state.finished_crafts_inventory,
            ResourceId.TIMBER_PLANK
        ) == 0,
        "completed older saves do not receive duplicate cabin planks"
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
    var chest_available_for_cabin_task =
        finished_crafts_is_available(story_state);
    var cabin_blocked_without_planks =
        !progression_build_cabin_state(story_state);
    inventory_add(
        story_state.player_inventory,
        ResourceId.TIMBER_PLANK,
        CABIN_TIMBER_PLANK_COST
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
        && chest_available_for_cabin_task
        && cabin_blocked_without_planks
        && cabin_completed
        && cabin_claimed
        && inventory_get_amount(
            story_state.player_inventory,
            ResourceId.TIMBER_PLANK
        ) == 0
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
