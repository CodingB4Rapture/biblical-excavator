/// Fieldrock depletion and one-day respawn lifecycle.

#macro FIELDROCK_RESPAWN_DAYS 1

function fieldrock_record_find_index(_world_id)
{
    var records = game_state_ensure().fieldrock_records;
    for (var i = 0; i < array_length(records); i++)
    {
        if (records[i].world_id == _world_id) return i;
    }
    return -1;
}

function fieldrock_record_ensure(_world_id, _room_name, _x, _y)
{
    var game_state = game_state_ensure();
    var sync_token = resource_regeneration_sync_room();
    var index = fieldrock_record_find_index(_world_id);

    if (index >= 0)
    {
        var existing = game_state.fieldrock_records[index];
        existing.room_name = _room_name;
        existing.spawn_x = _x;
        existing.spawn_y = _y;
        existing.seen_token = sync_token;

        if (!variable_struct_exists(existing, "respawn_day"))
        {
            existing.respawn_day = save_world_id_is_removed(_world_id)
                ? game_state.day_number + FIELDROCK_RESPAWN_DAYS
                : -1;
        }
        return existing;
    }

    var record = {
        world_id: _world_id,
        room_name: _room_name,
        spawn_x: _x,
        spawn_y: _y,
        respawn_day: save_world_id_is_removed(_world_id)
            ? game_state.day_number + FIELDROCK_RESPAWN_DAYS
            : -1,
        seen_token: sync_token
    };
    array_push(game_state.fieldrock_records, record);
    return record;
}

function fieldrock_record_mark_depleted(_world_id, _room_name, _x, _y)
{
    var game_state = game_state_ensure();
    var record = fieldrock_record_ensure(
        _world_id,
        _room_name,
        _x,
        _y
    );
    record.respawn_day = game_state.day_number + FIELDROCK_RESPAWN_DAYS;
    save_mark_world_removed(_world_id);
    return record;
}

function fieldrock_record_make_available(_record)
{
    _record.respawn_day = -1;
    save_unmark_world_removed(_record.world_id);
}

function fieldrock_record_can_spawn(_record)
{
    if (_record.respawn_day < 0) return true;
    if (game_state_ensure().day_number < _record.respawn_day) return false;
    return resource_regeneration_spawn_is_clear(
        _record.spawn_x,
        _record.spawn_y,
        18
    );
}

function fieldrock_find_for_record(_record)
{
    for (var i = 0; i < instance_number(obj_fieldrock); i++)
    {
        var fieldrock = instance_find(obj_fieldrock, i);
        if (instance_exists(fieldrock)
        && variable_instance_exists(fieldrock, "world_id")
        && fieldrock.world_id == _record.world_id)
            return fieldrock;
    }
    return noone;
}

function fieldrock_records_prune_stale_current_room()
{
    var game_state = game_state_ensure();
    var current_room = room_get_name(room);
    var sync_token = resource_regeneration_sync_room();
    var kept_records = [];
    var removed_count = 0;

    for (var i = 0; i < array_length(game_state.fieldrock_records); i++)
    {
        var record = game_state.fieldrock_records[i];
        var belongs_here = record.room_name == current_room;
        var seen_here = variable_struct_exists(record, "seen_token")
            && record.seen_token == sync_token;

        if (belongs_here && !seen_here)
        {
            save_unmark_world_removed(record.world_id);
            removed_count += 1;
        }
        else
        {
            array_push(kept_records, record);
        }
    }

    game_state.fieldrock_records = kept_records;
    return removed_count;
}

function fieldrock_regeneration_update()
{
    var game_state = game_state_ensure();
    var current_room = room_get_name(room);
    var sync_token = resource_regeneration_sync_room();
    var respawned = 0;

    for (var i = 0; i < array_length(game_state.fieldrock_records); i++)
    {
        var record = game_state.fieldrock_records[i];

        if (record.room_name != current_room
        || !variable_struct_exists(record, "seen_token")
        || record.seen_token != sync_token
        || record.respawn_day < 0
        || game_state.day_number < record.respawn_day
        || instance_exists(fieldrock_find_for_record(record))
        || !resource_regeneration_spawn_is_clear(
            record.spawn_x,
            record.spawn_y,
            18
        ))
        {
            continue;
        }

        fieldrock_record_make_available(record);
        instance_create_depth(
            record.spawn_x,
            record.spawn_y,
            0,
            obj_fieldrock
        );
        respawned += 1;
    }

    return respawned;
}
