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

    var work_plan_rows = task_get_board_rows();
    var foundation_sections = task_get_work_sections_for_quest(
        QuestId.FIRM_FOUNDATION
    );
    var home_sections = task_get_work_sections_for_quest(
        QuestId.PLACE_OF_YOUR_OWN
    );
    passed = task_test_expect(
        array_length(work_plan_rows) == TaskId.COUNT
            + WORK_SECTION_COUNT
        && work_plan_rows[0].kind == "section"
        && work_plan_rows[1].task_id == TaskId.FIELDSTONE_BY_HAND
        && task_get_work_section_id(TaskId.FALLEN_TREE)
            == WORK_SECTION_KNOW_LAND
        && task_get_work_section_id(TaskId.TIMBER_DELIVERY)
            == WORK_SECTION_FOUNDATION
        && task_get_work_section_id(TaskId.PLACE_CABIN)
            == WORK_SECTION_HOME
        && array_length(foundation_sections) == 2
        && array_length(home_sections) == 1,
        "the work plan groups every task into three why-driven chapters"
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

    var unfinished_vehicle_cargo = save_copy_vehicle_cargo(id);
    passed = task_test_expect(
        array_length(unfinished_vehicle_cargo) == ResourceId.COUNT
        && unfinished_vehicle_cargo[ResourceId.FIELDSTONE] == 0,
        "startup snapshots tolerate a vehicle before its Create Event"
    ) && passed;

    var skill_curve_state = game_state_create_default();
    var heavy_result = skill_award_xp_state(
        skill_curve_state,
        SkillId.HEAVY_EQUIPMENT,
        100
    );
    var winch_unlock = skill_unlock_definition(
        SkillId.HEAVY_EQUIPMENT,
        SKILL_UNLOCK_UTILITY_VEHICLE_WINCH
    );
    var heavy_level_two_pages = skill_levelup_pages(
        SkillId.HEAVY_EQUIPMENT,
        2
    );
    var toolmanship_level_two_pages = skill_levelup_pages(
        SkillId.TOOLMANSHIP,
        2
    );
    var axe_choice_page = toolmanship_level_two_pages[1];
    var axe_choices = dialogue_page_choices(axe_choice_page);
    passed = task_test_expect(
        skill_xp_for_level(1) == 0
        && skill_xp_for_level(2) == 100
        && skill_xp_for_level(3) == 300
        && skill_xp_for_level(10) == 4500
        && skill_xp_for_level(50) == 122500
        && skill_level_from_xp(SkillId.TOOLMANSHIP, 99) == 1
        && skill_level_from_xp(SkillId.TOOLMANSHIP, 100) == 2
        && skill_level_from_xp(
            SkillId.TOOLMANSHIP,
            999999
        ) == SKILL_MASTERY_LEVEL_CAP
        && skill_definition(SkillId.TOOLMANSHIP).display_name
            == "Toolmanship"
        && skill_definition(SkillId.WOODWORK).display_name
            == "Woodwork"
        && resource_get_definition(ResourceId.FIELDSTONE).hand_skill_id
            == SkillId.TOOLMANSHIP
        && resource_get_definition(ResourceId.FIELDSTONE).hand_skill_xp
            == 15
        && 6 * resource_get_definition(
            ResourceId.FIELDSTONE
        ).hand_skill_xp + 25 >= skill_xp_for_level(2)
        && !is_undefined(winch_unlock)
        && winch_unlock.level == 2
        && winch_unlock.stable_key
            == SKILL_UNLOCK_UTILITY_VEHICLE_WINCH
        && array_length(heavy_level_two_pages) == 2
        && string_pos(
            "Utility Vehicle Winches",
            heavy_level_two_pages[1]
        ) > 0
        && array_length(toolmanship_level_two_pages) == 2
        && string_pos(
            "notch your axe",
            dialogue_page_text(axe_choice_page)
        ) > 0
        && array_length(axe_choices) == 2
        && axe_choices[0].action
            == DIALOGUE_ACTION_ENABLE_AXE_NOTCHING
        && axe_choices[1].action
            == DIALOGUE_ACTION_DISABLE_AXE_NOTCHING
        && heavy_result.changed
        && heavy_result.old_level == 1
        && heavy_result.new_level == 2
        && skill_curve_state.equipment_xp == 100
        && skill_get_xp(
            SkillId.HEAVY_EQUIPMENT,
            skill_curve_state
        ) == 100,
        "the mastery curve owns levels while preserving the equipment XP mirror"
    ) && passed;

    var notching_state = game_state_create_default();
    skill_award_xp_state(
        notching_state,
        SkillId.TOOLMANSHIP,
        skill_xp_for_level(2)
    );
    var notching_prompt_became_pending =
        notching_state.tools.axe_notching_prompt_pending;
    var notching_enabled = skill_set_axe_notching_preference_state(
        notching_state,
        AxeNotchingPreference.ENABLED
    );
    var first_notch = skill_record_axe_notch_state(notching_state);
    var second_notch = skill_record_axe_notch_state(notching_state);
    passed = task_test_expect(
        notching_prompt_became_pending
        && notching_enabled
        && !notching_state.tools.axe_notching_prompt_pending
        && notching_state.tools.axe_notching_preference
            == AxeNotchingPreference.ENABLED
        && first_notch
        && second_notch
        && notching_state.tools.axe_notch_count == 2,
        "Toolmanship level 2 offers and persists optional future axe notches"
    ) && passed;

    skill_levelup_queue_reset();
    var levelup_queued = skill_queue_levelup_result(
        SkillId.TOOLMANSHIP,
        {
            changed: true,
            old_level: 1,
            new_level: 2
        }
    );
    var queued_levelups = skill_levelup_queue_ensure();
    passed = task_test_expect(
        levelup_queued
        && array_length(queued_levelups) == 1
        && queued_levelups[0].skill_id == SkillId.TOOLMANSHIP
        && queued_levelups[0].level == 2,
        "skill gains queue one reusable level-up dialogue per earned level"
    ) && passed;
    skill_levelup_queue_reset();

    var winch_gate_state = game_state_create_default();
    winch_gate_state.task_statuses[TaskId.FIT_THE_WINCH] =
        TaskStatus.ACTIVE;
    winch_gate_state.winch_attachment_state =
        AttachmentState.STORED_AT_HOME;
    var winch_blocked_below_level_two =
        !progression_install_winch_state(winch_gate_state);
    skill_award_xp_state(
        winch_gate_state,
        SkillId.HEAVY_EQUIPMENT,
        skill_xp_for_level(2)
    );
    var winch_installed_at_level_two =
        progression_install_winch_state(winch_gate_state);
    passed = task_test_expect(
        winch_blocked_below_level_two
        && winch_installed_at_level_two
        && winch_gate_state.winch_attachment_state
            == AttachmentState.INSTALLED
        && winch_gate_state.task_statuses[TaskId.FIT_THE_WINCH]
            == TaskStatus.COMPLETE,
        "Heavy Equipment level 2 gates utility-vehicle winch installation"
    ) && passed;

    var intro_definition = cutscene_definition(
        CUTSCENE_INTRO_RESCUE
    );
    var axe_definition = cutscene_definition(
        CUTSCENE_AXE_HANDOFF
    );
    passed = task_test_expect(
        !is_undefined(intro_definition)
        && !is_undefined(axe_definition)
        && array_length(intro_definition.steps) >= 18
        && array_length(axe_definition.steps) >= 6
        && intro_definition.steps[
            array_length(intro_definition.steps) - 1
        ].type == CutsceneStepType.COMPLETE
        && axe_definition.steps[
            array_length(axe_definition.steps) - 1
        ].type == CutsceneStepType.COMPLETE,
        "the rescue and axe scenes share reusable authored cutscene steps"
    ) && passed;

    passed = task_test_expect(
        intro_definition.initial_fade_alpha == 1
        && intro_definition.steps[1].type
            == CutsceneStepType.REPOSITION_ACTOR
        && intro_definition.steps[1].actor_id
            == CUTSCENE_ACTOR_PLAYER
        && intro_definition.steps[2].type
            == CutsceneStepType.REPOSITION_ACTOR
        && intro_definition.steps[2].y == 430
        && intro_definition.steps[3].type
            == CutsceneStepType.CAMERA_FOCUS
        && intro_definition.steps[3].first_actor_id
            == CUTSCENE_ACTOR_PLAYER
        && intro_definition.steps[3].second_actor_id
            == CUTSCENE_ACTOR_PLAYER
        && intro_definition.steps[5].type
            == CutsceneStepType.FADE
        && intro_definition.steps[5].alpha == 0
        && intro_definition.steps[7].type
            == CutsceneStepType.MOVE_ACTOR
        && intro_definition.steps[7].y == 490
        && intro_definition.steps[9].type
            == CutsceneStepType.FADE
        && intro_definition.steps[9].alpha == 1
        && intro_definition.steps[11].type
            == CutsceneStepType.FADE
        && intro_definition.steps[11].alpha == 0
        && intro_definition.steps[12].type
            == CutsceneStepType.DIALOGUE
        && intro_definition.steps[12].actor_id
            == CUTSCENE_ACTOR_PLAYER
        && intro_definition.steps[12].pages[0] == "...help"
        && intro_definition.steps[13].type
            == CutsceneStepType.MOVE_ACTOR
        && intro_definition.steps[13].y == 524
        && intro_definition.steps[15].type
            == CutsceneStepType.FADE
        && intro_definition.steps[15].alpha == 1
        && intro_definition.steps[17].type
            == CutsceneStepType.FADE
        && intro_definition.steps[17].alpha == 0
        && intro_definition.steps[19].type
            == CutsceneStepType.DIALOGUE
        && intro_definition.steps[19].actor_id
            == CUTSCENE_ACTOR_FARMER
        && array_length(intro_definition.steps[19].pages) == 1
        && intro_definition.steps[19].pages[0] == "....."
        && intro_definition.steps[20].type
            == CutsceneStepType.FADE
        && intro_definition.steps[20].alpha == 1
        && cutscene_definition_resume_step(intro_definition, 1) == 22
        && intro_definition.steps[22].x == 1168
        && intro_definition.steps[22].y == 224
        && intro_definition.steps[24].first_actor_id
            == CUTSCENE_ACTOR_PLAYER
        && intro_definition.steps[24].second_actor_id
            == CUTSCENE_ACTOR_PLAYER
        && intro_definition.steps[26].speed == 0.012,
        "the intro stages two approaches and wakes west of the cabin door"
    ) && passed;

    passed = task_test_expect(
        cutscene_approach_value(0, 1, 0.25) == 0.25
        && cutscene_approach_value(1, 0, 0.25) == 0.75
        && cutscene_approach_value(0.9, 1, 0.25) == 1,
        "cutscene fades approach either target without a runtime builtin"
    ) && passed;

    var water_visit_definition =
        cutscene_definition(CUTSCENE_WATER_SUPPLY);
    passed = task_test_expect(
        water_visit_definition.steps[1].type
            == CutsceneStepType.REPOSITION_ACTOR
        && water_visit_definition.steps[1].target_actor_id
            == CUTSCENE_ACTOR_CABIN_SITE
        && water_visit_definition.steps[1].offset_y == 160
        && water_visit_definition.steps[5].type
            == CutsceneStepType.MOVE_ACTOR
        && water_visit_definition.steps[5].target_actor_id
            == CUTSCENE_ACTOR_CABIN_SITE
        && water_visit_definition.steps[5].offset_y == 64,
        "the post-build Farmer visit approaches from south of the cabin"
    ) && passed;

    passed = task_test_expect(
        !farmer_schedule_should_begin_pond_trip(899, 3, 2)
        && farmer_schedule_should_begin_pond_trip(900, 3, 2)
        && !farmer_schedule_should_begin_pond_trip(900, 3, 3)
        && !farmer_schedule_should_begin_pond_trip(
            CALENDAR_NIGHT_MINUTE,
            3,
            2
        ),
        "the Farmer begins one pond round trip per day at 3 PM"
    ) && passed;

    var axe_scene_state = game_state_create_default();
    axe_scene_state.tutorial_stage =
        TutorialStage.TRIP_ONE_HAND_FIELDSTONE;
    axe_scene_state.task_statuses[TaskId.FIELDSTONE_BY_HAND] =
        TaskStatus.ACTIVE;
    axe_scene_state.tutorial_fieldstones_collected = 6;
    var gathering_completed =
        progression_complete_hand_gathering_state(axe_scene_state);
    var axe_scene_record = cutscene_state_get_record(
        axe_scene_state,
        CUTSCENE_AXE_HANDOFF
    );
    var first_axe_command = cutscene_execute_command_state(
        axe_scene_state,
        CUTSCENE_COMMAND_GIVE_FARMERS_AXE
    );
    var second_axe_command = cutscene_execute_command_state(
        axe_scene_state,
        CUTSCENE_COMMAND_GIVE_FARMERS_AXE
    );
    passed = task_test_expect(
        gathering_completed
        && axe_scene_record.status == CutsceneStatus.ACTIVE
        && first_axe_command
        && second_axe_command
        && axe_scene_state.tools.axe_owned,
        "six stones queue one idempotent Farmer axe handoff"
    ) && passed;

    var machine_definitions = production_machine_definitions();
    var sawmill_definition = production_machine_definition(
        PRODUCTION_MACHINE_SAWMILL
    );
    var lathe_definition = production_machine_definition(
        PRODUCTION_MACHINE_LATHE
    );
    var default_jobs = production_state_create_default_jobs();
    passed = task_test_expect(
        array_length(machine_definitions) == 2
        && !is_undefined(sawmill_definition)
        && !is_undefined(lathe_definition)
        && sawmill_definition.machine_type
            == ProductionMachineType.SAWMILL
        && lathe_definition.machine_type
            == ProductionMachineType.LATHE
        && sawmill_definition.room_name == "Room1"
        && sawmill_definition.x == 496
        && sawmill_definition.y == 32
        && lathe_definition.room_name == "Room1"
        && lathe_definition.x == 400
        && lathe_definition.y == 32
        && array_length(default_jobs) == 2
        && default_jobs[0].machine_id == sawmill_definition.id
        && default_jobs[1].machine_id == lathe_definition.id,
        "the machine registry owns authored metadata and default durable jobs"
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
    var plank_chest_delivery = inventory_get_amount(
        production_state.finished_crafts_inventory,
        ResourceId.TIMBER_PLANK
    );
    var planks_taken_for_sawmill = finished_crafts_take(
        production_state,
        ResourceId.TIMBER_PLANK,
        4
    );
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
        && plank_chest_delivery == 4
        && planks_taken_for_sawmill == 4
        && straight_started
        && corner_started_then_cancelled
        && inventory_get_amount(
            production_state.home_inventory,
            ResourceId.TIMBER_PLANK
        ) == 0
        && inventory_get_amount(
            production_state.finished_crafts_inventory,
            ResourceId.TIMBER_PLANK
        ) == 0
        && inventory_get_amount(
            production_state.player_inventory,
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
        "milled planks enter the chest and explicitly carried inputs reserve and refund correctly"
    ) && passed;

    var plank_handoff_state = game_state_create_default();
    plank_handoff_state.cabin_site_placed = true;
    plank_handoff_state.task_statuses[TaskId.BUILD_CABIN_FENCE] =
        TaskStatus.ACTIVE;
    inventory_add(
        plank_handoff_state.finished_crafts_inventory,
        ResourceId.TIMBER_PLANK,
        4
    );
    var collect_planks_step =
        production_tutorial_next_step(plank_handoff_state);
    var handoff_planks_taken = finished_crafts_take(
        plank_handoff_state,
        ResourceId.TIMBER_PLANK,
        4
    );
    var cut_after_pickup_step =
        production_tutorial_next_step(plank_handoff_state);
    passed = task_test_expect(
        collect_planks_step.kind == "collect_input"
        && collect_planks_step.target.recipe_id
            == ProductionRecipeId.CUT_STRAIGHT_FENCE
        && collect_planks_step.amount == 4
        && handoff_planks_taken == 4
        && cut_after_pickup_step.kind == "craft"
        && cut_after_pickup_step.target.recipe_id
            == ProductionRecipeId.CUT_STRAIGHT_FENCE,
        "tutorial requires chest pickup before carried planks become sawmill stock"
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
    var water_collect_step =
        water_tutorial_next_step(production_state);
    var empty_bucket_taken = finished_crafts_take(
        production_state,
        ResourceId.EMPTY_BUCKET,
        1
    );
    var water_fill_step =
        water_tutorial_next_step(production_state);
    var bucket_filled =
        water_fill_bucket_state(production_state);
    var water_deposit_step =
        water_tutorial_next_step(production_state);
    var bucket_deposited =
        water_deposit_bucket_state(production_state);
    global.game_state = production_state;
    var water_snapshot = save_build_snapshot();
    var reloaded_water_state = save_hydrate_game_state(
        json_parse(json_stringify(water_snapshot.game_state))
    );
    passed = task_test_expect(
        bucket_started
        && water_collect_step.kind == "collect"
        && empty_bucket_taken == 1
        && water_fill_step.kind == "fill"
        && bucket_filled
        && water_deposit_step.kind == "deposit"
        && bucket_deposited
        && inventory_get_amount(
            production_state.finished_crafts_inventory,
            ResourceId.EMPTY_BUCKET
        ) == 0
        && inventory_get_amount(
            production_state.player_inventory,
            ResourceId.EMPTY_BUCKET
        ) == 1
        && inventory_get_amount(
            production_state.player_inventory,
            ResourceId.WATER_BUCKET
        ) == 0
        && production_state.water_tank_amount == 11
        && production_state.water_tutorial_stage
            == WaterTutorialStage.COMPLETE
        && production_state.homestead_stage
            == HomesteadStage.FIRST_REST_REQUIRED
        && reloaded_water_state.water_tank_amount == 11
        && reloaded_water_state.water_tutorial_stage
            == WaterTutorialStage.COMPLETE,
        "the post-cabin bucket loop derives each step and advances the tank from 10/40 to 11/40"
    ) && passed;

    var full_tank_state = game_state_create_default();
    full_tank_state.cabin_built = true;
    full_tank_state.water_tutorial_stage =
        WaterTutorialStage.COMPLETE;
    full_tank_state.homestead_stage =
        HomesteadStage.FIRST_REST_REQUIRED;
    full_tank_state.water_tank_amount = WATER_TANK_CAPACITY;
    inventory_add(
        full_tank_state.player_inventory,
        ResourceId.WATER_BUCKET,
        1
    );
    var overfill_rejected =
        !water_deposit_bucket_state(full_tank_state);
    passed = task_test_expect(
        overfill_rejected
        && full_tank_state.water_tank_amount == 40
        && inventory_get_amount(
            full_tank_state.player_inventory,
            ResourceId.WATER_BUCKET
        ) == 1,
        "the water tank stops atomically at its 40-bucket capacity"
    ) && passed;

    var water_build_state = game_state_create_default();
    water_build_state.cabin_site_placed = true;
    water_build_state.cabin_fence_marked = true;
    water_build_state.task_statuses[TaskId.PLACE_CABIN] =
        TaskStatus.ACTIVE;
    var water_build_completed =
        progression_build_cabin_state(water_build_state);
    var water_scene_record = cutscene_state_get_record(
        water_build_state,
        CUTSCENE_WATER_SUPPLY
    );
    passed = task_test_expect(
        water_build_completed
        && water_build_state.water_tank_amount == 10
        && water_build_state.water_tutorial_stage
            == WaterTutorialStage.ACTIVE
        && water_build_state.homestead_stage
            == HomesteadStage.WATER_SUPPLY_REQUIRED
        && water_scene_record.status == CutsceneStatus.ACTIVE,
        "raising the cabin atomically starts the Farmer water visit and blocks first rest"
    ) && passed;

    var v8_water_save = {
        format_version: 8,
        game_state: {
            cabin_built: true,
            day_number: 1,
            homestead_stage: HomesteadStage.FIRST_REST_REQUIRED,
            player_inventory: array_create(9, 0),
            home_inventory: array_create(9, 0),
            finished_crafts_inventory: array_create(9, 0),
            cutscene_records: []
        },
        scene: {},
        settings: {}
    };
    var migrated_v8_water = save_migrate_to_current(
        json_parse(json_stringify(v8_water_save))
    );
    var migrated_v8_water_state = save_hydrate_game_state(
        migrated_v8_water.game_state
    );
    var migrated_water_record = cutscene_state_get_record(
        migrated_v8_water_state,
        CUTSCENE_WATER_SUPPLY
    );
    passed = task_test_expect(
        migrated_v8_water.format_version == SAVE_FORMAT_CURRENT
        && migrated_v8_water_state.water_tank_amount == 10
        && migrated_v8_water_state.water_tutorial_stage
            == WaterTutorialStage.ACTIVE
        && migrated_v8_water_state.homestead_stage
            == HomesteadStage.WATER_SUPPLY_REQUIRED
        && migrated_water_record.status == CutsceneStatus.ACTIVE
        && array_length(
            migrated_v8_water_state.player_inventory.amounts
        ) == ResourceId.COUNT,
        "format-v8 cabins awaiting first rest migrate into the water lesson without replaying earlier work"
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

    var v4_home_inventory = array_create(ResourceId.COUNT, 0);
    var v4_finished_inventory = array_create(ResourceId.COUNT, 0);
    v4_home_inventory[ResourceId.TIMBER_PLANK] = 4;
    v4_finished_inventory[ResourceId.TIMBER_PLANK] = 1;
    var migrated_v4 = save_migrate_to_current({
        format_version: 4,
        game_state: {
            home_inventory: v4_home_inventory,
            finished_crafts_inventory: v4_finished_inventory
        },
        scene: {},
        settings: {}
    });
    passed = task_test_expect(
        migrated_v4.format_version == SAVE_FORMAT_CURRENT
        && migrated_v4.game_state.home_inventory[
            ResourceId.TIMBER_PLANK
        ] == 0
        && migrated_v4.game_state.finished_crafts_inventory[
            ResourceId.TIMBER_PLANK
        ] == 5,
        "v4 hidden Homebase planks migrate once into visible chest stock"
    ) && passed;

    var migrated_v5 = save_migrate_to_current({
        format_version: 5,
        game_state: {
            equipment_xp: 42,
            tutorial_intro_seen: true,
            tutorial_stage: TutorialStage.CHOP_TREE,
            tools: {axe_owned: true}
        },
        scene: {},
        settings: {}
    });
    var migrated_v5_intro = cutscene_state_get_record(
        migrated_v5.game_state,
        CUTSCENE_INTRO_RESCUE
    );
    var migrated_v5_axe = cutscene_state_get_record(
        migrated_v5.game_state,
        CUTSCENE_AXE_HANDOFF
    );
    passed = task_test_expect(
        migrated_v5.format_version == SAVE_FORMAT_CURRENT
        && migrated_v5.game_state.skill_xp[
            SkillId.HEAVY_EQUIPMENT
        ] == 42
        && migrated_v5_intro.status == CutsceneStatus.COMPLETE
        && migrated_v5_axe.status == CutsceneStatus.COMPLETE,
        "v5 equipment XP and completed story moments migrate to current"
    ) && passed;

    var v6_skill_xp = skill_state_create_default_xp();
    v6_skill_xp[SkillId.TOOLMANSHIP] = 25;
    var migrated_v6 = save_migrate_to_current({
        format_version: 6,
        game_state: {
            skill_xp: v6_skill_xp,
            tutorial_fieldstones_collected: 6,
            tutorial_fieldrocks_crushed: 10,
            tutorial_stage: TutorialStage.WINCH_INSTALL_REQUIRED,
            tools: {axe_owned: true}
        },
        scene: {},
        settings: {}
    });
    passed = task_test_expect(
        migrated_v6.format_version == SAVE_FORMAT_CURRENT
        && migrated_v6.game_state.skill_xp[
            SkillId.TOOLMANSHIP
        ] == 115
        && migrated_v6.game_state.skill_xp[
            SkillId.HEAVY_EQUIPMENT
        ] == 100
        && skill_unlock_is_available_state(
            migrated_v6.game_state,
            SkillId.HEAVY_EQUIPMENT,
            SKILL_UNLOCK_UTILITY_VEHICLE_WINCH
        )
        && migrated_v6.game_state.tools.axe_notching_prompt_pending,
        "v6 tutorial work migrates into both corrected level-2 outcomes"
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

    var minefield_exploration = tutorial_guidance_explore_area(
        WORLD_AREA_MINEFIELD,
        "SEARCH THE ROCKY FIELD"
    );
    passed = task_test_expect(
        minefield_exploration.valid
        && minefield_exploration.target_kind == "area"
        && minefield_exploration.x == 1080
        && minefield_exploration.y == 616,
        "exploration guidance points to an area instead of an exact resource"
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
