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
