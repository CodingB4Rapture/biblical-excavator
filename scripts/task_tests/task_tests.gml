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
        && array_length(wife_handoff_response.pages) == 4
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
        ) == 4,
        "parking, site marking, boundary work, and cabin building share the homestead quest"
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

    var production_state = game_state_create_default();
    production_state.task_board_unlocked = true;
    production_state.cabin_site_placed = true;
    production_state.task_statuses[TaskId.BUILD_CABIN_FENCE] =
        TaskStatus.ACTIVE;
    inventory_add(
        production_state.home_inventory,
        ResourceId.TIMBER_LOG,
        1
    );
    global.game_state = production_state;
    var planks_started = production_start_job(
        PRODUCTION_MACHINE_SAWMILL,
        ProductionRecipeId.SAW_TIMBER_PLANKS,
        1
    );
    production_finish_all_jobs();
    production_state = game_state_ensure();
    var straight_started = production_start_job(
        PRODUCTION_MACHINE_SAWMILL,
        ProductionRecipeId.CUT_STRAIGHT_FENCE,
        2
    );
    production_finish_all_jobs();
    production_state = game_state_ensure();
    var corner_started_then_cancelled = production_start_job(
        PRODUCTION_MACHINE_SAWMILL,
        ProductionRecipeId.CUT_FENCE_CORNERS,
        1
    ) && production_cancel_job(PRODUCTION_MACHINE_SAWMILL);
    production_state = game_state_ensure();
    passed = task_test_expect(
        planks_started
        && straight_started
        && corner_started_then_cancelled
        && inventory_get_amount(
            production_state.home_inventory,
            ResourceId.TIMBER_PLANK
        ) == 2
        && inventory_get_amount(
            production_state.finished_crafts_inventory,
            ResourceId.FENCE_STRAIGHT
        ) == 10
        && production_state.production_completed_batches[
            ProductionRecipeId.SAW_TIMBER_PLANKS
        ] == 1
        && production_state.production_completed_batches[
            ProductionRecipeId.CUT_STRAIGHT_FENCE
        ] == 2,
        "machine jobs reserve inputs, finish batches, deliver output, and refund cancelled work"
    ) && passed;

    var recovery_state = game_state_create_default();
    recovery_state.cabin_site_placed = true;
    recovery_state.task_statuses[TaskId.BUILD_CABIN_FENCE] =
        TaskStatus.ACTIVE;
    recovery_state.production_completed_batches[
        ProductionRecipeId.SAW_TIMBER_PLANKS
    ] = 1;
    recovery_state.production_completed_batches[
        ProductionRecipeId.CUT_STRAIGHT_FENCE
    ] = 2;
    recovery_state.production_completed_batches[
        ProductionRecipeId.CUT_FENCE_CORNERS
    ] = 1;
    recovery_state.production_completed_batches[
        ProductionRecipeId.CUT_FENCE_GATE
    ] = 1;
    inventory_add(
        recovery_state.home_inventory,
        ResourceId.TIMBER_LOG,
        1
    );
    var recovery_target =
        production_tutorial_recipe_target(recovery_state);
    passed = task_test_expect(
        !is_undefined(recovery_target)
        && recovery_target.recipe_id
            == ProductionRecipeId.SAW_TIMBER_PLANKS
        && recovery_target.batches == 1
        && production_recipe_max_batches(
            ProductionRecipeId.SAW_TIMBER_PLANKS,
            recovery_state
        ) == 1,
        "missing physical fence pieces permit one recovery log despite historical batch counters"
    ) && passed;

    production_state.cabin_built = true;
    inventory_add(
        production_state.home_inventory,
        ResourceId.SMALL_LUMBER,
        1
    );
    global.game_state = production_state;
    var bucket_started = production_start_job(
        PRODUCTION_MACHINE_LATHE,
        ProductionRecipeId.TURN_EMPTY_BUCKET,
        1
    );
    production_finish_all_jobs();
    production_state = game_state_ensure();
    passed = task_test_expect(
        bucket_started
        && inventory_get_amount(
            production_state.finished_crafts_inventory,
            ResourceId.EMPTY_BUCKET
        ) == 1,
        "the late-tutorial lathe hook turns Small Lumber into an Empty Bucket"
    ) && passed;

    var saved_machine_state = game_state_create_default();
    saved_machine_state.cabin_site_placed = true;
    saved_machine_state.task_statuses[TaskId.BUILD_CABIN_FENCE] =
        TaskStatus.ACTIVE;
    inventory_add(
        saved_machine_state.home_inventory,
        ResourceId.TIMBER_LOG,
        1
    );
    global.game_state = saved_machine_state;
    var saved_job_started = production_start_job(
        PRODUCTION_MACHINE_SAWMILL,
        ProductionRecipeId.SAW_TIMBER_PLANKS,
        1
    );
    saved_machine_state = game_state_ensure();
    var saved_job_index = production_state_find_job_index(
        saved_machine_state,
        PRODUCTION_MACHINE_SAWMILL
    );
    var saved_job = saved_machine_state.production_jobs[
        saved_job_index
    ];
    saved_job.seconds_remaining = 4.5;
    production_state_set_job(
        saved_machine_state,
        saved_job_index,
        saved_job
    );
    var hydrated_machine_state = save_hydrate_game_state(
        json_parse(json_stringify({
            production_jobs: save_clone_array(
                saved_machine_state.production_jobs
            ),
            production_completed_batches: save_clone_array(
                saved_machine_state.production_completed_batches
            )
        }))
    );
    var hydrated_job = production_job_get(
        PRODUCTION_MACHINE_SAWMILL,
        hydrated_machine_state
    );
    passed = task_test_expect(
        saved_job_started
        && production_job_is_active(hydrated_job)
        && hydrated_job.recipe_id
            == ProductionRecipeId.SAW_TIMBER_PLANKS
        && hydrated_job.batch_total == 1
        && abs(hydrated_job.seconds_remaining - 4.5) < 0.01,
        "an active machine batch survives JSON hydration"
    ) && passed;

    var chest_state = game_state_create_default();
    var chest_locked_before_cabin_task =
        !finished_crafts_is_available(chest_state);
    chest_state.task_statuses[TaskId.BUILD_CABIN_FENCE] =
        TaskStatus.ACTIVE;
    inventory_add(
        chest_state.finished_crafts_inventory,
        ResourceId.FENCE_STRAIGHT,
        5
    );
    var chest_pieces_moved = finished_crafts_take(
        chest_state,
        ResourceId.FENCE_STRAIGHT,
        5
    );
    passed = task_test_expect(
        chest_locked_before_cabin_task
        && finished_crafts_is_available(chest_state)
        && chest_pieces_moved == 5
        && inventory_get_amount(
            chest_state.finished_crafts_inventory,
            ResourceId.FENCE_STRAIGHT
        ) == 0
        && inventory_get_amount(
            chest_state.player_inventory,
            ResourceId.FENCE_STRAIGHT
        ) == 5,
        "finished crafts stay reserved until workshop work, then transfer once"
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
            ResourceId.FENCE_STRAIGHT
        ) == 0
        && inventory_get_amount(
            hydrated_chest_state.player_inventory,
            ResourceId.FENCE_STRAIGHT
        ) == 5
        && inventory_get_resource_capacity(
            hydrated_chest_state.player_inventory,
            ResourceId.TIMBER_PLANK
        ) == PLAYER_TIMBER_PLANK_CAPACITY + 2,
        "chest stock, carried crafts, and future capacity upgrades survive JSON hydration"
    ) && passed;

    var additive_save_state = save_hydrate_game_state({});
    passed = task_test_expect(
        inventory_get_amount(
            additive_save_state.finished_crafts_inventory,
            ResourceId.TIMBER_PLANK
        ) == 0
        && inventory_get_resource_capacity(
            additive_save_state.player_inventory,
            ResourceId.FIELDSTONE
        ) == PLAYER_FIELDSTONE_CAPACITY
        && inventory_get_resource_capacity(
            additive_save_state.player_inventory,
            ResourceId.TIMBER_PLANK
        ) == PLAYER_TIMBER_PLANK_CAPACITY,
        "additive hydration creates empty production stock and per-item limits"
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

    var v3_task_statuses = array_create(8, TaskStatus.LOCKED);
    v3_task_statuses[TaskId.MARK_CABIN_SITE] = TaskStatus.CLAIMED;
    v3_task_statuses[TaskId.PLACE_CABIN] = TaskStatus.AVAILABLE;
    var v3_player_inventory = array_create(5, 0);
    var v3_finished_inventory = array_create(5, 0);
    v3_player_inventory[ResourceId.TIMBER_PLANK] = 2;
    v3_finished_inventory[ResourceId.TIMBER_PLANK] = 4;
    var migrated_v3 = save_migrate_to_current({
        format_version: 3,
        game_state: {
            task_statuses: v3_task_statuses,
            cabin_built: false,
            player_inventory: v3_player_inventory,
            finished_crafts_inventory: v3_finished_inventory
        },
        scene: {},
        settings: {}
    });
    passed = task_test_expect(
        migrated_v3.format_version == SAVE_FORMAT_CURRENT
        && migrated_v3.game_state.task_statuses[
            TaskId.BUILD_CABIN_FENCE
        ] == TaskStatus.AVAILABLE
        && migrated_v3.game_state.task_statuses[TaskId.PLACE_CABIN]
            == TaskStatus.LOCKED
        && migrated_v3.game_state.player_inventory[
            ResourceId.TIMBER_PLANK
        ] == 0
        && migrated_v3.game_state.finished_crafts_inventory[
            ResourceId.TIMBER_PLANK
        ] == 0
        && array_length(migrated_v3.game_state.production_jobs) == 2,
        "v3 cabin progress migrates to the workshop boundary without seeded planks"
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
    var story_site = cabin_site_definition(CABIN_SITE_EIRENEIKOS);
    var site_chosen = progression_choose_cabin_site_state(
        story_state,
        story_site,
        0
    );
    var fence_waited_for_building = !story_state.cabin_fence_marked;
    var marking_claimed = progression_claim_task_state(
        TaskId.MARK_CABIN_SITE,
        story_state
    );
    var boundary_accepted = progression_accept_task_state(
        TaskId.BUILD_CABIN_FENCE,
        story_state
    );
    var chest_available_for_cabin_task =
        finished_crafts_is_available(story_state);
    var cabin_blocked_before_boundary =
        !progression_accept_task_state(
            TaskId.PLACE_CABIN,
            story_state
        );
    var boundary_completed =
        progression_complete_cabin_fence_state(story_state);
    var boundary_claimed = progression_claim_task_state(
        TaskId.BUILD_CABIN_FENCE,
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
        && site_chosen
        && fence_waited_for_building
        && marking_claimed
        && boundary_accepted
        && cabin_accepted
        && chest_available_for_cabin_task
        && cabin_blocked_before_boundary
        && boundary_completed
        && boundary_claimed
        && cabin_completed
        && cabin_claimed
        && story_state.free_build_unlocked
        && story_state.quest_statuses[QuestId.FIRM_FOUNDATION]
            == QuestStatus.COMPLETE
        && story_state.quest_statuses[QuestId.PLACE_OF_YOUR_OWN]
            == QuestStatus.COMPLETE,
        "task claims bridge parking, marking, and construction"
    ) && passed;

    var cabin_sites = cabin_site_definitions();
    var northwest_site = cabin_sites[0];
    var workfield_site = cabin_sites[1];
    var recorded_save_state = game_state_create_default();
    recorded_save_state.cabin_placement_unlocked = true;
    recorded_save_state.skidsteer_parked = true;
    recorded_save_state.task_statuses[TaskId.MARK_CABIN_SITE] =
        TaskStatus.ACTIVE;
    var recorded_save_site_chosen = progression_choose_cabin_site_state(
        recorded_save_state,
        northwest_site,
        2
    );
    passed = task_test_expect(
        recorded_save_site_chosen
        && recorded_save_state.task_statuses[TaskId.MARK_CABIN_SITE]
            == TaskStatus.COMPLETE
        && recorded_save_state.cabin_site_placed
        && recorded_save_state.cabin_selected_site_id
            == northwest_site.id
        && recorded_save_state.cabin_site_x == northwest_site.x
        && recorded_save_state.cabin_site_y == northwest_site.y
        && cabin_site_flag_count_taken(recorded_save_state) == 1
        && !recorded_save_state.cabin_fence_marked
        && !recorded_save_state.cabin_built,
        "the recorded active-task save chooses Site I atomically"
    ) && passed;
    var northwest_bounds = cabin_fence_plot_bounds_at(
        northwest_site.x,
        northwest_site.y
    );
    var workfield_bounds = cabin_fence_plot_bounds_at(
        workfield_site.x,
        workfield_site.y
    );
    var site_state = game_state_create_default();
    site_state.cabin_placement_unlocked = true;
    site_state.task_statuses[TaskId.MARK_CABIN_SITE] =
        TaskStatus.ACTIVE;
    var took_site_flag = progression_choose_cabin_site_state(
        site_state,
        northwest_site,
        0
    );
    var rejected_other_site_flag = !progression_choose_cabin_site_state(
        site_state,
        workfield_site,
        0
    );
    site_state.cabin_fence_marked = true;
    var hydrated_site_state = save_hydrate_game_state(
        json_parse(json_stringify(site_state))
    );
    passed = task_test_expect(
        array_length(cabin_sites) == 2
        && northwest_site.id != workfield_site.id
        && northwest_site.room_name == "Room1"
        && workfield_site.room_name == "Room1",
        "predefined cabin sites keep distinct authored IDs"
    ) && passed;
    passed = task_test_expect(
        northwest_bounds.min_x == 48
        && northwest_bounds.max_x == 176
        && northwest_bounds.min_y == 80
        && northwest_bounds.max_y == 208
        && workfield_bounds.min_x == 656
        && workfield_bounds.max_x == 784
        && workfield_bounds.min_y == 528
        && workfield_bounds.max_y == 656,
        "predefined cabin sites keep their fixed footprints"
    ) && passed;
    passed = task_test_expect(
        took_site_flag
        && rejected_other_site_flag
        && cabin_site_flag_is_taken(
            northwest_site.id,
            0,
            site_state
        )
        && !cabin_site_flag_is_taken(
            workfield_site.id,
            0,
            site_state
        )
        && cabin_site_flag_count_taken(site_state) == 1
        && site_state.task_statuses[TaskId.MARK_CABIN_SITE]
            == TaskStatus.COMPLETE,
        "taking one flag atomically commits the selected site"
    ) && passed;

    var partial_site_state = game_state_create_default();
    partial_site_state.cabin_placement_unlocked = true;
    partial_site_state.cabin_site_placed = true;
    partial_site_state.cabin_site_room = northwest_site.room_name;
    partial_site_state.cabin_site_x = northwest_site.x;
    partial_site_state.cabin_site_y = northwest_site.y;
    partial_site_state.cabin_selected_site_id = northwest_site.id;
    partial_site_state.cabin_site_flags_taken = 0;
    partial_site_state.task_statuses[TaskId.MARK_CABIN_SITE] =
        TaskStatus.ACTIVE;
    var partial_site_repaired =
        progression_repair_cabin_site_selection_state(
            partial_site_state
        );
    passed = task_test_expect(
        partial_site_repaired
        && partial_site_state.task_statuses[TaskId.MARK_CABIN_SITE]
            == TaskStatus.COMPLETE
        && cabin_site_flag_count_taken(partial_site_state) == 1,
        "the v4 half-selected flag save repairs to one completed site choice"
    ) && passed;

    passed = task_test_expect(
        hydrated_site_state.cabin_selected_site_id == northwest_site.id
        && hydrated_site_state.cabin_site_room == northwest_site.room_name
        && hydrated_site_state.cabin_site_x == northwest_site.x
        && hydrated_site_state.cabin_site_y == northwest_site.y
        && hydrated_site_state.cabin_site_flags_taken
            == site_state.cabin_site_flags_taken
        && hydrated_site_state.cabin_fence_marked,
        "selected cabin site and construction progress survive JSON hydration"
    ) && passed;
    passed = task_test_expect(
        world_area_id_at_position("Room1", 112, 144)
            == WORLD_AREA_EIRENEIKOS
        && world_area_id_at_position("Room1", 96, 640)
            == WORLD_AREA_POND_FOREST
        && world_area_id_at_position("Room1", 576, 320)
            == WORLD_AREA_WORKFIELD
        && world_area_id_at_position("Room1", 576, 80)
            == WORLD_AREA_FARMYARD
        && world_area_id_at_position("Room1", 1088, 640)
            == WORLD_AREA_MINEFIELD
        && world_area_id_at_position("Room1", 1184, 240)
            == WORLD_AREA_HOMESTEAD,
        "Room1 landmarks resolve to stable area IDs"
    ) && passed;

    var relocated_site_state = game_state_create_default();
    relocated_site_state.cabin_site_placed = true;
    relocated_site_state.cabin_site_room = workfield_site.room_name;
    relocated_site_state.cabin_site_x = 400;
    relocated_site_state.cabin_site_y = 464;
    relocated_site_state.cabin_selected_site_id = workfield_site.id;
    relocated_site_state.fence_records = [
        fence_record_create(
            workfield_site.room_name,
            336,
            400,
            FenceGatePart.NONE,
            FENCE_PURPOSE_CABIN_SITE
        )
    ];
    game_state_normalize(relocated_site_state);
    passed = task_test_expect(
        relocated_site_state.cabin_site_x == workfield_site.x
        && relocated_site_state.cabin_site_y == workfield_site.y
        && relocated_site_state.fence_records[0].x == 656
        && relocated_site_state.fence_records[0].y == 528,
        "authored site movement keeps saved cabin fencing aligned"
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
