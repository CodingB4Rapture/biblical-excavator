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
