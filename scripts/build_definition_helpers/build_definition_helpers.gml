/// Build-piece catalog and the authored cabin-site blueprint.

function build_resource_piece_type(_resource_id)
{
    switch (_resource_id)
    {
        case ResourceId.FENCE_STRAIGHT:
            return FencePieceType.STRAIGHT;
        case ResourceId.FENCE_CORNER:
            return FencePieceType.CORNER;
        case ResourceId.FENCE_GATE:
            return FencePieceType.GATE;
    }
    return FencePieceType.LEGACY;
}

function build_piece_resource_id(_piece_type)
{
    switch (_piece_type)
    {
        case FencePieceType.STRAIGHT:
            return ResourceId.FENCE_STRAIGHT;
        case FencePieceType.CORNER:
            return ResourceId.FENCE_CORNER;
        case FencePieceType.GATE:
            return ResourceId.FENCE_GATE;
    }
    return -1;
}

function build_record_effective_piece_type(_records, _index)
{
    var record = _records[_index];
    var piece_type = fence_record_piece_type(record);
    if (piece_type != FencePieceType.LEGACY) return piece_type;
    if (fence_record_gate_part(record) != FenceGatePart.NONE)
        return FencePieceType.GATE;

    var mask = fence_neighbor_mask(_records, _index);
    var is_corner =
        mask == (FenceNeighbor.EAST | FenceNeighbor.SOUTH)
        || mask == (FenceNeighbor.WEST | FenceNeighbor.SOUTH)
        || mask == (FenceNeighbor.EAST | FenceNeighbor.NORTH)
        || mask == (FenceNeighbor.WEST | FenceNeighbor.NORTH);
    return is_corner
        ? FencePieceType.CORNER
        : FencePieceType.STRAIGHT;
}

function build_resource_is_placeable(_resource_id)
{
    return build_resource_piece_type(_resource_id)
        != FencePieceType.LEGACY;
}

function build_piece_sprite(_piece_type, _orientation)
{
    var orientation = ((_orientation mod 4) + 4) mod 4;

    if (_piece_type == FencePieceType.GATE)
        return spr_fence_gate;

    if (_piece_type == FencePieceType.CORNER)
    {
        switch (orientation)
        {
            case FenceRotation.RIGHT: return spr_top_right_fence_corner;
            case FenceRotation.BACK: return spr_right_fence_corner;
            case FenceRotation.LEFT: return spr_left_fence_corner;
        }
        return spr_top_left_fence_corner;
    }

    switch (orientation)
    {
        case FenceRotation.RIGHT: return spr_rightside_fence;
        case FenceRotation.BACK: return spr_back_fence;
        case FenceRotation.LEFT: return spr_leftside_fence;
    }
    return spr_front_fence;
}

function cabin_blueprint_socket(
    _id,
    _x,
    _y,
    _piece_type,
    _orientation,
    _span = 1
)
{
    return {
        id: _id,
        x: _x,
        y: _y,
        piece_type: _piece_type,
        orientation: _orientation,
        span: _span
    };
}

function cabin_blueprint_sockets_at(_site_x, _site_y)
{
    var bounds = cabin_fence_plot_bounds_at(_site_x, _site_y);
    var grid = fence_grid_size();
    var result = [
        cabin_blueprint_socket(
            "top_left", bounds.min_x, bounds.min_y,
            FencePieceType.CORNER, FenceRotation.FRONT
        ),
        cabin_blueprint_socket(
            "top_right", bounds.max_x, bounds.min_y,
            FencePieceType.CORNER, FenceRotation.RIGHT
        ),
        cabin_blueprint_socket(
            "bottom_right", bounds.max_x, bounds.max_y,
            FencePieceType.CORNER, FenceRotation.BACK
        ),
        cabin_blueprint_socket(
            "bottom_left", bounds.min_x, bounds.max_y,
            FencePieceType.CORNER, FenceRotation.LEFT
        )
    ];

    for (var x_index = 1; x_index <= 3; x_index++)
    {
        array_push(
            result,
            cabin_blueprint_socket(
                "back_" + string(x_index),
                bounds.min_x + x_index * grid,
                bounds.min_y,
                FencePieceType.STRAIGHT,
                FenceRotation.BACK
            )
        );
    }

    for (var y_index = 1; y_index <= 3; y_index++)
    {
        array_push(
            result,
            cabin_blueprint_socket(
                "left_" + string(y_index),
                bounds.min_x,
                bounds.min_y + y_index * grid,
                FencePieceType.STRAIGHT,
                FenceRotation.LEFT
            )
        );
        array_push(
            result,
            cabin_blueprint_socket(
                "right_" + string(y_index),
                bounds.max_x,
                bounds.min_y + y_index * grid,
                FencePieceType.STRAIGHT,
                FenceRotation.RIGHT
            )
        );
    }

    array_push(
        result,
        cabin_blueprint_socket(
            "front_straight",
            bounds.min_x + grid * 3,
            bounds.max_y,
            FencePieceType.STRAIGHT,
            FenceRotation.FRONT
        )
    );
    array_push(
        result,
        cabin_blueprint_socket(
            "front_gate",
            bounds.min_x + grid,
            bounds.max_y,
            FencePieceType.GATE,
            FenceRotation.FRONT,
            2
        )
    );
    return result;
}

function cabin_blueprint_sockets(_game_state = undefined)
{
    var game_state = is_undefined(_game_state)
        ? game_state_read()
        : _game_state;
    if (!game_state.cabin_site_placed) return [];
    return cabin_blueprint_sockets_at(
        game_state.cabin_site_x,
        game_state.cabin_site_y
    );
}

function cabin_blueprint_socket_at(
    _x,
    _y,
    _game_state = undefined
)
{
    var sockets = cabin_blueprint_sockets(_game_state);
    var grid = fence_grid_size();
    for (var index = 0; index < array_length(sockets); index++)
    {
        var socket = sockets[index];
        if (socket.y == _y
        && (_x == socket.x
            || (socket.span == 2 && _x == socket.x + grid)))
        {
            return socket;
        }
    }
    return undefined;
}

function cabin_blueprint_socket_by_id(
    _socket_id,
    _game_state = undefined
)
{
    if (!is_string(_socket_id) || _socket_id == "")
        return undefined;

    var sockets = cabin_blueprint_sockets(_game_state);
    for (var index = 0; index < array_length(sockets); index++)
    {
        if (sockets[index].id == _socket_id)
            return sockets[index];
    }
    return undefined;
}
