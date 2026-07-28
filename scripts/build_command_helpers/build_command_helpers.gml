/// Explicit build placement/removal events over durable fence records.

function build_is_unlocked(_game_state = undefined)
{
    var game_state = is_undefined(_game_state)
        ? game_state_read()
        : _game_state;
    return task_is_active(TaskId.BUILD_CABIN_FENCE, game_state)
        || game_state.free_build_unlocked;
}

/// Repairs authored cabin-socket metadata from the durable socket ID. Early
/// build saves retained the geometry but could deserialize enum values as
/// LEGACY, making a visibly complete boundary read as unfinished.
function build_repair_cabin_blueprint_records(_game_state)
{
    if (!is_struct(_game_state)
    || !_game_state.cabin_site_placed
    || !is_array(_game_state.fence_records))
    {
        return false;
    }

    var changed = false;
    for (var index = 0;
        index < array_length(_game_state.fence_records);
        index++)
    {
        var record = _game_state.fence_records[index];
        if (!is_struct(record)
        || record.room_name != _game_state.cabin_site_room
        || fence_record_purpose(record) != FENCE_PURPOSE_CABIN_SITE)
        {
            continue;
        }

        var socket_id = fence_record_blueprint_socket_id(record);
        var socket = cabin_blueprint_socket_by_id(
            socket_id,
            _game_state
        );
        if (is_undefined(socket)) continue;

        if (fence_record_piece_type(record) != socket.piece_type
        || fence_record_orientation(record) != socket.orientation)
        {
            record.piece_type = socket.piece_type;
            record.orientation = socket.orientation;
            _game_state.fence_records[index] = record;
            changed = true;
        }
    }
    return changed;
}

function build_place_piece(
    _resource_id,
    _orientation,
    _x,
    _y
)
{
    var game_state = game_state_ensure();
    var status = build_placement_status(
        _resource_id,
        _orientation,
        _x,
        _y,
        game_state
    );
    if (!status.valid) return status;

    var room_name = room_get_name(room);
    var records = fence_records_for_room(
        game_state.fence_records,
        room_name
    );
    var piece_type = build_resource_piece_type(_resource_id);
    var purpose = is_undefined(status.socket)
        ? FENCE_PURPOSE_FREE_BUILD
        : FENCE_PURPOSE_CABIN_SITE;
    var socket_id = is_undefined(status.socket)
        ? ""
        : status.socket.id;

    if (piece_type == FencePieceType.GATE)
    {
        array_push(
            records,
            fence_record_create(
                room_name,
                status.x,
                status.y,
                FenceGatePart.LEFT,
                purpose,
                piece_type,
                _orientation,
                socket_id
            )
        );
        array_push(
            records,
            fence_record_create(
                room_name,
                status.x + fence_grid_size(),
                status.y,
                FenceGatePart.RIGHT,
                purpose,
                piece_type,
                _orientation,
                socket_id
            )
        );
    }
    else
    {
        array_push(
            records,
            fence_record_create(
                room_name,
                status.x,
                status.y,
                FenceGatePart.NONE,
                purpose,
                piece_type,
                _orientation,
                socket_id
            )
        );
    }

    if (!inventory_remove(
        game_state.player_inventory,
        _resource_id,
        1
    ))
    {
        status.valid = false;
        status.message = "The carried piece could not be consumed.";
        return status;
    }

    fence_commit_room_records(room_name, records);
    fence_restore_room();
    game_state = game_state_ensure();
    var blueprint = cabin_blueprint_status(game_state);
    if (task_is_active(TaskId.BUILD_CABIN_FENCE, game_state)
    && blueprint.complete)
    {
        progression_complete_cabin_fence_state(game_state);
        notification_show_hint(
            "Cabin boundary complete. Return to the Task Board.",
            game_get_speed(gamespeed_fps) * 5,
            true
        );
    }
    save_write();
    status.message = "Piece placed.";
    return status;
}

function build_remove_piece_at(_x, _y)
{
    var game_state = game_state_ensure();
    var room_name = room_get_name(room);
    var records = fence_records_for_room(
        game_state.fence_records,
        room_name
    );
    var grid_x = fence_snap_to_grid(_x);
    var grid_y = fence_snap_to_grid(_y);
    var index = fence_find_record(records, grid_x, grid_y);

    if (index < 0)
    {
        return {
            removed: false,
            message: "There is no fence piece in that cell."
        };
    }

    var selected = records[index];
    var resource_id = build_piece_resource_id(
        build_record_effective_piece_type(records, index)
    );

    var result = fence_remove_at(records, grid_x, grid_y);
    if (!result.removed) return result;

    inventory_add(game_state.player_inventory, resource_id, 1);
    fence_commit_room_records(room_name, result.records);
    fence_restore_room();
    save_write();
    return {
        removed: true,
        message: resource_get_name(resource_id) + " returned."
    };
}

function build_begin_placement(_resource_id, _remove_mode = false)
{
    var game_state = game_state_ensure();
    if (!build_is_unlocked(game_state)
    || instance_exists(obj_build_placement_controller))
    {
        return noone;
    }

    if (!_remove_mode
    && inventory_get_amount(
        game_state.player_inventory,
        _resource_id
    ) <= 0)
    {
        return noone;
    }

    var controller = instance_create_depth(
        0,
        0,
        -800,
        obj_build_placement_controller
    );
    controller.resource_id = _resource_id;
    controller.orientation = FenceRotation.FRONT;
    controller.remove_mode = _remove_mode;
    return controller;
}
