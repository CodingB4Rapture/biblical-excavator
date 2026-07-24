/// Durable runtime state schema.
///
/// This module may create missing structural fields, resize persisted arrays,
/// and sanitize invalid values. It must not advance tutorial/task/quest
/// progression, create room instances, display UI, or save the game.

function tutorial_stage_is_valid(_stage)
{
    switch (_stage)
    {
        case TutorialStage.TALK_TO_FARMER:
        case TutorialStage.TALK_TO_FARMERS_WIFE:
        case TutorialStage.TRIP_ONE_HAND_FIELDSTONE:
        case TutorialStage.TRIP_TWO_VEHICLE_FIELDSTONE:
        case TutorialStage.WINCH_PACKAGE_READY:
        case TutorialStage.HAUL_FIRST_LOG:
        case TutorialStage.COMPLETE:
        case TutorialStage.WINCH_INSTALL_REQUIRED:
        case TutorialStage.INSPECT_FIRST_LOG:
        case TutorialStage.TAKE_WINCH_CABLE:
        case TutorialStage.ATTACH_CABLE_TO_LOG:
        case TutorialStage.CHOP_TREE:
        case TutorialStage.INSPECT_FALLEN_TREE:
        case TutorialStage.PULL_STUMP:
            return true;
    }

    return false;
}

/// Persisted TutorialStage numbers are append-only and are not narrative order.
function tutorial_stage_rank(_stage)
{
    switch (_stage)
    {
        case TutorialStage.TALK_TO_FARMER: return 0;
        case TutorialStage.TALK_TO_FARMERS_WIFE: return 1;
        case TutorialStage.TRIP_ONE_HAND_FIELDSTONE: return 2;
        case TutorialStage.CHOP_TREE: return 3;
        case TutorialStage.INSPECT_FALLEN_TREE: return 4;
        case TutorialStage.TRIP_TWO_VEHICLE_FIELDSTONE: return 5;
        case TutorialStage.WINCH_PACKAGE_READY: return 6;
        case TutorialStage.WINCH_INSTALL_REQUIRED: return 7;
        case TutorialStage.INSPECT_FIRST_LOG: return 8;
        case TutorialStage.TAKE_WINCH_CABLE: return 9;
        case TutorialStage.ATTACH_CABLE_TO_LOG: return 10;
        case TutorialStage.HAUL_FIRST_LOG: return 11;
        case TutorialStage.PULL_STUMP: return 12;
        case TutorialStage.COMPLETE: return 13;
    }

    return 0;
}

function tutorial_stage_implies_axe(_stage)
{
    return _stage != TutorialStage.TALK_TO_FARMER
        && _stage != TutorialStage.TALK_TO_FARMERS_WIFE
        && _stage != TutorialStage.TRIP_ONE_HAND_FIELDSTONE;
}

function game_state_create_default()
{
    return {
        player_inventory: inventory_create_player(),
        home_inventory: inventory_create(-1),
        finished_crafts_inventory: inventory_create_finished_crafts(),
        tools: {
            axe_owned: false
        },
        tutorial_fieldstones_collected: 0,
        tutorial_fieldrocks_crushed: 0,
        fieldstone_records: [],
        fieldrock_records: [],
        tree_records: [],
        // Legacy format-v1 save key. Keep it for trip UI/save compatibility.
        trip_rocks_gathered: 0,
        trip_xp_gained: 0,
        daily_resources_gathered: array_create(ResourceId.COUNT, 0),
        equipment_xp: 0,
        completed_deliveries: 0,
        winch_attachment_state: AttachmentState.LOCKED,
        tutorial_intro_seen: false,
        tutorial_stage: TutorialStage.TALK_TO_FARMER,
        tutorial_hand_stones_spawned: false,
        tutorial_board_assignment_pending: false,
        quest_statuses: array_create(QuestId.COUNT, QuestStatus.LOCKED),
        task_board_unlocked: false,
        task_statuses: array_create(TaskId.COUNT, TaskStatus.LOCKED),
        cabin_placement_unlocked: false,
        skidsteer_parked: false,
        cabin_site_placed: false,
        cabin_site_room: "Room1",
        cabin_site_x: 0,
        cabin_site_y: 0,
        cabin_fence_marked: false,
        cabin_built: false,
        homestead_stage: HomesteadStage.TUTORIAL,
        first_hub_hint_pending: false,
        day_number: 1,
        // Minutes since midnight; 1080 is 6:00 PM.
        time_of_day: 1080,
        fence_records: [],
        removed_world_ids: []
    };
}

function homestead_stage_infer(_game_state)
{
    if (!_game_state.cabin_built)
    {
        return HomesteadStage.TUTORIAL;
    }

    return (_game_state.day_number > 1)
        ? HomesteadStage.HUB_OPEN
        : HomesteadStage.FIRST_REST_REQUIRED;
}

function homestead_stage_sanitize(_stage, _game_state)
{
    if (!is_real(_stage)
    || _stage < HomesteadStage.TUTORIAL
    || _stage > HomesteadStage.HUB_OPEN)
    {
        return homestead_stage_infer(_game_state);
    }

    if (!_game_state.cabin_built)
    {
        return HomesteadStage.TUTORIAL;
    }

    return _stage;
}

function homestead_stage_get()
{
    return game_state_ensure().homestead_stage;
}

function quest_status_is_valid(_status)
{
    return _status == QuestStatus.LOCKED
        || _status == QuestStatus.ACTIVE
        || _status == QuestStatus.COMPLETE;
}

function game_state_infer_quest_status(_quest_id, _game_state)
{
    switch (_quest_id)
    {
        case QuestId.FIRM_FOUNDATION:
            if (_game_state.tutorial_stage == TutorialStage.TALK_TO_FARMER)
                return QuestStatus.LOCKED;
            if (_game_state.tutorial_stage == TutorialStage.COMPLETE)
                return QuestStatus.COMPLETE;
            return QuestStatus.ACTIVE;

        case QuestId.PLACE_OF_YOUR_OWN:
            if (_game_state.cabin_built) return QuestStatus.COMPLETE;
            if (_game_state.cabin_placement_unlocked
            || _game_state.tutorial_stage == TutorialStage.COMPLETE)
                return QuestStatus.ACTIVE;
            return QuestStatus.LOCKED;
    }

    return QuestStatus.LOCKED;
}

function game_state_normalize(_game_state)
{
    if (!variable_struct_exists(_game_state, "tutorial_stage")
    || !tutorial_stage_is_valid(_game_state.tutorial_stage))
    {
        _game_state.tutorial_stage = TutorialStage.TALK_TO_FARMER;
    }

    if (!variable_struct_exists(_game_state, "player_inventory")
    || !is_struct(_game_state.player_inventory))
    {
        _game_state.player_inventory = inventory_create_player();
    }
    else
    {
        _game_state.player_inventory =
            inventory_ensure_size(_game_state.player_inventory);
    }
    // Player carrying limits are per resource. Keeping them in the inventory
    // struct gives later task rewards a durable place to increase each limit.
    _game_state.player_inventory.capacity = -1;
    inventory_apply_minimum_resource_capacity(
        _game_state.player_inventory,
        ResourceId.FIELDSTONE,
        PLAYER_FIELDSTONE_CAPACITY
    );
    inventory_apply_minimum_resource_capacity(
        _game_state.player_inventory,
        ResourceId.TIMBER_PLANK,
        PLAYER_TIMBER_PLANK_CAPACITY
    );

    if (!variable_struct_exists(_game_state, "home_inventory")
    || !is_struct(_game_state.home_inventory))
    {
        _game_state.home_inventory = inventory_create(-1);
    }
    else
    {
        _game_state.home_inventory =
            inventory_ensure_size(_game_state.home_inventory);
    }

    if (!variable_struct_exists(_game_state, "finished_crafts_inventory")
    || !is_struct(_game_state.finished_crafts_inventory))
    {
        _game_state.finished_crafts_inventory =
            inventory_create_finished_crafts();
        if (variable_struct_exists(_game_state, "cabin_built")
        && _game_state.cabin_built)
        {
            _game_state.finished_crafts_inventory.amounts[
                ResourceId.TIMBER_PLANK
            ] = 0;
        }
    }
    else
    {
        _game_state.finished_crafts_inventory = inventory_ensure_size(
            _game_state.finished_crafts_inventory
        );
    }

    if (!variable_struct_exists(_game_state, "tools")
    || !is_struct(_game_state.tools))
    {
        _game_state.tools = {
            axe_owned: tutorial_stage_implies_axe(_game_state.tutorial_stage)
        };
    }

    if (!variable_struct_exists(_game_state.tools, "axe_owned"))
    {
        _game_state.tools.axe_owned =
            tutorial_stage_implies_axe(_game_state.tutorial_stage);
    }

    if (!variable_struct_exists(_game_state, "tutorial_fieldstones_collected"))
    {
        _game_state.tutorial_fieldstones_collected =
            _game_state.tools.axe_owned
                ? 6
                : min(
                    6,
                    inventory_get_amount(
                        _game_state.player_inventory,
                        ResourceId.FIELDSTONE
                    )
                );
    }
    _game_state.tutorial_fieldstones_collected = clamp(
        _game_state.tutorial_fieldstones_collected,
        0,
        6
    );

    if (!variable_struct_exists(_game_state, "trip_rocks_gathered"))
        _game_state.trip_rocks_gathered = 0;
    if (!variable_struct_exists(_game_state, "trip_xp_gained"))
        _game_state.trip_xp_gained = 0;
    if (!variable_struct_exists(_game_state, "equipment_xp"))
        _game_state.equipment_xp = 0;
    if (!variable_struct_exists(_game_state, "completed_deliveries"))
        _game_state.completed_deliveries = 0;

    if (!variable_struct_exists(_game_state, "tutorial_fieldrocks_crushed"))
    {
        var tutorial_rank = tutorial_stage_rank(_game_state.tutorial_stage);
        _game_state.tutorial_fieldrocks_crushed = tutorial_rank > 5
            ? 10
            : (
                tutorial_rank == 5
                    ? clamp(
                        _game_state.trip_rocks_gathered
                            - _game_state.tutorial_fieldstones_collected,
                        0,
                        10
                    )
                    : 0
            );
    }
    _game_state.tutorial_fieldrocks_crushed = clamp(
        _game_state.tutorial_fieldrocks_crushed,
        0,
        10
    );

    if (!variable_struct_exists(_game_state, "winch_attachment_state"))
        _game_state.winch_attachment_state = AttachmentState.LOCKED;
    if (!variable_struct_exists(_game_state, "tutorial_intro_seen"))
        _game_state.tutorial_intro_seen = false;
    if (!variable_struct_exists(_game_state, "tutorial_hand_stones_spawned"))
        _game_state.tutorial_hand_stones_spawned = false;
    if (!variable_struct_exists(_game_state, "tutorial_board_assignment_pending"))
        _game_state.tutorial_board_assignment_pending = false;

    if (!variable_struct_exists(_game_state, "cabin_placement_unlocked"))
    {
        _game_state.cabin_placement_unlocked =
            _game_state.tutorial_stage == TutorialStage.COMPLETE;
    }
    if (!variable_struct_exists(_game_state, "cabin_site_placed"))
        _game_state.cabin_site_placed = false;
    if (!variable_struct_exists(_game_state, "cabin_site_room"))
        _game_state.cabin_site_room = "Room1";
    if (!variable_struct_exists(_game_state, "cabin_site_x"))
        _game_state.cabin_site_x = 0;
    if (!variable_struct_exists(_game_state, "cabin_site_y"))
        _game_state.cabin_site_y = 0;
    if (!variable_struct_exists(_game_state, "skidsteer_parked"))
        _game_state.skidsteer_parked = false;
    if (!variable_struct_exists(_game_state, "cabin_fence_marked"))
        _game_state.cabin_fence_marked = false;
    if (!variable_struct_exists(_game_state, "cabin_built"))
    {
        // Saves from before the marked-site flow used cabin_site_placed as the
        // finished-cabin milestone.
        _game_state.cabin_built = _game_state.cabin_site_placed
            && variable_struct_exists(_game_state, "homestead_stage")
            && _game_state.homestead_stage
                != HomesteadStage.TUTORIAL;
    }
    if (!variable_struct_exists(_game_state, "day_number"))
        _game_state.day_number = 1;
    if (!variable_struct_exists(_game_state, "time_of_day"))
        _game_state.time_of_day = 1080;
    if (!variable_struct_exists(_game_state, "first_hub_hint_pending"))
        _game_state.first_hub_hint_pending = false;

    var array_fields = [
        "removed_world_ids",
        "tree_records",
        "fieldrock_records",
        "fieldstone_records",
        "fence_records"
    ];
    for (var array_index = 0;
        array_index < array_length(array_fields);
        array_index++)
    {
        var field_name = array_fields[array_index];
        if (!variable_struct_exists(_game_state, field_name)
        || !is_array(_game_state[$ field_name]))
        {
            _game_state[$ field_name] = [];
        }
    }

    if (!variable_struct_exists(_game_state, "daily_resources_gathered")
    || !is_array(_game_state.daily_resources_gathered))
    {
        _game_state.daily_resources_gathered =
            array_create(ResourceId.COUNT, 0);
    }
    while (array_length(_game_state.daily_resources_gathered)
        < ResourceId.COUNT)
    {
        array_push(_game_state.daily_resources_gathered, 0);
    }

    if (!variable_struct_exists(_game_state, "quest_statuses")
    || !is_array(_game_state.quest_statuses))
    {
        _game_state.quest_statuses =
            array_create(QuestId.COUNT, QuestStatus.LOCKED);
    }
    while (array_length(_game_state.quest_statuses) < QuestId.COUNT)
    {
        var missing_quest_id = array_length(_game_state.quest_statuses);
        array_push(
            _game_state.quest_statuses,
            game_state_infer_quest_status(missing_quest_id, _game_state)
        );
    }
    for (var quest_id = 0; quest_id < QuestId.COUNT; quest_id++)
    {
        if (!quest_status_is_valid(_game_state.quest_statuses[quest_id]))
        {
            _game_state.quest_statuses[quest_id] =
                game_state_infer_quest_status(quest_id, _game_state);
        }
    }

    if (!variable_struct_exists(_game_state, "homestead_stage"))
    {
        _game_state.homestead_stage = homestead_stage_infer(_game_state);
    }
    else
    {
        _game_state.homestead_stage = homestead_stage_sanitize(
            _game_state.homestead_stage,
            _game_state
        );
    }

    task_state_ensure(_game_state);
    return _game_state;
}

function game_state_ensure()
{
    if (!variable_global_exists("game_state")
    || !is_struct(global.game_state))
    {
        global.game_state = game_state_create_default();
    }

    return game_state_normalize(global.game_state);
}
