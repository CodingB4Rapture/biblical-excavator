/// Fence record schema, filtering, copying, and durable room persistence.

function fence_grid_size()
{
    return 32;
}

function fence_snap_to_grid(_value)
{
    var grid = fence_grid_size();
    return floor(_value / grid) * grid + grid * 0.5;
}

function fence_record_create(
    _room_name,
    _x,
    _y,
    _gate_part = FenceGatePart.NONE,
    _purpose = ""
)
{
    return {
        room_name: _room_name,
        x: round(_x),
        y: round(_y),
        gate_part: _gate_part,
        purpose: is_string(_purpose) ? _purpose : ""
    };
}

function fence_record_gate_part(_record)
{
    if (!is_struct(_record)
    || !variable_struct_exists(_record, "gate_part")
    || !is_numeric(_record.gate_part))
    {
        return FenceGatePart.NONE;
    }

    var gate_part = round(_record.gate_part);
    return (gate_part >= FenceGatePart.NONE && gate_part <= FenceGatePart.RIGHT)
        ? gate_part
        : FenceGatePart.NONE;
}

function fence_record_purpose(_record)
{
    if (!is_struct(_record)
    || !variable_struct_exists(_record, "purpose")
    || !is_string(_record.purpose))
    {
        return "";
    }

    return _record.purpose;
}

function fence_copy_record(_record)
{
    return fence_record_create(
        _record.room_name,
        _record.x,
        _record.y,
        fence_record_gate_part(_record),
        fence_record_purpose(_record)
    );
}

function fence_copy_records(_records)
{
    var result = [];

    if (!is_array(_records))
    {
        return result;
    }

    for (var i = 0; i < array_length(_records); i++)
    {
        var record = _records[i];

        if (!is_struct(record)
        || !variable_struct_exists(record, "room_name")
        || !is_string(record.room_name)
        || !variable_struct_exists(record, "x")
        || !is_real(record.x)
        || !variable_struct_exists(record, "y")
        || !is_real(record.y))
        {
            continue;
        }

        array_push(result, fence_copy_record(record));
    }

    return result;
}

function fence_records_for_room(_records, _room_name)
{
    var result = [];

    if (!is_array(_records))
    {
        return result;
    }

    for (var i = 0; i < array_length(_records); i++)
    {
        var record = _records[i];

        if (is_struct(record)
        && variable_struct_exists(record, "room_name")
        && record.room_name == _room_name)
        {
            array_push(result, fence_copy_record(record));
        }
    }

    return result;
}

function fence_records_for_purpose(_records, _purpose, _room_name = "")
{
    var result = [];

    if (!is_array(_records))
    {
        return result;
    }

    for (var i = 0; i < array_length(_records); i++)
    {
        var record = _records[i];

        if (fence_record_purpose(record) == _purpose
        && (_room_name == "" || record.room_name == _room_name))
        {
            array_push(result, fence_copy_record(record));
        }
    }

    return result;
}

function fence_records_without_purpose(_records, _purpose, _room_name = "")
{
    var result = [];

    if (!is_array(_records))
    {
        return result;
    }

    for (var i = 0; i < array_length(_records); i++)
    {
        var record = _records[i];
        var remove_record = fence_record_purpose(record) == _purpose
            && (_room_name == "" || record.room_name == _room_name);

        if (!remove_record)
        {
            array_push(result, fence_copy_record(record));
        }
    }

    return result;
}

function fence_find_record(_records, _x, _y)
{
    for (var i = 0; i < array_length(_records); i++)
    {
        if (_records[i].x == _x && _records[i].y == _y)
        {
            return i;
        }
    }

    return -1;
}

function fence_commit_room_records(_room_name, _room_records)
{
    var game_state = game_state_ensure();
    var merged = [];

    for (var i = 0; i < array_length(game_state.fence_records); i++)
    {
        var record = game_state.fence_records[i];

        if (record.room_name != _room_name)
        {
            array_push(merged, fence_copy_record(record));
        }
    }

    for (var room_index = 0;
        room_index < array_length(_room_records);
        room_index++)
    {
        array_push(merged, fence_copy_record(_room_records[room_index]));
    }

    game_state.fence_records = merged;
    return true;
}
