/// Read-only build inventory, blueprint occupancy, and placement validation.

function build_get_inventory_rows(_game_state = undefined)
{
    var game_state = is_undefined(_game_state)
        ? game_state_read()
        : _game_state;
    var result = [];
    for (var resource_id = 0;
        resource_id < ResourceId.COUNT;
        resource_id++)
    {
        if (build_resource_is_placeable(resource_id))
        {
            array_push(result, {
                resource_id: resource_id,
                amount: inventory_get_amount(
                    game_state.player_inventory,
                    resource_id
                )
            });
        }
    }
    return result;
}

function cabin_blueprint_socket_is_filled(
    _socket,
    _game_state = undefined
)
{
    var game_state = is_undefined(_game_state)
        ? game_state_read()
        : _game_state;
    for (var index = 0;
        index < array_length(game_state.fence_records);
        index++)
    {
        var record = game_state.fence_records[index];
        if (record.room_name == game_state.cabin_site_room
        && fence_record_blueprint_socket_id(record) == _socket.id
        && fence_record_piece_type(record) == _socket.piece_type)
        {
            return true;
        }
    }
    return false;
}

function cabin_blueprint_status(_game_state = undefined)
{
    var game_state = is_undefined(_game_state)
        ? game_state_read()
        : _game_state;
    var sockets = cabin_blueprint_sockets(game_state);
    var filled = 0;
    for (var index = 0; index < array_length(sockets); index++)
    {
        if (cabin_blueprint_socket_is_filled(sockets[index], game_state))
            filled += 1;
    }
    return {
        filled: filled,
        total: array_length(sockets),
        complete: array_length(sockets) > 0
            && filled == array_length(sockets)
    };
}

function cabin_blueprint_missing_piece_count(
    _piece_type,
    _game_state = undefined
)
{
    var game_state = is_undefined(_game_state)
        ? game_state_read()
        : _game_state;
    var sockets = cabin_blueprint_sockets(game_state);
    var missing = 0;
    for (var index = 0; index < array_length(sockets); index++)
    {
        var socket = sockets[index];
        if (socket.piece_type == _piece_type
        && !cabin_blueprint_socket_is_filled(socket, game_state))
        {
            missing += 1;
        }
    }
    return missing;
}

function cabin_blueprint_nearest_open_socket(
    _x,
    _y,
    _piece_type,
    _maximum_distance = 44,
    _game_state = undefined
)
{
    var game_state = is_undefined(_game_state)
        ? game_state_read()
        : _game_state;
    var sockets = cabin_blueprint_sockets(game_state);
    var nearest = undefined;
    var nearest_distance = max(0, _maximum_distance);

    for (var index = 0; index < array_length(sockets); index++)
    {
        var socket = sockets[index];
        if (socket.piece_type != _piece_type
        || cabin_blueprint_socket_is_filled(socket, game_state))
        {
            continue;
        }

        var distance = point_distance(_x, _y, socket.x, socket.y);
        if (distance <= nearest_distance)
        {
            nearest = socket;
            nearest_distance = distance;
        }
    }
    return nearest;
}

function cabin_blueprint_recommended_resource(
    _game_state = undefined
)
{
    var game_state = is_undefined(_game_state)
        ? game_state_read()
        : _game_state;
    var sockets = cabin_blueprint_sockets(game_state);
    for (var index = 0; index < array_length(sockets); index++)
    {
        var socket = sockets[index];
        if (cabin_blueprint_socket_is_filled(socket, game_state))
            continue;

        var resource_id = build_piece_resource_id(socket.piece_type);
        if (resource_id >= 0
        && inventory_get_amount(
            game_state.player_inventory,
            resource_id
        ) > 0)
        {
            return resource_id;
        }
    }
    return -1;
}

function build_placement_status(
    _resource_id,
    _orientation,
    _x,
    _y,
    _game_state = undefined
)
{
    var game_state = is_undefined(_game_state)
        ? game_state_read()
        : _game_state;
    var piece_type = build_resource_piece_type(_resource_id);
    var grid_x = fence_snap_to_grid(_x);
    var grid_y = fence_snap_to_grid(_y);
    var room_name = room_get_name(room);
    var room_records = fence_records_for_room(
        game_state.fence_records,
        room_name
    );
    var socket = undefined;

    if (piece_type == FencePieceType.LEGACY)
        return {valid: false, message: "That item cannot be placed.", x: grid_x, y: grid_y, socket: socket};
    if (inventory_get_amount(
        game_state.player_inventory,
        _resource_id
    ) <= 0)
        return {valid: false, message: "No carried piece remains.", x: grid_x, y: grid_y, socket: socket};

    if (task_is_active(TaskId.BUILD_CABIN_FENCE, game_state))
    {
        if (room_name != game_state.cabin_site_room)
            return {valid: false, message: "The tutorial fence belongs at the selected cabin site.", x: grid_x, y: grid_y, socket: socket};
        socket = cabin_blueprint_socket_at(grid_x, grid_y, game_state);
        if (is_undefined(socket))
            return {valid: false, message: "Place this piece on the cabin silhouette.", x: grid_x, y: grid_y, socket: socket};
        grid_x = socket.x;
        grid_y = socket.y;
        if (socket.piece_type != piece_type)
            return {valid: false, message: "That silhouette needs a different fence piece.", x: grid_x, y: grid_y, socket: socket};
        if (socket.orientation != _orientation)
            return {valid: false, message: "Press R until the piece matches the silhouette.", x: grid_x, y: grid_y, socket: socket};
        if (cabin_blueprint_socket_is_filled(socket, game_state))
            return {valid: false, message: "That silhouette is already filled.", x: grid_x, y: grid_y, socket: socket};
    }
    else if (!game_state.free_build_unlocked)
    {
        return {valid: false, message: "Free building unlocks after the cabin task.", x: grid_x, y: grid_y, socket: socket};
    }

    if (fence_find_record(room_records, grid_x, grid_y) != -1)
        return {valid: false, message: "That grid cell already contains fence.", x: grid_x, y: grid_y, socket: socket};
    if (piece_type == FencePieceType.GATE
    && fence_find_record(room_records, grid_x + fence_grid_size(), grid_y) != -1)
        return {valid: false, message: "A gate needs two clear cells.", x: grid_x, y: grid_y, socket: socket};

    var candidate = fence_copy_records(room_records);
    array_push(
        candidate,
        fence_record_create(
            room_name,
            grid_x,
            grid_y,
            piece_type == FencePieceType.GATE
                ? FenceGatePart.LEFT
                : FenceGatePart.NONE,
            "",
            piece_type,
            _orientation
        )
    );
    if (piece_type == FencePieceType.GATE)
    {
        array_push(
            candidate,
            fence_record_create(
                room_name,
                grid_x + fence_grid_size(),
                grid_y,
                FenceGatePart.RIGHT,
                "",
                piece_type,
                _orientation
            )
        );
    }
    var topology = fence_junction_status(candidate);
    if (!topology.valid)
        return {valid: false, message: topology.message, x: grid_x, y: grid_y, socket: socket};

    return {valid: true, message: "Place piece", x: grid_x, y: grid_y, socket: socket};
}
