/// Resource definitions and small, reusable inventory helpers.
///
/// To add another resource later:
/// 1. Add its name to ResourceId.
/// 2. Add one case to resource_get_definition.
/// 3. Give a world object that resource_id.

function resource_get_definition(_resource_id)
{
    switch (_resource_id)
    {
        case ResourceId.FIELDSTONE:
        {
            return {
                name: "Fieldstone",
                world_name: "Fieldstone",
                category: ResourceCategory.STONE,
                size: ResourceSize.SMALL,
                can_pocket: true,
                can_vehicle_carry: true,
                can_winch: false,
                world_sprite: spr_fieldstone,
                crush_result_id: -1,
                crush_result_amount: 0,
                delivery_result_id: ResourceId.FIELDSTONE
            };
        }

        case ResourceId.FIELDROCK:
        {
            return {
                name: "Fieldrock",
                world_name: "Fieldrock",
                category: ResourceCategory.STONE,
                size: ResourceSize.LARGE,
                can_pocket: false,
                can_vehicle_carry: false,
                can_winch: false,
                world_sprite: spr_fieldrock,
                crush_result_id: ResourceId.FIELDSTONE,
                crush_result_amount: 1,
                delivery_result_id: -1
            };
        }

        case ResourceId.TIMBER_LOG:
        {
            return {
                name: "Timber Log",
                world_name: "Downed Tree",
                category: ResourceCategory.LUMBER,
                size: ResourceSize.LARGE,
                can_pocket: false,
                can_vehicle_carry: false,
                can_winch: true,
                world_sprite: spr_downed_tree,
                crush_result_id: -1,
                crush_result_amount: 0,
                delivery_result_id: ResourceId.TIMBER_LOG
            };
        }

        case ResourceId.SMALL_LUMBER:
        {
            return {
                name: "Small Lumber",
                world_name: "Stump",
                category: ResourceCategory.LUMBER,
                size: ResourceSize.LARGE,
                can_pocket: false,
                can_vehicle_carry: false,
                can_winch: true,
                world_sprite: spr_stump,
                crush_result_id: -1,
                crush_result_amount: 0,
                delivery_result_id: ResourceId.SMALL_LUMBER
            };
        }
    }

    return {
        name: "Unknown Resource",
        world_name: "Unknown Resource",
        category: ResourceCategory.STONE,
        size: ResourceSize.SMALL,
        can_pocket: false,
        can_vehicle_carry: false,
        can_winch: false,
        world_sprite: -1,
        crush_result_id: -1,
        crush_result_amount: 0,
        delivery_result_id: -1
    };
}

function resource_get_name(_resource_id)
{
    return resource_get_definition(_resource_id).name;
}

function inventory_create(_capacity)
{
    return {
        capacity: _capacity,
        amounts: array_create(ResourceId.COUNT, 0)
    };
}

function resource_get_world_name(_resource_id)
{
    return resource_get_definition(_resource_id).world_name;
}

function inventory_ensure_size(_inventory)
{
    if (!is_struct(_inventory)) return inventory_create(0);

    if (!variable_struct_exists(_inventory, "capacity"))
    {
        _inventory.capacity = 0;
    }

    if (!variable_struct_exists(_inventory, "amounts") || !is_array(_inventory.amounts))
    {
        _inventory.amounts = array_create(ResourceId.COUNT, 0);
        return _inventory;
    }

    while (array_length(_inventory.amounts) < ResourceId.COUNT)
    {
        array_push(_inventory.amounts, 0);
    }

    return _inventory;
}

function inventory_get_amount(_inventory, _resource_id)
{
    return _inventory.amounts[_resource_id];
}

function inventory_get_total(_inventory)
{
    var total = 0;

    for (var resource_id = 0; resource_id < ResourceId.COUNT; resource_id++)
    {
        total += _inventory.amounts[resource_id];
    }

    return total;
}

function inventory_get_space(_inventory)
{
    if (_inventory.capacity < 0)
    {
        return 1000000;
    }

    return max(0, _inventory.capacity - inventory_get_total(_inventory));
}

function inventory_can_add(_inventory, _resource_id, _amount)
{
    if (_amount <= 0)
    {
        return true;
    }

    return inventory_get_space(_inventory) >= _amount;
}

function inventory_add(_inventory, _resource_id, _amount)
{
    var amount_to_add = min(max(0, _amount), inventory_get_space(_inventory));

    if (amount_to_add <= 0)
    {
        return 0;
    }

    _inventory.amounts[_resource_id] += amount_to_add;
    return amount_to_add;
}

function inventory_remove(_inventory, _resource_id, _amount)
{
    var amount_to_remove = min(max(0, _amount), _inventory.amounts[_resource_id]);

    if (amount_to_remove <= 0)
    {
        return 0;
    }

    _inventory.amounts[_resource_id] -= amount_to_remove;
    return amount_to_remove;
}

function inventory_transfer_resource(_from, _to, _resource_id)
{
    var available = inventory_get_amount(_from, _resource_id);
    var amount_to_move = min(available, inventory_get_space(_to));

    if (amount_to_move <= 0)
    {
        return 0;
    }

    inventory_remove(_from, _resource_id, amount_to_move);
    inventory_add(_to, _resource_id, amount_to_move);
    return amount_to_move;
}

function game_state_create_default()
{
    return {
        player_inventory: inventory_create(6),
        home_inventory: inventory_create(-1),
        tools: {
            axe_owned: false
        },
        tutorial_fieldstones_collected: 0,
        fieldstone_records: [],
        fieldrock_records: [],
        tree_records: [],
        // Legacy format-v1 save key; the value now counts gathered Fieldstones.
        trip_rocks_gathered: 0,
        trip_xp_gained: 0,
        daily_resources_gathered: array_create(ResourceId.COUNT, 0),
        equipment_xp: 0,
        completed_deliveries: 0,
        winch_attachment_state: AttachmentState.LOCKED,
        tutorial_intro_seen: false,
        tutorial_stage: TutorialStage.TALK_TO_FARMER,
        tutorial_hand_stones_spawned: false,
        quest_statuses: array_create(QuestId.COUNT, QuestStatus.LOCKED),
        cabin_placement_unlocked: false,
        cabin_site_placed: false,
        cabin_site_room: "Room1",
        cabin_site_x: 0,
        cabin_site_y: 0,
        homestead_stage: HomesteadStage.TUTORIAL,
        first_hub_hint_pending: false,
        day_number: 1,
        // Minutes since midnight; 1080 is 6:00 PM.
        time_of_day: 1080,
        removed_world_ids: []
    };
}

function homestead_stage_infer(_game_state)
{
    if (!_game_state.cabin_site_placed)
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

    if (!_game_state.cabin_site_placed)
    {
        return HomesteadStage.TUTORIAL;
    }

    return _stage;
}

function homestead_stage_set(_stage)
{
    var game_state = game_state_ensure();
    game_state.homestead_stage = homestead_stage_sanitize(_stage, game_state);
    return game_state.homestead_stage;
}

function homestead_stage_get()
{
    return game_state_ensure().homestead_stage;
}

function game_state_ensure()
{
    if (!variable_global_exists("game_state") || !is_struct(global.game_state))
    {
        global.game_state = game_state_create_default();
    }

    if (!variable_struct_exists(global.game_state, "removed_world_ids"))
    {
        global.game_state.removed_world_ids = [];
    }

    global.game_state.player_inventory = inventory_ensure_size(global.game_state.player_inventory);
    global.game_state.home_inventory = inventory_ensure_size(global.game_state.home_inventory);

    if (!variable_struct_exists(global.game_state, "tools")
    || !is_struct(global.game_state.tools))
    {
        global.game_state.tools = {
            axe_owned: global.game_state.tutorial_stage != TutorialStage.TALK_TO_FARMER
                && global.game_state.tutorial_stage != TutorialStage.TALK_TO_FARMERS_WIFE
                && global.game_state.tutorial_stage != TutorialStage.TRIP_ONE_HAND_FIELDSTONE
        };
    }

    if (!variable_struct_exists(global.game_state.tools, "axe_owned"))
    {
        global.game_state.tools.axe_owned = global.game_state.tutorial_stage != TutorialStage.TALK_TO_FARMER
            && global.game_state.tutorial_stage != TutorialStage.TALK_TO_FARMERS_WIFE
            && global.game_state.tutorial_stage != TutorialStage.TRIP_ONE_HAND_FIELDSTONE;
    }

    if (!variable_struct_exists(global.game_state, "tutorial_fieldstones_collected"))
    {
        global.game_state.tutorial_fieldstones_collected = global.game_state.tools.axe_owned
            ? 6
            : min(
                6,
                inventory_get_amount(global.game_state.player_inventory, ResourceId.FIELDSTONE)
            );
    }

    if (!variable_struct_exists(global.game_state, "tree_records")
    || !is_array(global.game_state.tree_records))
    {
        global.game_state.tree_records = [];
    }

    if (!variable_struct_exists(global.game_state, "fieldrock_records")
    || !is_array(global.game_state.fieldrock_records))
    {
        global.game_state.fieldrock_records = [];
    }

    if (!variable_struct_exists(global.game_state, "fieldstone_records")
    || !is_array(global.game_state.fieldstone_records))
    {
        global.game_state.fieldstone_records = [];
    }

    if (!variable_struct_exists(global.game_state, "quest_statuses"))
    {
        global.game_state.quest_statuses = array_create(
            QuestId.COUNT,
            QuestStatus.LOCKED
        );
        global.game_state.quest_statuses[QuestId.FIRM_FOUNDATION] =
            global.game_state.tutorial_stage == TutorialStage.COMPLETE
                ? QuestStatus.COMPLETE
                : QuestStatus.ACTIVE;
    }

    if (global.game_state.tutorial_stage == TutorialStage.TALK_TO_FARMER)
    {
        global.game_state.quest_statuses[QuestId.FIRM_FOUNDATION] = QuestStatus.LOCKED;
    }

    if (!variable_struct_exists(global.game_state, "cabin_placement_unlocked"))
    {
        global.game_state.cabin_placement_unlocked =
            global.game_state.tutorial_stage == TutorialStage.COMPLETE;
    }

    if (!variable_struct_exists(global.game_state, "cabin_site_placed"))
    {
        global.game_state.cabin_site_placed = false;
    }

    if (!variable_struct_exists(global.game_state, "cabin_site_room"))
    {
        global.game_state.cabin_site_room = "Room1";
    }

    if (!variable_struct_exists(global.game_state, "cabin_site_x"))
    {
        global.game_state.cabin_site_x = 0;
    }

    if (!variable_struct_exists(global.game_state, "cabin_site_y"))
    {
        global.game_state.cabin_site_y = 0;
    }

    // Runtime states created before the calendar feature keep all progress and
    // receive the same safe starting time as a new game.
    if (!variable_struct_exists(global.game_state, "day_number"))
    {
        global.game_state.day_number = 1;
    }

    if (!variable_struct_exists(global.game_state, "time_of_day"))
    {
        global.game_state.time_of_day = 1080;
    }

    if (!variable_struct_exists(global.game_state, "homestead_stage"))
    {
        global.game_state.homestead_stage = homestead_stage_infer(global.game_state);
    }
    else
    {
        global.game_state.homestead_stage = homestead_stage_sanitize(
            global.game_state.homestead_stage,
            global.game_state
        );
    }

    if (!variable_struct_exists(global.game_state, "first_hub_hint_pending"))
    {
        global.game_state.first_hub_hint_pending = false;
    }

    // Earlier tutorial code collected the mail automatically but left the
    // stage at the old WINCH_READY value (now WINCH_PACKAGE_READY).
    if (global.game_state.tutorial_stage == TutorialStage.WINCH_PACKAGE_READY
    && global.game_state.winch_attachment_state == AttachmentState.STORED_AT_HOME)
    {
        global.game_state.tutorial_stage = TutorialStage.WINCH_INSTALL_REQUIRED;
    }

    if (!variable_struct_exists(global.game_state, "daily_resources_gathered"))
    {
        global.game_state.daily_resources_gathered = array_create(ResourceId.COUNT, 0);
    }

    while (array_length(global.game_state.daily_resources_gathered) < ResourceId.COUNT)
    {
        array_push(global.game_state.daily_resources_gathered, 0);
    }

    return global.game_state;
}

function attachment_get_status_text()
{
    var game_state = game_state_ensure();

    switch (game_state.winch_attachment_state)
    {
        case AttachmentState.LOCKED: return "Locked";
        case AttachmentState.MAIL_READY: return "Mail arrived";
        case AttachmentState.STORED_AT_HOME: return "Ready to install";
        case AttachmentState.INSTALLED: return "Installed";
    }

    return "Unknown";
}
