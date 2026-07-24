/// Provisional fence placement, gate editing, and enclosure removal transactions.

function fence_make_rectangle_records(
    _room_name,
    _first_x,
    _first_y,
    _second_x,
    _second_y,
    _purpose = ""
)
{
    var records = [];
    var grid = fence_grid_size();
    var min_x = min(_first_x, _second_x);
    var max_x = max(_first_x, _second_x);
    var min_y = min(_first_y, _second_y);
    var max_y = max(_first_y, _second_y);

    if (min_x == max_x || min_y == max_y)
    {
        return records;
    }

    for (var x_position = min_x;
        x_position <= max_x;
        x_position += grid)
    {
        array_push(
            records,
            fence_record_create(
                _room_name,
                x_position,
                min_y,
                FenceGatePart.NONE,
                _purpose
            )
        );
        array_push(
            records,
            fence_record_create(
                _room_name,
                x_position,
                max_y,
                FenceGatePart.NONE,
                _purpose
            )
        );
    }

    for (var y_position = min_y + grid;
        y_position < max_y;
        y_position += grid)
    {
        array_push(
            records,
            fence_record_create(
                _room_name,
                min_x,
                y_position,
                FenceGatePart.NONE,
                _purpose
            )
        );
        array_push(
            records,
            fence_record_create(
                _room_name,
                max_x,
                y_position,
                FenceGatePart.NONE,
                _purpose
            )
        );
    }

    return records;
}

function fence_try_add_rectangle(
    _records,
    _room_name,
    _first_x,
    _first_y,
    _second_x,
    _second_y,
    _outside_gate_count = 0,
    _purpose = ""
)
{
    var rectangle = fence_make_rectangle_records(
        _room_name,
        _first_x,
        _first_y,
        _second_x,
        _second_y,
        _purpose
    );

    if (array_length(rectangle) == 0)
    {
        return {
            valid: false,
            message: "Choose an opposite corner with both width and height.",
            records: fence_copy_records(_records)
        };
    }

    var candidate = fence_copy_records(_records);

    for (var rectangle_index = 0;
        rectangle_index < array_length(rectangle);
        rectangle_index++)
    {
        var record = rectangle[rectangle_index];

        if (fence_find_record(candidate, record.x, record.y) != -1)
        {
            return {
                valid: false,
                message: "That enclosure overlaps an existing fence.",
                records: fence_copy_records(_records)
            };
        }

        array_push(candidate, fence_copy_record(record));
    }

    var status = fence_layout_status(candidate, _outside_gate_count);

    if (!status.valid)
    {
        return {
            valid: false,
            message: status.message,
            records: fence_copy_records(_records)
        };
    }

    return {
        valid: true,
        message: "Rectangle ready to place.",
        records: candidate
    };
}

function fence_try_place_gate(
    _records,
    _room_name,
    _x,
    _y,
    _outside_gate_count = 0,
    _purpose = ""
)
{
    if (fence_count_gates(_records) + _outside_gate_count >= 1)
    {
        return {
            valid: false,
            message: "Only one gate is supported. Remove the existing gate first.",
            records: fence_copy_records(_records),
            gate_x: _x,
            gate_y: _y
        };
    }

    var grid = fence_grid_size();
    var clicked_index = fence_find_record(_records, _x, _y);

    if (clicked_index == -1)
    {
        return {
            valid: false,
            message: "Click a straight horizontal side to install the gate.",
            records: fence_copy_records(_records),
            gate_x: _x,
            gate_y: _y
        };
    }

    var required_mask = FenceNeighbor.EAST | FenceNeighbor.WEST;
    var candidate_left_positions = [_x, _x - grid];

    for (var position_index = 0;
        position_index < array_length(candidate_left_positions);
        position_index++)
    {
        var left_x = candidate_left_positions[position_index];
        var left_index = fence_find_record(_records, left_x, _y);
        var right_index = fence_find_record(_records, left_x + grid, _y);

        if (left_index == -1 || right_index == -1)
        {
            continue;
        }

        if (fence_record_gate_part(_records[left_index]) != FenceGatePart.NONE
        || fence_record_gate_part(_records[right_index]) != FenceGatePart.NONE
        || fence_neighbor_mask(_records, left_index) != required_mask
        || fence_neighbor_mask(_records, right_index) != required_mask)
        {
            continue;
        }

        var result = fence_try_place(
            _records,
            _room_name,
            left_x,
            _y,
            true,
            _outside_gate_count,
            _purpose
        );

        return {
            valid: result.valid,
            message: result.valid
                ? "Gate ready to install."
                : result.message,
            records: result.records,
            gate_x: left_x,
            gate_y: _y
        };
    }

    return {
        valid: false,
        message: "The gate needs two neighboring straight horizontal fence cells.",
        records: fence_copy_records(_records),
        gate_x: _x,
        gate_y: _y
    };
}

function fence_remove_gate_at(_records, _x, _y)
{
    var selected_index = fence_find_record(_records, _x, _y);

    if (selected_index == -1
    || fence_record_gate_part(_records[selected_index]) == FenceGatePart.NONE)
    {
        return {
            removed: false,
            message: "There is no gate in that grid cell.",
            records: fence_copy_records(_records)
        };
    }

    var selected = _records[selected_index];
    var left_x = fence_record_gate_part(selected) == FenceGatePart.LEFT
        ? selected.x
        : selected.x - fence_grid_size();
    var right_x = left_x + fence_grid_size();
    var result = [];

    for (var i = 0; i < array_length(_records); i++)
    {
        var record = _records[i];
        var replace_gate_cell = record.y == selected.y
            && (record.x == left_x || record.x == right_x);

        array_push(
            result,
            replace_gate_cell
                ? fence_record_create(
                    record.room_name,
                    record.x,
                    record.y,
                    FenceGatePart.NONE,
                    fence_record_purpose(record)
                )
                : fence_copy_record(record)
        );
    }

    return {
        removed: true,
        message: "Gate removed; the fence side was restored.",
        records: result
    };
}

function fence_remove_enclosure_at(_records, _x, _y)
{
    var selected_index = fence_find_record(_records, _x, _y);

    if (selected_index == -1)
    {
        return {
            removed: false,
            message: "There is no enclosure at that grid cell.",
            records: fence_copy_records(_records)
        };
    }

    var component = fence_component_info(_records, selected_index);
    var remove_indices = array_create(array_length(_records), false);

    for (var component_index = 0;
        component_index < array_length(component.indices);
        component_index++)
    {
        remove_indices[component.indices[component_index]] = true;
    }

    var result = [];

    for (var i = 0; i < array_length(_records); i++)
    {
        if (!remove_indices[i])
        {
            array_push(result, fence_copy_record(_records[i]));
        }
    }

    return {
        removed: true,
        message: "Enclosure removed.",
        records: result
    };
}

function fence_try_place(
    _records,
    _room_name,
    _x,
    _y,
    _gate_mode,
    _outside_gate_count = 0,
    _purpose = ""
)
{
    var grid = fence_grid_size();
    var current_index = fence_find_record(_records, _x, _y);
    var candidate = fence_copy_records(_records);

    if (!_gate_mode)
    {
        if (current_index != -1)
        {
            return {
                valid: false,
                message: "That grid cell already contains fence.",
                records: candidate
            };
        }

        array_push(
            candidate,
            fence_record_create(
                _room_name,
                _x,
                _y,
                FenceGatePart.NONE,
                _purpose
            )
        );
    }
    else
    {
        if (fence_count_gates(_records) + _outside_gate_count >= 1)
        {
            return {
                valid: false,
                message: "Only one gate is supported. Remove the existing gate first.",
                records: candidate
            };
        }

        var east_index = fence_find_record(_records, _x + grid, _y);
        var both_empty = current_index == -1 && east_index == -1;
        var both_normal = current_index != -1
            && east_index != -1
            && fence_record_gate_part(candidate[current_index]) == FenceGatePart.NONE
            && fence_record_gate_part(candidate[east_index]) == FenceGatePart.NONE;

        if (!both_empty && !both_normal)
        {
            return {
                valid: false,
                message: "A gate needs the clicked cell and the cell immediately to its right.",
                records: candidate
            };
        }

        if (both_empty)
        {
            array_push(
                candidate,
                fence_record_create(
                    _room_name,
                    _x,
                    _y,
                    FenceGatePart.LEFT,
                    _purpose
                )
            );
            array_push(
                candidate,
                fence_record_create(
                    _room_name,
                    _x + grid,
                    _y,
                    FenceGatePart.RIGHT,
                    _purpose
                )
            );
        }
        else
        {
            // Rebuild the pair as new plain records. This is reliable on VM
            // and YYC targets even when struct accessors are copy-on-write.
            var converted = [];

            for (var convert_index = 0;
                convert_index < array_length(candidate);
                convert_index++)
            {
                var convert_record = candidate[convert_index];

                if (convert_index == current_index)
                {
                    array_push(
                        converted,
                        fence_record_create(
                            convert_record.room_name,
                            convert_record.x,
                            convert_record.y,
                            FenceGatePart.LEFT,
                            fence_record_purpose(convert_record)
                        )
                    );
                }
                else if (convert_index == east_index)
                {
                    array_push(
                        converted,
                        fence_record_create(
                            convert_record.room_name,
                            convert_record.x,
                            convert_record.y,
                            FenceGatePart.RIGHT,
                            fence_record_purpose(convert_record)
                        )
                    );
                }
                else
                {
                    array_push(converted, fence_copy_record(convert_record));
                }
            }

            candidate = converted;
        }
    }

    var junction_status = fence_junction_status(candidate);

    if (!junction_status.valid)
    {
        return {
            valid: false,
            message: junction_status.message,
            records: fence_copy_records(_records)
        };
    }

    return {
        valid: true,
        message: _gate_mode
            ? "Gate placed provisionally."
            : "Fence placed provisionally.",
        records: candidate
    };
}

function fence_remove_at(_records, _x, _y)
{
    var remove_index = fence_find_record(_records, _x, _y);

    if (remove_index == -1)
    {
        return {
            removed: false,
            message: "There is no planned fence in that grid cell.",
            records: fence_copy_records(_records)
        };
    }

    var selected = _records[remove_index];
    var selected_part = fence_record_gate_part(selected);
    var partner_x = selected.x;
    var partner_y = selected.y;

    if (selected_part == FenceGatePart.LEFT)
    {
        partner_x += fence_grid_size();
    }
    else if (selected_part == FenceGatePart.RIGHT)
    {
        partner_x -= fence_grid_size();
    }

    var result = [];

    for (var i = 0; i < array_length(_records); i++)
    {
        var record = _records[i];
        var remove_selected = record.x == selected.x && record.y == selected.y;
        var remove_partner = selected_part != FenceGatePart.NONE
            && record.x == partner_x
            && record.y == partner_y;

        if (!remove_selected && !remove_partner)
        {
            array_push(result, fence_copy_record(record));
        }
    }

    return {
        removed: true,
        message: selected_part == FenceGatePart.NONE
            ? "Fence removed provisionally."
            : "Gate removed provisionally.",
        records: result
    };
}
