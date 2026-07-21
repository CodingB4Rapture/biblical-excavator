/// Persistent standing-tree and felled-piece records.

function tree_record_find_index(_world_id)
{
    var records = game_state_ensure().tree_records;
    for (var i = 0; i < array_length(records); i++)
    {
        if (records[i].world_id == _world_id) return i;
    }
    return -1;
}

function tree_record_ensure(_world_id, _room_name, _x, _y)
{
    var game_state = game_state_ensure();
    var sync_token = resource_regeneration_sync_room();
    var index = tree_record_find_index(_world_id);

    if (index >= 0)
    {
        var existing = game_state.tree_records[index];
        existing.room_name = _room_name;
        existing.original_x = _x;
        existing.original_y = _y;
        existing.seen_token = sync_token;

        if (!variable_struct_exists(existing, "respawn_day"))
        {
            existing.respawn_day = -1;
        }

        tree_record_schedule_regrowth(existing);
        return existing;
    }

    var record = {
        world_id: _world_id,
        room_name: _room_name,
        original_x: _x,
        original_y: _y,
        state: TreeState.STANDING,
        downed_exists: false,
        downed_x: _x + 40,
        downed_y: _y + 24,
        stump_exists: false,
        stump_x: _x,
        stump_y: _y + 24,
        respawn_day: -1,
        seen_token: sync_token
    };

    array_push(game_state.tree_records, record);
    return record;
}

function tree_record_mark_felled(_world_id, _x, _y)
{
    var record = tree_record_ensure(_world_id, room_get_name(room), _x, _y);
    record.state = TreeState.FELLED;
    record.downed_exists = true;
    record.downed_x = _x + 40;
    record.downed_y = _y + 24;
    record.stump_exists = true;
    record.stump_x = _x;
    record.stump_y = _y + 24;
    record.respawn_day = -1;
    return record;
}

function tree_record_schedule_regrowth(_record)
{
    if (_record.state != TreeState.FELLED
    || _record.downed_exists
    || _record.stump_exists
    || _record.respawn_day >= 0)
    {
        return false;
    }

    _record.respawn_day = game_state_ensure().day_number + TREE_REGROWTH_DAYS;
    return true;
}

function tree_record_update_downed(_tree_world_id, _x, _y, _exists = true)
{
    var index = tree_record_find_index(_tree_world_id);
    if (index < 0) return;
    var record = game_state_ensure().tree_records[index];
    record.downed_exists = _exists;
    record.downed_x = _x;
    record.downed_y = _y;
    tree_record_schedule_regrowth(record);
}

function tree_record_update_stump(_tree_world_id, _x, _y, _exists = true)
{
    var index = tree_record_find_index(_tree_world_id);
    if (index < 0) return;
    var record = game_state_ensure().tree_records[index];
    record.stump_exists = _exists;
    record.stump_x = _x;
    record.stump_y = _y;
    tree_record_schedule_regrowth(record);
}

function tree_record_can_regrow(_record)
{
    return _record.state == TreeState.FELLED
        && _record.respawn_day >= 0
        && game_state_ensure().day_number >= _record.respawn_day
        && resource_regeneration_spawn_is_clear(
            _record.original_x,
            _record.original_y,
            18
        );
}

function tree_record_make_standing(_record)
{
    _record.state = TreeState.STANDING;
    _record.downed_exists = false;
    _record.downed_x = _record.original_x + 40;
    _record.downed_y = _record.original_y + 24;
    _record.stump_exists = false;
    _record.stump_x = _record.original_x;
    _record.stump_y = _record.original_y + 24;
    _record.respawn_day = -1;

    // A later felling reuses these deterministic piece IDs.
    save_unmark_world_removed(_record.world_id + "_downed");
    save_unmark_world_removed(_record.world_id + "_stump");
}

function tree_find_standing_for_record(_record)
{
    for (var i = 0; i < instance_number(obj_tree); i++)
    {
        var tree = instance_find(obj_tree, i);

        if (instance_exists(tree)
        && variable_instance_exists(tree, "world_id")
        && tree.world_id == _record.world_id)
        {
            return tree;
        }
    }

    return noone;
}

function tree_records_prune_stale_current_room()
{
    var game_state = game_state_ensure();
    var current_room = room_get_name(room);
    var sync_token = resource_regeneration_sync_room();
    var kept_records = [];
    var removed_count = 0;

    for (var i = 0; i < array_length(game_state.tree_records); i++)
    {
        var record = game_state.tree_records[i];
        var belongs_here = record.room_name == current_room;
        var seen_here = variable_struct_exists(record, "seen_token")
            && record.seen_token == sync_token;

        if (belongs_here && !seen_here)
        {
            save_unmark_world_removed(record.world_id + "_downed");
            save_unmark_world_removed(record.world_id + "_stump");
            removed_count += 1;
        }
        else
        {
            array_push(kept_records, record);
        }
    }

    game_state.tree_records = kept_records;
    return removed_count;
}

function tree_regeneration_update()
{
    var game_state = game_state_ensure();
    var current_room = room_get_name(room);
    var sync_token = resource_regeneration_sync_room();
    var regrown = 0;

    for (var i = 0; i < array_length(game_state.tree_records); i++)
    {
        var record = game_state.tree_records[i];

        if (record.room_name != current_room
        || !variable_struct_exists(record, "seen_token")
        || record.seen_token != sync_token
        || instance_exists(tree_find_standing_for_record(record))
        || !tree_record_can_regrow(record))
        {
            continue;
        }

        tree_record_make_standing(record);
        instance_create_depth(record.original_x, record.original_y, 0, obj_tree);
        regrown += 1;
    }

    return regrown;
}

function tree_find_piece_for_record(_object, _tree_world_id)
{
    for (var i = 0; i < instance_number(_object); i++)
    {
        var piece = instance_find(_object, i);
        if (piece.tree_world_id == _tree_world_id) return piece;
    }
    return noone;
}

function tree_spawn_felled_pieces(_record)
{
    if (_record.downed_exists
    && !instance_exists(tree_find_piece_for_record(obj_log, _record.world_id)))
    {
        instance_create_depth(
            _record.downed_x,
            _record.downed_y,
            0,
            obj_log,
            { tree_world_id: _record.world_id }
        );
    }

    if (_record.stump_exists
    && !instance_exists(tree_find_piece_for_record(obj_stump, _record.world_id)))
    {
        instance_create_depth(
            _record.stump_x,
            _record.stump_y,
            0,
            obj_stump,
            { tree_world_id: _record.world_id }
        );
    }
}

function tree_find_felled_log()
{
    for (var i = 0; i < instance_number(obj_log); i++)
    {
        var log = instance_find(obj_log, i);
        if (log.tree_world_id != "") return log;
    }
    return noone;
}
