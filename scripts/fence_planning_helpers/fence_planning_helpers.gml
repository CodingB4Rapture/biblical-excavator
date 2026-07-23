/// First-version fence planning and persistence helpers.
/// Fence records are plain structs so format-version-one saves stay portable.

function fence_grid_size()
{
    return 32;
}

function fence_snap_to_grid(_value)
{
    var grid = fence_grid_size();
    return floor(_value / grid) * grid + grid * 0.5;
}

function fence_record_create(_room_name, _x, _y, _gate_part = FenceGatePart.NONE)
{
    return {
        room_name: _room_name,
        x: round(_x),
        y: round(_y),
        gate_part: _gate_part
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

function fence_copy_record(_record)
{
    return fence_record_create(
        _record.room_name,
        _record.x,
        _record.y,
        fence_record_gate_part(_record)
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

function fence_neighbor_mask(_records, _index)
{
    var record = _records[_index];
    var grid = fence_grid_size();
    var mask = 0;

    if (fence_find_record(_records, record.x, record.y - grid) != -1)
    {
        mask |= FenceNeighbor.NORTH;
    }

    if (fence_find_record(_records, record.x + grid, record.y) != -1)
    {
        mask |= FenceNeighbor.EAST;
    }

    if (fence_find_record(_records, record.x, record.y + grid) != -1)
    {
        mask |= FenceNeighbor.SOUTH;
    }

    if (fence_find_record(_records, record.x - grid, record.y) != -1)
    {
        mask |= FenceNeighbor.WEST;
    }

    return mask;
}

function fence_neighbor_count(_mask)
{
    var count = 0;
    if ((_mask & FenceNeighbor.NORTH) != 0) count += 1;
    if ((_mask & FenceNeighbor.EAST) != 0) count += 1;
    if ((_mask & FenceNeighbor.SOUTH) != 0) count += 1;
    if ((_mask & FenceNeighbor.WEST) != 0) count += 1;
    return count;
}

function fence_component_info(_records, _start_index)
{
    var record_count = array_length(_records);
    var included = array_create(record_count, false);
    var queue = [_start_index];
    var indices = [];
    var cursor = 0;
    var grid = fence_grid_size();
    var first = _records[_start_index];
    var min_x = first.x;
    var max_x = first.x;
    var min_y = first.y;
    var max_y = first.y;
    included[_start_index] = true;

    while (cursor < array_length(queue))
    {
        var index = queue[cursor];
        cursor += 1;
        array_push(indices, index);

        var record = _records[index];
        min_x = min(min_x, record.x);
        max_x = max(max_x, record.x);
        min_y = min(min_y, record.y);
        max_y = max(max_y, record.y);

        var neighbor_index = fence_find_record(_records, record.x, record.y - grid);
        if (neighbor_index != -1 && !included[neighbor_index])
        {
            included[neighbor_index] = true;
            array_push(queue, neighbor_index);
        }

        neighbor_index = fence_find_record(_records, record.x + grid, record.y);
        if (neighbor_index != -1 && !included[neighbor_index])
        {
            included[neighbor_index] = true;
            array_push(queue, neighbor_index);
        }

        neighbor_index = fence_find_record(_records, record.x, record.y + grid);
        if (neighbor_index != -1 && !included[neighbor_index])
        {
            included[neighbor_index] = true;
            array_push(queue, neighbor_index);
        }

        neighbor_index = fence_find_record(_records, record.x - grid, record.y);
        if (neighbor_index != -1 && !included[neighbor_index])
        {
            included[neighbor_index] = true;
            array_push(queue, neighbor_index);
        }
    }

    return {
        indices: indices,
        min_x: min_x,
        max_x: max_x,
        min_y: min_y,
        max_y: max_y
    };
}

function fence_component_bounds(_records, _index)
{
    return fence_component_info(_records, _index);
}

function fence_count_gates(_records)
{
    var count = 0;

    for (var i = 0; i < array_length(_records); i++)
    {
        if (fence_record_gate_part(_records[i]) == FenceGatePart.LEFT)
        {
            count += 1;
        }
    }

    return count;
}

function fence_count_gates_outside_room(_records, _room_name)
{
    var count = 0;

    for (var i = 0; i < array_length(_records); i++)
    {
        var record = _records[i];

        if (record.room_name != _room_name
        && fence_record_gate_part(record) == FenceGatePart.LEFT)
        {
            count += 1;
        }
    }

    return count;
}

function fence_junction_status(_records)
{
    for (var i = 0; i < array_length(_records); i++)
    {
        var neighbor_count = fence_neighbor_count(fence_neighbor_mask(_records, i));

        if (neighbor_count >= 4)
        {
            return {
                valid: false,
                message: "Crossings are not supported in this fence version."
            };
        }

        if (neighbor_count >= 3)
        {
            return {
                valid: false,
                message: "T-junctions are not supported in this fence version."
            };
        }
    }

    return { valid: true, message: "" };
}

function fence_layout_status(_records, _outside_gate_count = 0)
{
    var count = array_length(_records);

    if (count == 0)
    {
        return {
            valid: true,
            message: "Plan is empty. Press F to save and exit.",
            component_count: 0,
            gate_count: _outside_gate_count
        };
    }

    for (var i = 0; i < count; i++)
    {
        for (var j = i + 1; j < count; j++)
        {
            if (_records[i].x == _records[j].x
            && _records[i].y == _records[j].y)
            {
                return {
                    valid: false,
                    message: "Two fence records occupy the same grid cell.",
                    component_count: 0,
                    gate_count: 0
                };
            }
        }
    }

    var junction_status = fence_junction_status(_records);

    if (!junction_status.valid)
    {
        return {
            valid: false,
            message: junction_status.message,
            component_count: 0,
            gate_count: 0
        };
    }

    for (var degree_index = 0; degree_index < count; degree_index++)
    {
        if (fence_neighbor_count(fence_neighbor_mask(_records, degree_index)) < 2)
        {
            return {
                valid: false,
                message: "Loose ends are provisional only. Close every rectangle before pressing F.",
                component_count: 0,
                gate_count: 0
            };
        }
    }

    var gate_count = fence_count_gates(_records) + _outside_gate_count;

    if (gate_count > 1)
    {
        return {
            valid: false,
            message: "Only one gate is supported in this fence version.",
            component_count: 0,
            gate_count: gate_count
        };
    }

    for (var gate_index = 0; gate_index < count; gate_index++)
    {
        var gate_record = _records[gate_index];
        var gate_part = fence_record_gate_part(gate_record);

        if (gate_part == FenceGatePart.NONE)
        {
            continue;
        }

        var partner_index = (gate_part == FenceGatePart.LEFT)
            ? fence_find_record(
                _records,
                gate_record.x + fence_grid_size(),
                gate_record.y
            )
            : fence_find_record(
                _records,
                gate_record.x - fence_grid_size(),
                gate_record.y
            );
        var expected_partner = (gate_part == FenceGatePart.LEFT)
            ? FenceGatePart.RIGHT
            : FenceGatePart.LEFT;

        if (partner_index == -1
        || fence_record_gate_part(_records[partner_index]) != expected_partner)
        {
            return {
                valid: false,
                message: "The gate must occupy one linked pair of horizontal cells.",
                component_count: 0,
                gate_count: gate_count
            };
        }

        var required_mask = FenceNeighbor.EAST | FenceNeighbor.WEST;

        if (fence_neighbor_mask(_records, gate_index) != required_mask)
        {
            return {
                valid: false,
                message: "The gate must replace two straight horizontal fence cells.",
                component_count: 0,
                gate_count: gate_count
            };
        }
    }

    var visited = array_create(count, false);
    var component_count = 0;
    var grid = fence_grid_size();

    for (var start_index = 0; start_index < count; start_index++)
    {
        if (visited[start_index])
        {
            continue;
        }

        var component = fence_component_info(_records, start_index);
        component_count += 1;

        for (var mark_index = 0;
            mark_index < array_length(component.indices);
            mark_index++)
        {
            visited[component.indices[mark_index]] = true;
        }

        var width_steps = (component.max_x - component.min_x) / grid;
        var height_steps = (component.max_y - component.min_y) / grid;

        if (width_steps < 1 || height_steps < 1)
        {
            return {
                valid: false,
                message: "Each enclosure needs both width and height.",
                component_count: component_count,
                gate_count: gate_count
            };
        }

        var expected_count = 2 * (width_steps + height_steps);

        if (array_length(component.indices) != expected_count)
        {
            return {
                valid: false,
                message: "Only closed rectangular enclosures are supported for now.",
                component_count: component_count,
                gate_count: gate_count
            };
        }

        for (var check_x = component.min_x;
            check_x <= component.max_x;
            check_x += grid)
        {
            if (fence_find_record(_records, check_x, component.min_y) == -1
            || fence_find_record(_records, check_x, component.max_y) == -1)
            {
                return {
                    valid: false,
                    message: "Only closed rectangular enclosures are supported for now.",
                    component_count: component_count,
                    gate_count: gate_count
                };
            }
        }

        for (var check_y = component.min_y + grid;
            check_y < component.max_y;
            check_y += grid)
        {
            if (fence_find_record(_records, component.min_x, check_y) == -1
            || fence_find_record(_records, component.max_x, check_y) == -1)
            {
                return {
                    valid: false,
                    message: "Only closed rectangular enclosures are supported for now.",
                    component_count: component_count,
                    gate_count: gate_count
                };
            }
        }
    }

    return {
        valid: true,
        message: "Closed fence plan ready. Press F to save and exit.",
        component_count: component_count,
        gate_count: gate_count
    };
}

function fence_make_rectangle_records(
    _room_name,
    _first_x,
    _first_y,
    _second_x,
    _second_y
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
            fence_record_create(_room_name, x_position, min_y)
        );
        array_push(
            records,
            fence_record_create(_room_name, x_position, max_y)
        );
    }

    for (var y_position = min_y + grid;
        y_position < max_y;
        y_position += grid)
    {
        array_push(
            records,
            fence_record_create(_room_name, min_x, y_position)
        );
        array_push(
            records,
            fence_record_create(_room_name, max_x, y_position)
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
    _outside_gate_count = 0
)
{
    var rectangle = fence_make_rectangle_records(
        _room_name,
        _first_x,
        _first_y,
        _second_x,
        _second_y
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
    _outside_gate_count = 0
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
            _outside_gate_count
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
                    FenceGatePart.NONE
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
    _outside_gate_count = 0
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
            fence_record_create(_room_name, _x, _y, FenceGatePart.NONE)
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
                fence_record_create(_room_name, _x, _y, FenceGatePart.LEFT)
            );
            array_push(
                candidate,
                fence_record_create(
                    _room_name,
                    _x + grid,
                    _y,
                    FenceGatePart.RIGHT
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
                            FenceGatePart.LEFT
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
                            FenceGatePart.RIGHT
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

function fence_sprite_for_record(_records, _index)
{
    var gate_part = fence_record_gate_part(_records[_index]);

    if (gate_part == FenceGatePart.LEFT)
    {
        return spr_fence_gate;
    }

    if (gate_part == FenceGatePart.RIGHT)
    {
        return -1;
    }

    var mask = fence_neighbor_mask(_records, _index);
    var record = _records[_index];
    var bounds = fence_component_bounds(_records, _index);
    var horizontal = FenceNeighbor.EAST | FenceNeighbor.WEST;
    var vertical = FenceNeighbor.NORTH | FenceNeighbor.SOUTH;

    if (mask == horizontal
    || mask == FenceNeighbor.EAST
    || mask == FenceNeighbor.WEST
    || mask == 0)
    {
        return (record.y == bounds.min_y)
            ? spr_back_fence
            : spr_front_fence;
    }

    if (mask == vertical
    || mask == FenceNeighbor.NORTH
    || mask == FenceNeighbor.SOUTH)
    {
        return (record.x == bounds.min_x)
            ? spr_leftside_fence
            : spr_rightside_fence;
    }

    if (mask == (FenceNeighbor.EAST | FenceNeighbor.SOUTH))
    {
        return spr_top_left_fence_corner;
    }

    if (mask == (FenceNeighbor.WEST | FenceNeighbor.SOUTH))
    {
        return spr_top_right_fence_corner;
    }

    if (mask == (FenceNeighbor.EAST | FenceNeighbor.NORTH))
    {
        return spr_left_fence_corner;
    }

    if (mask == (FenceNeighbor.WEST | FenceNeighbor.NORTH))
    {
        return spr_right_fence_corner;
    }

    return spr_front_fence;
}

function fence_refresh_room_instances(_records, _planning = false, _layout_valid = true)
{
    with (obj_fence_piece)
    {
        instance_destroy();
    }

    for (var i = 0; i < array_length(_records); i++)
    {
        var fence_sprite = fence_sprite_for_record(_records, i);

        if (fence_sprite == -1)
        {
            continue;
        }

        var record = _records[i];
        var piece = instance_create_depth(record.x, record.y, 50, obj_fence_piece);
        piece.fence_room_name = record.room_name;
        piece.fence_sprite = fence_sprite;
        piece.draw_offset_x = fence_record_gate_part(record) == FenceGatePart.LEFT
            ? fence_grid_size() * 0.5
            : 0;
        piece.piece_alpha = _planning ? 0.78 : 1;
        piece.piece_colour = (_planning && !_layout_valid)
            ? make_color_rgb(255, 184, 92)
            : c_white;
    }
}

function fence_restore_room()
{
    var game_state = game_state_ensure();
    var room_name = room_get_name(room);
    var records = fence_records_for_room(game_state.fence_records, room_name);
    fence_refresh_room_instances(records, false, true);
    return array_length(records);
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
    fence_refresh_room_instances(_room_records, false, true);
    return true;
}

/// Deterministic regression coverage, invoked only with --fence-tests.
function fence_test_rectangle(
    _room_name,
    _min_x,
    _min_y,
    _width_steps,
    _height_steps
)
{
    return fence_make_rectangle_records(
        _room_name,
        _min_x,
        _min_y,
        _min_x + _width_steps * fence_grid_size(),
        _min_y + _height_steps * fence_grid_size()
    );
}

function fence_test_expect(_condition, _message)
{
    if (_condition)
    {
        show_debug_message("FENCE TEST PASS: " + _message);
        return true;
    }

    show_debug_message("FENCE TEST FAIL: " + _message);
    return false;
}

function fence_planning_run_tests()
{
    var failures = 0;
    var room_name = room_get_name(room);
    var grid = fence_grid_size();
    var min_x = 16;
    var min_y = 16;
    var max_x = min_x + grid * 4;
    var max_y = min_y + grid * 3;
    var target_rectangle = fence_test_rectangle(
        room_name,
        min_x,
        min_y,
        4,
        3
    );
    var rectangle_result = fence_try_add_rectangle(
        [],
        room_name,
        min_x,
        min_y,
        max_x,
        max_y
    );
    var rectangle = rectangle_result.records;

    if (!fence_test_expect(
        rectangle_result.valid
        && array_length(rectangle) == array_length(target_rectangle),
        "two-corner placement builds the complete rectangle"
    )) failures += 1;

    var overlap_result = fence_try_add_rectangle(
        rectangle,
        room_name,
        min_x + grid,
        min_y + grid,
        max_x + grid,
        max_y + grid
    );

    if (!fence_test_expect(
        !overlap_result.valid,
        "an overlapping rectangle is rejected"
    )) failures += 1;

    var rectangle_status = fence_layout_status(rectangle);

    if (!fence_test_expect(
        rectangle_status.valid,
        "closed rectangle validates"
    )) failures += 1;

    var top_left_index = fence_find_record(rectangle, min_x, min_y);
    var top_right_index = fence_find_record(rectangle, max_x, min_y);
    var bottom_left_index = fence_find_record(rectangle, min_x, max_y);
    var bottom_right_index = fence_find_record(rectangle, max_x, max_y);
    var top_straight_index = fence_find_record(rectangle, min_x + grid, min_y);
    var bottom_straight_index = fence_find_record(
        rectangle,
        min_x + grid,
        max_y
    );
    var left_straight_index = fence_find_record(rectangle, min_x, min_y + grid);
    var right_straight_index = fence_find_record(rectangle, max_x, min_y + grid);

    if (!fence_test_expect(
        fence_sprite_for_record(rectangle, top_left_index)
            == spr_top_left_fence_corner
        && fence_sprite_for_record(rectangle, top_right_index)
            == spr_top_right_fence_corner
        && fence_sprite_for_record(rectangle, bottom_left_index)
            == spr_left_fence_corner
        && fence_sprite_for_record(rectangle, bottom_right_index)
            == spr_right_fence_corner,
        "all four corners choose the correct sprites"
    )) failures += 1;

    if (!fence_test_expect(
        fence_sprite_for_record(rectangle, top_straight_index)
            == spr_back_fence
        && fence_sprite_for_record(rectangle, bottom_straight_index)
            == spr_front_fence
        && fence_sprite_for_record(rectangle, left_straight_index)
            == spr_leftside_fence
        && fence_sprite_for_record(rectangle, right_straight_index)
            == spr_rightside_fence,
        "straight sides choose north/east/south/west art"
    )) failures += 1;

    var l_shape = [
        fence_record_create(room_name, min_x, min_y),
        fence_record_create(room_name, min_x + grid, min_y),
        fence_record_create(room_name, min_x, min_y + grid)
    ];
    var l_corner_index = fence_find_record(l_shape, min_x, min_y);
    var corner_before_removal = fence_sprite_for_record(
        l_shape,
        l_corner_index
    );
    var l_removal = fence_remove_at(l_shape, min_x + grid, min_y);
    l_corner_index = fence_find_record(l_removal.records, min_x, min_y);
    var corner_after_removal = fence_sprite_for_record(
        l_removal.records,
        l_corner_index
    );

    if (!fence_test_expect(
        corner_before_removal == spr_top_left_fence_corner
        && corner_after_removal == spr_leftside_fence,
        "neighbor changes automatically update a corner"
    )) failures += 1;

    var removal = fence_remove_at(
        rectangle,
        min_x + grid * 2,
        min_y
    );

    if (!fence_test_expect(
        removal.removed
        && !fence_layout_status(removal.records).valid,
        "removal works and exposes a rejected loose end"
    )) failures += 1;

    var gate_result = fence_try_place_gate(
        rectangle,
        room_name,
        min_x + grid,
        max_y,
        0
    );
    var gate_status = fence_layout_status(gate_result.records);
    var gate_left_index = fence_find_record(
        gate_result.records,
        min_x + grid,
        max_y
    );
    var gate_right_index = fence_find_record(
        gate_result.records,
        min_x + grid * 2,
        max_y
    );

    if (!fence_test_expect(
        gate_result.valid
        && gate_status.valid
        && fence_record_gate_part(gate_result.records[gate_left_index])
            == FenceGatePart.LEFT
        && fence_record_gate_part(gate_result.records[gate_right_index])
            == FenceGatePart.RIGHT
        && fence_sprite_for_record(gate_result.records, gate_left_index)
            == spr_fence_gate
        && fence_sprite_for_record(gate_result.records, gate_right_index) == -1,
        "one two-cell horizontal gate validates and renders once"
    )) failures += 1;

    var second_gate = fence_try_place_gate(
        gate_result.records,
        room_name,
        min_x + grid * 3,
        max_y,
        0
    );

    if (!fence_test_expect(
        !second_gate.valid,
        "a second gate is rejected"
    )) failures += 1;

    var gate_removal = fence_remove_gate_at(
        gate_result.records,
        min_x + grid * 2,
        max_y
    );

    if (!fence_test_expect(
        gate_removal.removed
        && fence_count_gates(gate_removal.records) == 0
        && fence_layout_status(gate_removal.records).valid,
        "right-click gate removal restores the closed fence side"
    )) failures += 1;

    var enclosure_removal = fence_remove_enclosure_at(
        gate_result.records,
        min_x,
        min_y
    );

    if (!fence_test_expect(
        enclosure_removal.removed
        && array_length(enclosure_removal.records) == 0
        && fence_layout_status(enclosure_removal.records).valid,
        "right-click enclosure removal leaves no loose fragments"
    )) failures += 1;

    var t_junction = fence_try_place(
        rectangle,
        room_name,
        min_x + grid,
        min_y + grid,
        false
    );

    if (!fence_test_expect(
        !t_junction.valid,
        "a T-junction is rejected during placement"
    )) failures += 1;

    var crossing = [
        fence_record_create(room_name, 400, 400),
        fence_record_create(room_name, 400, 400 - grid),
        fence_record_create(room_name, 400 + grid, 400),
        fence_record_create(room_name, 400, 400 + grid),
        fence_record_create(room_name, 400 - grid, 400)
    ];

    if (!fence_test_expect(
        !fence_layout_status(crossing).valid,
        "a crossing is rejected"
    )) failures += 1;

    var loose_end = [fence_record_create(room_name, 400, 400)];

    if (!fence_test_expect(
        !fence_layout_status(loose_end).valid,
        "a loose end cannot be committed"
    )) failures += 1;

    var encoded = json_stringify({fence_records: gate_result.records});
    var decoded = json_parse(encoded);
    var restored = fence_copy_records(decoded.fence_records);

    if (!fence_test_expect(
        array_length(restored) == array_length(gate_result.records)
        && fence_layout_status(restored).valid
        && fence_count_gates(restored) == 1,
        "fence records survive a save/load JSON round trip"
    )) failures += 1;

    var legacy_default = game_state_create_default();

    if (!fence_test_expect(
        array_length(legacy_default.fence_records) == 0
        && array_length(fence_copy_records(undefined)) == 0,
        "a legacy save with no fence field safely defaults to an empty plan"
    )) failures += 1;

    var game_state = game_state_ensure();
    var original_records = fence_copy_records(game_state.fence_records);
    game_state.fence_records = restored;
    var restored_piece_count = fence_restore_room();
    var expected_drawn_pieces = array_length(restored) - 1;

    if (!fence_test_expect(
        restored_piece_count == array_length(restored)
        && instance_number(obj_fence_piece) == expected_drawn_pieces,
        "room restoration rebuilds saved pieces and draws the gate once"
    )) failures += 1;

    game_state.fence_records = original_records;
    with (obj_fence_piece) instance_destroy();

    if (failures == 0)
    {
        show_debug_message("FENCE TEST RESULT: PASS");
        return true;
    }

    show_debug_message(
        "FENCE TEST RESULT: FAIL (" + string(failures) + " failures)"
    );
    return false;
}
