/// Fence connectivity, enclosure topology, and cabin-boundary validation.

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

function cabin_fence_plot_bounds_at(_site_x, _site_y)
{
    var grid = fence_grid_size();
    var site_x = fence_snap_to_grid(_site_x);
    var site_y = fence_snap_to_grid(_site_y);

    return {
        min_x: site_x - grid * 2,
        max_x: site_x + grid * 2,
        min_y: site_y - grid * 2,
        max_y: site_y + grid * 3
    };
}

function cabin_fence_plot_bounds()
{
    var game_state = game_state_ensure();
    return cabin_fence_plot_bounds_at(
        game_state.cabin_site_x,
        game_state.cabin_site_y
    );
}

function cabin_fence_point_is_corner(_x, _y, _bounds)
{
    return (_x == _bounds.min_x || _x == _bounds.max_x)
        && (_y == _bounds.min_y || _y == _bounds.max_y);
}

function cabin_fence_point_is_opposite_corner(
    _x,
    _y,
    _anchor_x,
    _anchor_y,
    _bounds
)
{
    if (!cabin_fence_point_is_corner(_x, _y, _bounds))
    {
        return false;
    }

    return _x != _anchor_x && _y != _anchor_y;
}

function cabin_fence_plot_status(_records, _room_name, _bounds)
{
    var cabin_records = fence_records_for_purpose(
        _records,
        FENCE_PURPOSE_CABIN_SITE,
        _room_name
    );

    if (array_length(cabin_records) == 0)
    {
        return {
            valid: false,
            message: "Step 1: click one highlighted corner, then its opposite corner.",
            component_count: 0,
            gate_count: 0
        };
    }

    var layout = fence_layout_status(cabin_records, 0);

    if (!layout.valid)
    {
        return layout;
    }

    if (layout.component_count != 1)
    {
        return {
            valid: false,
            message: "The cabin boundary must be one enclosure.",
            component_count: layout.component_count,
            gate_count: layout.gate_count
        };
    }

    var component = fence_component_info(cabin_records, 0);

    if (component.min_x != _bounds.min_x
    || component.max_x != _bounds.max_x
    || component.min_y != _bounds.min_y
    || component.max_y != _bounds.max_y)
    {
        return {
            valid: false,
            message: "Use the highlighted boundary exactly; its size is fixed for this task.",
            component_count: 1,
            gate_count: layout.gate_count
        };
    }

    if (layout.gate_count != 1)
    {
        return {
            valid: false,
            message: "Step 2: press G, then place one gate on the highlighted front side.",
            component_count: 1,
            gate_count: layout.gate_count
        };
    }

    for (var gate_index = 0;
        gate_index < array_length(cabin_records);
        gate_index++)
    {
        var record = cabin_records[gate_index];

        if (fence_record_gate_part(record) != FenceGatePart.NONE
        && record.y != _bounds.max_y)
        {
            return {
                valid: false,
                message: "The cabin gate belongs on the front (south) side of the yard.",
                component_count: 1,
                gate_count: layout.gate_count
            };
        }
    }

    return {
        valid: true,
        message: "Boundary and front gate are ready. Press F to finish the task.",
        component_count: 1,
        gate_count: 1
    };
}
