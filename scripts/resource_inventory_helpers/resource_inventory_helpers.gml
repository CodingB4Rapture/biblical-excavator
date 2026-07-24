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
                is_finished_craft: false,
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
                is_finished_craft: false,
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
                is_finished_craft: false,
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
                is_finished_craft: false,
                world_sprite: spr_stump,
                crush_result_id: -1,
                crush_result_amount: 0,
                delivery_result_id: ResourceId.SMALL_LUMBER
            };
        }

        case ResourceId.TIMBER_PLANK:
        {
            return {
                name: "Timber Plank",
                world_name: "Timber Plank",
                category: ResourceCategory.LUMBER,
                size: ResourceSize.SMALL,
                can_pocket: true,
                can_vehicle_carry: false,
                can_winch: false,
                is_finished_craft: true,
                // The chest menu draws a simple board preview until dedicated
                // plank art is supplied.
                world_sprite: -1,
                crush_result_id: -1,
                crush_result_amount: 0,
                delivery_result_id: -1
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
        is_finished_craft: false,
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

function inventory_create(_capacity, _resource_capacities = undefined)
{
    var resource_capacities = array_create(ResourceId.COUNT, -1);
    if (is_array(_resource_capacities))
    {
        for (var capacity_index = 0;
            capacity_index < min(
                ResourceId.COUNT,
                array_length(_resource_capacities)
            );
            capacity_index++)
        {
            resource_capacities[capacity_index] =
                _resource_capacities[capacity_index];
        }
    }

    return {
        capacity: _capacity,
        amounts: array_create(ResourceId.COUNT, 0),
        resource_capacities: resource_capacities
    };
}

function inventory_create_player()
{
    var inventory = inventory_create(-1);
    inventory.resource_capacities[ResourceId.FIELDSTONE] =
        PLAYER_FIELDSTONE_CAPACITY;
    inventory.resource_capacities[ResourceId.TIMBER_PLANK] =
        PLAYER_TIMBER_PLANK_CAPACITY;
    return inventory;
}

function inventory_create_vehicle()
{
    var inventory = inventory_create(VEHICLE_FIELDSTONE_CAPACITY);
    inventory.resource_capacities[ResourceId.FIELDSTONE] =
        VEHICLE_FIELDSTONE_CAPACITY;
    return inventory;
}

function inventory_create_finished_crafts()
{
    var inventory = inventory_create(-1);
    inventory.amounts[ResourceId.TIMBER_PLANK] = CABIN_TIMBER_PLANK_COST;
    return inventory;
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
    }

    while (array_length(_inventory.amounts) < ResourceId.COUNT)
    {
        array_push(_inventory.amounts, 0);
    }

    if (!variable_struct_exists(_inventory, "resource_capacities")
    || !is_array(_inventory.resource_capacities))
    {
        _inventory.resource_capacities =
            array_create(ResourceId.COUNT, -1);
    }

    while (array_length(_inventory.resource_capacities) < ResourceId.COUNT)
    {
        array_push(_inventory.resource_capacities, -1);
    }

    return _inventory;
}

function inventory_get_resource_capacity(_inventory, _resource_id)
{
    inventory_ensure_size(_inventory);
    return _inventory.resource_capacities[_resource_id];
}

function inventory_set_resource_capacity(_inventory, _resource_id, _capacity)
{
    inventory_ensure_size(_inventory);
    _inventory.resource_capacities[_resource_id] = _capacity;
    return _capacity;
}

/// Applies the baseline without overwriting a larger task-reward upgrade.
function inventory_apply_minimum_resource_capacity(
    _inventory,
    _resource_id,
    _minimum
)
{
    var current = inventory_get_resource_capacity(_inventory, _resource_id);
    return inventory_set_resource_capacity(
        _inventory,
        _resource_id,
        current < 0 ? _minimum : max(current, _minimum)
    );
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

function inventory_get_space(_inventory, _resource_id = -1)
{
    var shared_space = _inventory.capacity < 0
        ? 1000000
        : max(0, _inventory.capacity - inventory_get_total(_inventory));

    if (_resource_id < 0)
    {
        return shared_space;
    }

    var resource_capacity = inventory_get_resource_capacity(
        _inventory,
        _resource_id
    );
    var resource_space = resource_capacity < 0
        ? 1000000
        : max(
            0,
            resource_capacity
                - inventory_get_amount(_inventory, _resource_id)
        );
    return min(shared_space, resource_space);
}

function inventory_can_add(_inventory, _resource_id, _amount)
{
    if (_amount <= 0)
    {
        return true;
    }

    return inventory_get_space(_inventory, _resource_id) >= _amount;
}

function inventory_add(_inventory, _resource_id, _amount)
{
    var amount_to_add = min(
        max(0, _amount),
        inventory_get_space(_inventory, _resource_id)
    );

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
    return inventory_transfer_amount(
        _from,
        _to,
        _resource_id,
        inventory_get_amount(_from, _resource_id)
    );
}

function inventory_transfer_amount(_from, _to, _resource_id, _amount)
{
    var available = inventory_get_amount(_from, _resource_id);
    var amount_to_move = min(
        max(0, _amount),
        available,
        inventory_get_space(_to, _resource_id)
    );

    if (amount_to_move <= 0)
    {
        return 0;
    }

    inventory_remove(_from, _resource_id, amount_to_move);
    inventory_add(_to, _resource_id, amount_to_move);
    return amount_to_move;
}

function finished_crafts_get_rows()
{
    var rows = [];

    for (var resource_id = 0;
        resource_id < ResourceId.COUNT;
        resource_id++)
    {
        if (resource_get_definition(resource_id).is_finished_craft)
            array_push(rows, resource_id);
    }

    return rows;
}

function finished_crafts_take(_game_state, _resource_id, _amount)
{
    if (!is_struct(_game_state)
    || !resource_get_definition(_resource_id).is_finished_craft)
    {
        return 0;
    }

    return inventory_transfer_amount(
        _game_state.finished_crafts_inventory,
        _game_state.player_inventory,
        _resource_id,
        _amount
    );
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
