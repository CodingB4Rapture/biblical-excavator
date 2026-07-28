/// Pure save-data migrations. These functions only transform plain structs.

#macro SAVE_FORMAT_CURRENT 9
#macro SAVE_V2_TASK_COUNT 6

function save_migrate_v1_to_v2(_data)
{
    if (!is_struct(_data)
    || !variable_struct_exists(_data, "game_state")
    || !is_struct(_data.game_state))
    {
        return undefined;
    }

    var saved_state = _data.game_state;

    if (!variable_struct_exists(saved_state, "tutorial_stage")
    || !tutorial_stage_is_valid(saved_state.tutorial_stage))
    {
        saved_state.tutorial_stage = TutorialStage.TALK_TO_FARMER;
    }

    if (!variable_struct_exists(
        saved_state,
        "tutorial_fieldstones_collected"
    ))
    {
        saved_state.tutorial_fieldstones_collected = 0;
    }

    if (!variable_struct_exists(saved_state, "trip_rocks_gathered"))
        saved_state.trip_rocks_gathered = 0;

    if (!variable_struct_exists(
        saved_state,
        "tutorial_fieldrocks_crushed"
    ))
    {
        var rank = tutorial_stage_rank(saved_state.tutorial_stage);
        saved_state.tutorial_fieldrocks_crushed = rank > 5
            ? 10
            : (
                rank == 5
                    ? clamp(
                        saved_state.trip_rocks_gathered
                            - saved_state.tutorial_fieldstones_collected,
                        0,
                        10
                    )
                    : 0
            );
    }

    if (!variable_struct_exists(
        saved_state,
        "tutorial_board_assignment_pending"
    ))
    {
        saved_state.tutorial_board_assignment_pending = false;
    }

    if (!variable_struct_exists(
        saved_state,
        "cabin_placement_unlocked"
    ))
    {
        saved_state.cabin_placement_unlocked =
            tutorial_stage_rank(saved_state.tutorial_stage) >= 13;
    }

    if (variable_struct_exists(saved_state, "winch_attachment_state")
    && saved_state.tutorial_stage == TutorialStage.WINCH_PACKAGE_READY
    && saved_state.winch_attachment_state == AttachmentState.STORED_AT_HOME)
    {
        saved_state.tutorial_stage =
            TutorialStage.WINCH_INSTALL_REQUIRED;
    }

    var migrated_cabin_placed = variable_struct_exists(
        saved_state,
        "cabin_site_placed"
    ) && saved_state.cabin_site_placed;
    var migrated_cabin_unlocked =
        saved_state.cabin_placement_unlocked;

    if (!variable_struct_exists(saved_state, "quest_statuses")
    || !is_array(saved_state.quest_statuses))
    {
        saved_state.quest_statuses =
            array_create(QuestId.COUNT, QuestStatus.LOCKED);
        saved_state.quest_statuses[QuestId.FIRM_FOUNDATION] =
            saved_state.tutorial_stage == TutorialStage.TALK_TO_FARMER
                ? QuestStatus.LOCKED
                : (
                    saved_state.tutorial_stage == TutorialStage.COMPLETE
                        ? QuestStatus.COMPLETE
                        : QuestStatus.ACTIVE
                );
        saved_state.quest_statuses[QuestId.PLACE_OF_YOUR_OWN] =
            migrated_cabin_placed
                ? QuestStatus.COMPLETE
                : (
                    migrated_cabin_unlocked
                        ? QuestStatus.ACTIVE
                        : QuestStatus.LOCKED
                );
    }

    while (array_length(saved_state.quest_statuses) < QuestId.COUNT)
    {
        array_push(
            saved_state.quest_statuses,
            migrated_cabin_placed
                ? QuestStatus.COMPLETE
                : (
                    migrated_cabin_unlocked
                    || saved_state.tutorial_stage
                        == TutorialStage.COMPLETE
                        ? QuestStatus.ACTIVE
                        : QuestStatus.LOCKED
                )
        );
    }

    // Version one allowed tutorial milestones to mirror several task states
    // at once. Normalize once into the v2 single-active-task invariant. Earlier
    // work is archived without granting newly balanced retroactive rewards.
    var legacy_rank = tutorial_stage_rank(saved_state.tutorial_stage);
    var current_task = -1;
    if (saved_state.tutorial_board_assignment_pending)
        current_task = TaskId.FIELDSTONE_BY_HAND;
    else if (legacy_rank == 2)
        current_task = TaskId.FIELDSTONE_BY_HAND;
    else if (legacy_rank >= 3 && legacy_rank <= 4)
        current_task = TaskId.FALLEN_TREE;
    else if (legacy_rank == 5)
        current_task = TaskId.STONE_HAUL;
    else if (legacy_rank >= 6 && legacy_rank <= 7)
        current_task = TaskId.FIT_THE_WINCH;
    else if (legacy_rank >= 8 && legacy_rank <= 12)
        current_task = TaskId.TIMBER_DELIVERY;
    else if (legacy_rank >= 13)
    {
        var has_cabin = variable_struct_exists(
            saved_state,
            "cabin_site_placed"
        ) && saved_state.cabin_site_placed;
        if (!has_cabin) current_task = TaskId.PLACE_CABIN;
    }

    saved_state.task_statuses =
        array_create(SAVE_V2_TASK_COUNT, TaskStatus.LOCKED);
    saved_state.task_board_unlocked = current_task >= 0
        || legacy_rank >= 2;
    if (current_task >= 0)
    {
        for (var prior_task = 0;
            prior_task < current_task;
            prior_task++)
        {
            saved_state.task_statuses[prior_task] = TaskStatus.CLAIMED;
        }
        saved_state.task_statuses[current_task] =
            saved_state.tutorial_board_assignment_pending
                ? TaskStatus.AVAILABLE
                : TaskStatus.ACTIVE;
    }
    else if (legacy_rank >= 13)
    {
        for (var archived_task = 0;
            archived_task < SAVE_V2_TASK_COUNT;
            archived_task++)
        {
            saved_state.task_statuses[archived_task] =
                TaskStatus.CLAIMED;
        }
    }

    if (!variable_struct_exists(_data, "scene")
    || !is_struct(_data.scene))
    {
        _data.scene = {};
    }

    var scene = _data.scene;
    if (!variable_struct_exists(scene, "dialogue_active"))
        scene.dialogue_active = false;
    if (!variable_struct_exists(scene, "dialogue_pages"))
        scene.dialogue_pages = [];
    if (!variable_struct_exists(scene, "dialogue_page_index"))
        scene.dialogue_page_index = 0;
    if (!variable_struct_exists(scene, "dialogue_choice_index"))
        scene.dialogue_choice_index = 0;
    if (!variable_struct_exists(scene, "dialogue_speaker"))
        scene.dialogue_speaker = "";
    if (!variable_struct_exists(scene, "dialogue_style"))
        scene.dialogue_style = NotificationStyle.PROMPT;
    if (!variable_struct_exists(scene, "dialogue_completion_action"))
        scene.dialogue_completion_action = "";
    scene.dialogue_completion_action = dialogue_action_normalize(
        scene.dialogue_completion_action
    );

    if (!variable_struct_exists(_data, "settings")
    || !is_struct(_data.settings))
    {
        _data.settings = {
            master_volume: 1,
            fullscreen: false
        };
    }

    _data.format_version = 2;
    return _data;
}

function save_migrate_v2_to_v3(_data)
{
    if (!is_struct(_data)
    || !variable_struct_exists(_data, "game_state")
    || !is_struct(_data.game_state))
    {
        return undefined;
    }

    var saved_state = _data.game_state;
    var old_statuses = variable_struct_exists(saved_state, "task_statuses")
        && is_array(saved_state.task_statuses)
            ? saved_state.task_statuses
            : [];
    var new_statuses = array_create(TaskId.COUNT, TaskStatus.LOCKED);

    for (var old_task_id = 0;
        old_task_id < min(SAVE_V2_TASK_COUNT, array_length(old_statuses));
        old_task_id++)
    {
        var old_status = old_statuses[old_task_id];
        new_statuses[old_task_id] = task_status_is_valid(old_status)
            ? old_status
            : TaskStatus.LOCKED;
    }

    var cabin_placed = variable_struct_exists(
        saved_state,
        "cabin_site_placed"
    ) && saved_state.cabin_site_placed;
    var old_cabin_status = new_statuses[TaskId.PLACE_CABIN];

    if (cabin_placed)
    {
        // In v2, placing the site used the completed cabin art and was the end
        // of the arc. Preserve that finished state without making an existing
        // player repeat newly inserted tutorial tasks.
        saved_state.skidsteer_parked = true;
        saved_state.cabin_fence_marked = true;
        saved_state.cabin_built = true;
        new_statuses[TaskId.PARK_SKIDSTEER] = TaskStatus.CLAIMED;
        new_statuses[TaskId.MARK_CABIN_SITE] = TaskStatus.CLAIMED;
    }
    else
    {
        saved_state.skidsteer_parked = false;
        saved_state.cabin_fence_marked = false;
        saved_state.cabin_built = false;
        new_statuses[TaskId.PLACE_CABIN] = TaskStatus.LOCKED;

        var timber_claimed = new_statuses[TaskId.TIMBER_DELIVERY]
            == TaskStatus.CLAIMED;
        if (old_cabin_status == TaskStatus.ACTIVE)
        {
            new_statuses[TaskId.PARK_SKIDSTEER] = TaskStatus.ACTIVE;
        }
        else if (old_cabin_status >= TaskStatus.AVAILABLE
        || timber_claimed)
        {
            new_statuses[TaskId.PARK_SKIDSTEER] = TaskStatus.AVAILABLE;
        }
    }

    saved_state.task_statuses = new_statuses;
    _data.format_version = 3;
    return _data;
}

function save_migrate_v3_to_v4(_data)
{
    if (!is_struct(_data)
    || !variable_struct_exists(_data, "game_state")
    || !is_struct(_data.game_state))
    {
        return undefined;
    }

    var saved_state = _data.game_state;
    var old_statuses = variable_struct_exists(saved_state, "task_statuses")
        && is_array(saved_state.task_statuses)
            ? saved_state.task_statuses
            : [];
    var new_statuses = array_create(TaskId.COUNT, TaskStatus.LOCKED);
    for (var task_id = 0;
        task_id < min(8, array_length(old_statuses));
        task_id++)
    {
        new_statuses[task_id] = task_status_is_valid(
            old_statuses[task_id]
        )
            ? old_statuses[task_id]
            : TaskStatus.LOCKED;
    }

    var cabin_built = variable_struct_exists(saved_state, "cabin_built")
        && saved_state.cabin_built;
    if (cabin_built)
    {
        new_statuses[TaskId.BUILD_CABIN_FENCE] = TaskStatus.CLAIMED;
        saved_state.free_build_unlocked =
            new_statuses[TaskId.PLACE_CABIN] == TaskStatus.CLAIMED;
    }
    else if (new_statuses[TaskId.MARK_CABIN_SITE]
        == TaskStatus.CLAIMED)
    {
        // The previous version jumped straight from site selection to a
        // pre-seeded plank/cabin action. Route that point to the new explicit
        // workshop task without repeating the site decision.
        new_statuses[TaskId.BUILD_CABIN_FENCE] =
            TaskStatus.AVAILABLE;
        new_statuses[TaskId.PLACE_CABIN] = TaskStatus.LOCKED;
        saved_state.free_build_unlocked = false;

        if (variable_struct_exists(
            saved_state,
            "finished_crafts_inventory"
        ) && is_array(saved_state.finished_crafts_inventory)
        && array_length(saved_state.finished_crafts_inventory)
            > ResourceId.TIMBER_PLANK)
        {
            saved_state.finished_crafts_inventory[
                ResourceId.TIMBER_PLANK
            ] = 0;
        }
        if (variable_struct_exists(saved_state, "player_inventory")
        && is_array(saved_state.player_inventory)
        && array_length(saved_state.player_inventory)
            > ResourceId.TIMBER_PLANK)
        {
            saved_state.player_inventory[
                ResourceId.TIMBER_PLANK
            ] = 0;
        }
    }
    else
    {
        saved_state.free_build_unlocked = false;
    }

    saved_state.task_statuses = new_statuses;
    saved_state.production_jobs = [
        production_job_create(
            PRODUCTION_MACHINE_SAWMILL,
            ProductionMachineType.SAWMILL
        ),
        production_job_create(
            PRODUCTION_MACHINE_LATHE,
            ProductionMachineType.LATHE
        )
    ];
    saved_state.production_completed_batches =
        array_create(ProductionRecipeId.COUNT, 0);
    _data.format_version = 4;
    return _data;
}

/// Version four delivered milled planks into invisible Homebase stock even
/// though the middle chest presented all other completed workshop output.
/// Move that stranded stock into the chest once; later fence recipes consume
/// only planks the player explicitly retrieves and carries to the sawmill.
function save_migrate_v4_to_v5(_data)
{
    if (!is_struct(_data)
    || !variable_struct_exists(_data, "game_state")
    || !is_struct(_data.game_state))
    {
        return undefined;
    }

    var saved_state = _data.game_state;
    if (!variable_struct_exists(saved_state, "home_inventory")
    || !is_array(saved_state.home_inventory))
    {
        saved_state.home_inventory =
            array_create(ResourceId.COUNT, 0);
    }
    if (!variable_struct_exists(
        saved_state,
        "finished_crafts_inventory"
    ) || !is_array(saved_state.finished_crafts_inventory))
    {
        saved_state.finished_crafts_inventory =
            array_create(ResourceId.COUNT, 0);
    }
    while (array_length(saved_state.home_inventory) < ResourceId.COUNT)
        array_push(saved_state.home_inventory, 0);
    while (array_length(saved_state.finished_crafts_inventory)
        < ResourceId.COUNT)
    {
        array_push(saved_state.finished_crafts_inventory, 0);
    }

    var stranded_planks = max(
        0,
        saved_state.home_inventory[ResourceId.TIMBER_PLANK]
    );
    saved_state.home_inventory[ResourceId.TIMBER_PLANK] = 0;
    saved_state.finished_crafts_inventory[
        ResourceId.TIMBER_PLANK
    ] += stranded_planks;

    _data.format_version = 5;
    return _data;
}

/// Version six introduces the append-only skill XP array and durable authored
/// cutscene checkpoints. Existing saves retain equipment XP and do not replay
/// story presentations whose durable outcomes already happened.
function save_migrate_v5_to_v6(_data)
{
    if (!is_struct(_data)
    || !variable_struct_exists(_data, "game_state")
    || !is_struct(_data.game_state))
    {
        return undefined;
    }

    var saved_state = _data.game_state;
    var equipment_xp =
        variable_struct_exists(saved_state, "equipment_xp")
        && is_numeric(saved_state.equipment_xp)
            ? max(0, floor(saved_state.equipment_xp))
            : 0;
    saved_state.skill_xp = skill_state_create_default_xp();
    saved_state.skill_xp[SkillId.HEAVY_EQUIPMENT] = equipment_xp;

    var intro_complete =
        variable_struct_exists(saved_state, "tutorial_intro_seen")
        && saved_state.tutorial_intro_seen;
    if (variable_struct_exists(saved_state, "tutorial_stage")
    && saved_state.tutorial_stage != TutorialStage.TALK_TO_FARMER)
    {
        intro_complete = true;
    }
    var axe_complete =
        variable_struct_exists(saved_state, "tools")
        && is_struct(saved_state.tools)
        && variable_struct_exists(saved_state.tools, "axe_owned")
        && saved_state.tools.axe_owned;
    saved_state.cutscene_records = [
        cutscene_record_create(
            CUTSCENE_INTRO_RESCUE,
            intro_complete
                ? CutsceneStatus.COMPLETE
                : CutsceneStatus.NOT_STARTED
        ),
        cutscene_record_create(
            CUTSCENE_AXE_HANDOFF,
            axe_complete
                ? CutsceneStatus.COMPLETE
                : CutsceneStatus.NOT_STARTED
        )
    ];

    _data.format_version = 6;
    return _data;
}

/// Version seven credits the Toolmanship XP attached to completed tutorial
/// gathering and axe work.
function save_migrate_v6_to_v7(_data)
{
    if (!is_struct(_data)
    || !variable_struct_exists(_data, "game_state")
    || !is_struct(_data.game_state))
    {
        return undefined;
    }

    var saved_state = _data.game_state;
    if (!variable_struct_exists(saved_state, "skill_xp")
    || !is_array(saved_state.skill_xp))
    {
        saved_state.skill_xp = skill_state_create_default_xp();
    }
    while (array_length(saved_state.skill_xp) < SkillId.COUNT)
        array_push(saved_state.skill_xp, 0);

    var gathered_stones =
        variable_struct_exists(
            saved_state,
            "tutorial_fieldstones_collected"
        )
        && is_numeric(saved_state.tutorial_fieldstones_collected)
            ? clamp(
                floor(saved_state.tutorial_fieldstones_collected),
                0,
                6
            )
            : 0;
    var minimum_toolmanship_xp = gathered_stones * 15;

    var has_axe =
        variable_struct_exists(saved_state, "tools")
        && is_struct(saved_state.tools)
        && variable_struct_exists(saved_state.tools, "axe_owned")
        && saved_state.tools.axe_owned;
    if (has_axe)
        minimum_toolmanship_xp = max(minimum_toolmanship_xp, 90);

    if (variable_struct_exists(saved_state, "tutorial_stage")
    && tutorial_stage_rank(saved_state.tutorial_stage) >= 4)
    {
        minimum_toolmanship_xp = max(minimum_toolmanship_xp, 115);
    }

    saved_state.skill_xp[SkillId.TOOLMANSHIP] = max(
        is_numeric(saved_state.skill_xp[SkillId.TOOLMANSHIP])
            ? floor(saved_state.skill_xp[SkillId.TOOLMANSHIP])
            : 0,
        minimum_toolmanship_xp
    );

    _data.format_version = 7;
    return _data;
}

/// Version eight moves Utility Vehicle Winches to Heavy Equipment Level 2 and
/// adds the durable axe-notching choice introduced at Toolmanship Level 2.
function save_migrate_v7_to_v8(_data)
{
    if (!is_struct(_data)
    || !variable_struct_exists(_data, "game_state")
    || !is_struct(_data.game_state))
    {
        return undefined;
    }

    var saved_state = _data.game_state;
    if (!variable_struct_exists(saved_state, "skill_xp")
    || !is_array(saved_state.skill_xp))
    {
        saved_state.skill_xp = skill_state_create_default_xp();
    }
    while (array_length(saved_state.skill_xp) < SkillId.COUNT)
        array_push(saved_state.skill_xp, 0);

    var crushed_fieldrocks =
        variable_struct_exists(
            saved_state,
            "tutorial_fieldrocks_crushed"
        )
        && is_numeric(saved_state.tutorial_fieldrocks_crushed)
            ? clamp(
                floor(saved_state.tutorial_fieldrocks_crushed),
                0,
                10
            )
            : 0;
    var minimum_equipment_xp = crushed_fieldrocks * 10;
    if (variable_struct_exists(saved_state, "tutorial_stage")
    && tutorial_stage_rank(saved_state.tutorial_stage) >= 6)
    {
        minimum_equipment_xp = max(
            minimum_equipment_xp,
            skill_xp_for_level(2)
        );
    }
    if (variable_struct_exists(saved_state, "winch_attachment_state")
    && saved_state.winch_attachment_state != AttachmentState.LOCKED)
    {
        minimum_equipment_xp = max(
            minimum_equipment_xp,
            skill_xp_for_level(2)
        );
    }

    saved_state.skill_xp[SkillId.HEAVY_EQUIPMENT] = max(
        is_numeric(saved_state.skill_xp[SkillId.HEAVY_EQUIPMENT])
            ? floor(saved_state.skill_xp[SkillId.HEAVY_EQUIPMENT])
            : 0,
        minimum_equipment_xp
    );
    saved_state.equipment_xp = max(
        variable_struct_exists(saved_state, "equipment_xp")
        && is_numeric(saved_state.equipment_xp)
            ? floor(saved_state.equipment_xp)
            : 0,
        saved_state.skill_xp[SkillId.HEAVY_EQUIPMENT]
    );

    if (!variable_struct_exists(saved_state, "tools")
    || !is_struct(saved_state.tools))
    {
        saved_state.tools = {axe_owned: false};
    }
    if (!variable_struct_exists(
        saved_state.tools,
        "axe_notching_preference"
    ))
    {
        saved_state.tools.axe_notching_preference =
            AxeNotchingPreference.UNDECIDED;
    }
    if (!variable_struct_exists(saved_state.tools, "axe_notch_count"))
        saved_state.tools.axe_notch_count = 0;
    saved_state.tools.axe_notching_prompt_pending =
        saved_state.tools.axe_notching_preference
            == AxeNotchingPreference.UNDECIDED
        && skill_level_from_xp(
            SkillId.TOOLMANSHIP,
            saved_state.skill_xp[SkillId.TOOLMANSHIP]
        ) >= 2;

    // Replace the short-lived development version of this active level-up if
    // a save happened while its old Toolmanship winch page was onscreen.
    if (variable_struct_exists(_data, "scene")
    && is_struct(_data.scene)
    && variable_struct_exists(_data.scene, "dialogue_speaker")
    && _data.scene.dialogue_speaker == "SKILL LEVEL UP"
    && variable_struct_exists(_data.scene, "dialogue_pages")
    && is_array(_data.scene.dialogue_pages))
    {
        var old_winch_page_found = false;
        for (var page_index = 0;
            page_index < array_length(_data.scene.dialogue_pages);
            page_index++)
        {
            if (string_pos(
                "Utility Vehicle Winches",
                dialogue_page_text(_data.scene.dialogue_pages[page_index])
            ) > 0)
            {
                old_winch_page_found = true;
            }
        }
        if (old_winch_page_found)
        {
            _data.scene.dialogue_pages = skill_levelup_pages(
                SkillId.TOOLMANSHIP,
                2
            );
            _data.scene.dialogue_page_index = 0;
            _data.scene.dialogue_choice_index = 0;
        }
    }

    _data.format_version = 8;
    return _data;
}

/// Version nine inserts the post-cabin water lesson. Established homesteads
/// keep their unlocked day loop; cabins still waiting on their first rest
/// resume at the Farmer's water-supply visit.
function save_migrate_v8_to_v9(_data)
{
    if (!is_struct(_data)
    || !variable_struct_exists(_data, "game_state")
    || !is_struct(_data.game_state))
    {
        return undefined;
    }

    var saved_state = _data.game_state;
    var cabin_built =
        variable_struct_exists(saved_state, "cabin_built")
        && saved_state.cabin_built;
    var day_number =
        variable_struct_exists(saved_state, "day_number")
        && is_numeric(saved_state.day_number)
            ? max(1, floor(saved_state.day_number))
            : 1;
    var hub_open =
        variable_struct_exists(saved_state, "homestead_stage")
        && saved_state.homestead_stage == HomesteadStage.HUB_OPEN;
    var water_complete = cabin_built
        && (hub_open || day_number > 1);

    saved_state.water_tank_amount = water_complete
        ? WATER_TANK_START_AMOUNT + 1
        : WATER_TANK_START_AMOUNT;
    saved_state.water_tutorial_stage =
        !cabin_built
            ? WaterTutorialStage.LOCKED
            : (
                water_complete
                    ? WaterTutorialStage.COMPLETE
                    : WaterTutorialStage.ACTIVE
            );
    if (cabin_built && !water_complete)
    {
        saved_state.homestead_stage =
            HomesteadStage.WATER_SUPPLY_REQUIRED;
    }

    if (!variable_struct_exists(saved_state, "cutscene_records")
    || !is_array(saved_state.cutscene_records))
    {
        saved_state.cutscene_records = [];
    }
    var water_record_index = -1;
    for (var record_index = 0;
        record_index < array_length(saved_state.cutscene_records);
        record_index++)
    {
        var record = saved_state.cutscene_records[record_index];
        if (is_struct(record)
        && variable_struct_exists(record, "id")
        && record.id == CUTSCENE_WATER_SUPPLY)
        {
            water_record_index = record_index;
            break;
        }
    }
    var water_cutscene_status = water_complete
        ? CutsceneStatus.COMPLETE
        : (
            cabin_built
                ? CutsceneStatus.ACTIVE
                : CutsceneStatus.NOT_STARTED
        );
    if (water_record_index < 0)
    {
        array_push(
            saved_state.cutscene_records,
            cutscene_record_create(
                CUTSCENE_WATER_SUPPLY,
                water_cutscene_status
            )
        );
    }
    else
    {
        saved_state.cutscene_records[water_record_index].status =
            water_cutscene_status;
        saved_state.cutscene_records[water_record_index].checkpoint = 0;
    }

    var inventory_fields = [
        "player_inventory",
        "home_inventory",
        "finished_crafts_inventory"
    ];
    for (var field_index = 0;
        field_index < array_length(inventory_fields);
        field_index++)
    {
        var field_name = inventory_fields[field_index];
        if (!variable_struct_exists(saved_state, field_name)
        || !is_array(saved_state[$ field_name]))
        {
            saved_state[$ field_name] =
                array_create(ResourceId.COUNT, 0);
        }
        while (array_length(saved_state[$ field_name])
            < ResourceId.COUNT)
        {
            array_push(saved_state[$ field_name], 0);
        }
    }

    _data.format_version = 9;
    return _data;
}

function save_migrate_to_current(_data)
{
    if (!is_struct(_data)
    || !variable_struct_exists(_data, "format_version")
    || !is_real(_data.format_version))
    {
        return undefined;
    }

    var safety = 0;
    while (_data.format_version < SAVE_FORMAT_CURRENT && safety < 9)
    {
        switch (_data.format_version)
        {
            case 1:
                _data = save_migrate_v1_to_v2(_data);
                break;

            case 2:
                _data = save_migrate_v2_to_v3(_data);
                break;

            case 3:
                _data = save_migrate_v3_to_v4(_data);
                break;

            case 4:
                _data = save_migrate_v4_to_v5(_data);
                break;

            case 5:
                _data = save_migrate_v5_to_v6(_data);
                break;

            case 6:
                _data = save_migrate_v6_to_v7(_data);
                break;

            case 7:
                _data = save_migrate_v7_to_v8(_data);
                break;

            case 8:
                _data = save_migrate_v8_to_v9(_data);
                break;

            default:
                return undefined;
        }

        if (is_undefined(_data)) return undefined;
        safety += 1;
    }

    if (_data.format_version != SAVE_FORMAT_CURRENT)
        return undefined;

    if (!variable_struct_exists(_data, "game_state")
    || !is_struct(_data.game_state))
    {
        return undefined;
    }
    if (!variable_struct_exists(_data, "scene")
    || !is_struct(_data.scene))
    {
        _data.scene = {};
    }
    if (!variable_struct_exists(_data, "settings")
    || !is_struct(_data.settings))
    {
        _data.settings = {};
    }

    var scene = _data.scene;
    if (!variable_struct_exists(scene, "dialogue_active"))
        scene.dialogue_active = false;
    if (!variable_struct_exists(scene, "dialogue_pages"))
        scene.dialogue_pages = [];
    if (!variable_struct_exists(scene, "dialogue_page_index"))
        scene.dialogue_page_index = 0;
    if (!variable_struct_exists(scene, "dialogue_choice_index"))
        scene.dialogue_choice_index = 0;
    if (!variable_struct_exists(scene, "dialogue_speaker"))
        scene.dialogue_speaker = "";
    if (!variable_struct_exists(scene, "dialogue_completion_action"))
        scene.dialogue_completion_action = "";
    if (!variable_struct_exists(scene, "dialogue_style"))
        scene.dialogue_style = NotificationStyle.PROMPT;
    scene.dialogue_completion_action = dialogue_action_normalize(
        scene.dialogue_completion_action
    );

    return _data;
}
