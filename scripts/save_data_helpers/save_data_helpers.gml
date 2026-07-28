/// Plain array and inventory copy/hydration utilities.

function save_clone_array(_source)
{
    var result = array_create(array_length(_source), 0);

    for (var i = 0; i < array_length(_source); i++)
    {
        result[i] = _source[i];
    }

    return result;
}

function save_copy_amounts(_inventory)
{
    return save_clone_array(_inventory.amounts);
}

/// Room instances exist before every placed instance has necessarily finished
/// its Create Event. A startup save must never read unfinished vehicle state.
function save_copy_vehicle_cargo(_vehicle)
{
    if (!instance_exists(_vehicle)
    || !variable_instance_exists(_vehicle, "cargo_inventory"))
    {
        return array_create(ResourceId.COUNT, 0);
    }

    var cargo = _vehicle.cargo_inventory;
    if (!is_struct(cargo)
    || !variable_struct_exists(cargo, "amounts")
    || !is_array(cargo.amounts))
    {
        return array_create(ResourceId.COUNT, 0);
    }

    return save_copy_amounts(cargo);
}

function save_copy_resource_capacities(_inventory)
{
    inventory_ensure_size(_inventory);
    return save_clone_array(_inventory.resource_capacities);
}

function save_apply_amounts(_inventory, _amounts)
{
    for (var i = 0; i < min(array_length(_inventory.amounts), array_length(_amounts)); i++)
    {
        _inventory.amounts[i] = _amounts[i];
    }
}

function save_apply_resource_capacities(_inventory, _capacities)
{
    inventory_ensure_size(_inventory);

    for (var i = 0;
        i < min(
            array_length(_inventory.resource_capacities),
            array_length(_capacities)
        );
        i++)
    {
        _inventory.resource_capacities[i] = _capacities[i];
    }
}
