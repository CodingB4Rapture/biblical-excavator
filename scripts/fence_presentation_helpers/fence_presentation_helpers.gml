/// Fence sprite selection and live room-instance presentation.

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
