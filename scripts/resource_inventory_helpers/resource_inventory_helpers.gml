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
                category: ResourceCategory.ROCK,
                size: ResourceSize.SMALL,
                can_pocket: true,
                can_vehicle_carry: true,
                can_winch: false
            };
        }

        case ResourceId.TIMBER_LOG:
        {
            return {
                name: "Timber Log",
                category: ResourceCategory.LOG,
                size: ResourceSize.LARGE,
                can_pocket: false,
                can_vehicle_carry: false,
                can_winch: true
            };
        }
    }

    return {
        name: "Unknown Resource",
        category: ResourceCategory.ROCK,
        size: ResourceSize.SMALL,
        can_pocket: false,
        can_vehicle_carry: false,
        can_winch: false
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

function game_state_ensure()
{
    if (!variable_global_exists("game_state") || !is_struct(global.game_state))
    {
        global.game_state = {
            player_inventory: inventory_create(6),
            home_inventory: inventory_create(-1),
            trip_rocks_gathered: 0,
            trip_xp_gained: 0,
            equipment_xp: 0,
            completed_deliveries: 0,
            winch_mail_after_deliveries: 3,
            winch_attachment_state: AttachmentState.LOCKED
        };
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
