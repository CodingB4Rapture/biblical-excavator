/// Persistent, day-based regeneration for renewable world resources.
/// Tutorial hand-Fieldstones are intentionally one-time pickups. Renewable
/// Fieldstone comes from placed markers and Fieldrocks after the tutorial.

#macro FIELDROCK_RESPAWN_DAYS 1
#macro TREE_REGROWTH_DAYS 3
#macro FIELDSTONE_NOON_MINUTE 720
#macro FIELDSTONE_DAILY_SPAWN_CHANCE 0.45

function resource_regeneration_begin_room()
{
    if (!variable_global_exists("resource_regeneration_token"))
    {
        global.resource_regeneration_token = 0;
    }

    global.resource_regeneration_token += 1;
    global.resource_regeneration_room = room_get_name(room);
    return global.resource_regeneration_token;
}

function resource_regeneration_sync_room()
{
    var current_room = room_get_name(room);

    if (!variable_global_exists("resource_regeneration_token")
    || !variable_global_exists("resource_regeneration_room")
    || global.resource_regeneration_room != current_room)
    {
        return resource_regeneration_begin_room();
    }

    return global.resource_regeneration_token;
}

/// Renewable resources wait instead of appearing on top of an actor, cabin,
/// hauled resource, pond, or another large resource.
function resource_regeneration_spawn_is_clear(_x, _y, _radius)
{
    var blocker_objects = [
        obj_player,
        obj_skidsteer,
        obj_farmer,
        obj_farmers_wife,
        obj_cabin_site,
        obj_pond,
        obj_fieldstone,
        obj_small_fieldstone,
        obj_fieldrock,
        obj_tree,
        obj_log,
        obj_stump
    ];

    for (var i = 0; i < array_length(blocker_objects); i++)
    {
        if (instance_exists(collision_circle(
            _x,
            _y,
            _radius,
            blocker_objects[i],
            false,
            true
        )))
        {
            return false;
        }
    }

    return true;
}

function fieldrock_record_find_index(_world_id)
{
    var records = game_state_ensure().fieldrock_records;

    for (var i = 0; i < array_length(records); i++)
    {
        if (records[i].world_id == _world_id) return i;
    }

    return -1;
}

function fieldstone_record_find_index(_world_id)
{
    var records = game_state_ensure().fieldstone_records;

    for (var i = 0; i < array_length(records); i++)
    {
        if (records[i].world_id == _world_id) return i;
    }

    return -1;
}

function fieldstone_record_ensure(
    _world_id,
    _room_name,
    _x,
    _y,
    _spawn_chance = -1
)
{
    var game_state = game_state_ensure();
    var sync_token = resource_regeneration_sync_room();
    var index = fieldstone_record_find_index(_world_id);
    var resolved_chance = _spawn_chance < 0
        ? FIELDSTONE_DAILY_SPAWN_CHANCE
        : clamp(_spawn_chance, 0, 1);

    if (index >= 0)
    {
        var existing = game_state.fieldstone_records[index];
        existing.room_name = _room_name;
        existing.spawn_x = _x;
        existing.spawn_y = _y;
        existing.seen_token = sync_token;

        if (!variable_struct_exists(existing, "present")) existing.present = false;
        if (!variable_struct_exists(existing, "spawn_chance"))
        {
            existing.spawn_chance = resolved_chance;
        }
        else if (_spawn_chance >= 0)
        {
            existing.spawn_chance = resolved_chance;
        }

        if (!variable_struct_exists(existing, "last_roll_day"))
        {
            existing.last_roll_day = game_state.day_number;
        }

        return existing;
    }

    var record = {
        world_id: _world_id,
        room_name: _room_name,
        spawn_x: _x,
        spawn_y: _y,
        spawn_chance: resolved_chance,
        present: random(1) < resolved_chance,
        last_roll_day: game_state.day_number,
        seen_token: sync_token
    };

    array_push(game_state.fieldstone_records, record);
    return record;
}

function fieldstone_spawn_point_is_clear_of_records(_x, _y, _room_name)
{
    var records = game_state_ensure().fieldstone_records;

    for (var i = 0; i < array_length(records); i++)
    {
        var record = records[i];

        if (record.room_name == _room_name
        && point_distance(_x, _y, record.spawn_x, record.spawn_y) < 12)
        {
            return false;
        }
    }

    return true;
}

function fieldstone_spawn_area_register(
    _area_world_id,
    _room_name,
    _center_x,
    _center_y,
    _radius,
    _spawn_points,
    _spawn_chance
)
{
    var game_state = game_state_ensure();
    var sync_token = resource_regeneration_sync_room();
    var point_count = clamp(round(_spawn_points), 1, 64);
    var radius = clamp(_radius, 16, 512);

    for (var point_index = 0; point_index < point_count; point_index++)
    {
        var world_id = _area_world_id + "_" + string(point_index);
        var record_index = fieldstone_record_find_index(world_id);

        if (record_index >= 0)
        {
            var existing = game_state.fieldstone_records[record_index];
            existing.room_name = _room_name;
            existing.spawn_chance = clamp(_spawn_chance, 0, 1);
            existing.seen_token = sync_token;

            if (!variable_struct_exists(existing, "present")) existing.present = false;
            if (!variable_struct_exists(existing, "last_roll_day"))
            {
                existing.last_roll_day = game_state.day_number;
            }

            continue;
        }

        var spawn_x = _center_x;
        var spawn_y = _center_y;

        for (var attempt = 0; attempt < 12; attempt++)
        {
            var spawn_direction = random(360);
            var distance = sqrt(random(1)) * radius;
            var candidate_x = clamp(
                _center_x + lengthdir_x(distance, spawn_direction),
                8,
                room_width - 8
            );
            var candidate_y = clamp(
                _center_y + lengthdir_y(distance, spawn_direction),
                8,
                room_height - 8
            );

            spawn_x = candidate_x;
            spawn_y = candidate_y;

            if (fieldstone_spawn_point_is_clear_of_records(
                candidate_x,
                candidate_y,
                _room_name
            ))
            {
                break;
            }
        }

        fieldstone_record_ensure(
            world_id,
            _room_name,
            spawn_x,
            spawn_y,
            _spawn_chance
        );
    }
}

function fieldstone_record_mark_collected(_world_id)
{
    var index = fieldstone_record_find_index(_world_id);
    if (index < 0) return false;

    var game_state = game_state_ensure();
    var record = game_state.fieldstone_records[index];
    record.present = false;

    // A stone gathered after today's noon roll waits until tomorrow. A stone
    // gathered in the morning is eligible for today's noon roll.
    if (game_state.time_of_day >= FIELDSTONE_NOON_MINUTE)
    {
        record.last_roll_day = max(record.last_roll_day, game_state.day_number);
    }

    return true;
}

function fieldstone_find_for_record(_record)
{
    for (var i = 0; i < instance_number(obj_fieldstone); i++)
    {
        var fieldstone = instance_find(obj_fieldstone, i);

        if (instance_exists(fieldstone)
        && variable_instance_exists(fieldstone, "world_id")
        && fieldstone.world_id == _record.world_id)
        {
            return fieldstone;
        }
    }

    return noone;
}

/// During the first hand-gathering objective, existing spawn records replace
/// the old fixed six-stone row. Chance is bypassed only until enough currently
/// visible stones exist to finish the remaining objective.
function fieldstone_tutorial_ensure_visible_count(_required_visible)
{
    var game_state = game_state_ensure();
    var current_room = room_get_name(room);
    var sync_token = resource_regeneration_sync_room();
    var visible_count = instance_number(obj_fieldstone);

    if (visible_count >= _required_visible) return visible_count;

    for (var i = 0; i < array_length(game_state.fieldstone_records); i++)
    {
        var record = game_state.fieldstone_records[i];

        if (record.room_name != current_room
        || !variable_struct_exists(record, "seen_token")
        || record.seen_token != sync_token
        || instance_exists(fieldstone_find_for_record(record))
        || !resource_regeneration_spawn_is_clear(record.spawn_x, record.spawn_y, 5))
        {
            continue;
        }

        record.present = true;
        record.last_roll_day = game_state.day_number;
        instance_create_depth(
            record.spawn_x,
            record.spawn_y,
            0,
            obj_fieldstone,
            { spawn_world_id: record.world_id }
        );
        visible_count += 1;

        if (visible_count >= _required_visible) break;
    }

    return visible_count;
}

function fieldstone_records_prune_stale_current_room()
{
    var game_state = game_state_ensure();
    var current_room = room_get_name(room);
    var sync_token = resource_regeneration_sync_room();
    var kept_records = [];
    var removed_count = 0;

    for (var i = 0; i < array_length(game_state.fieldstone_records); i++)
    {
        var record = game_state.fieldstone_records[i];
        var belongs_here = record.room_name == current_room;
        var seen_here = variable_struct_exists(record, "seen_token")
            && record.seen_token == sync_token;

        if (belongs_here && !seen_here)
        {
            removed_count += 1;
        }
        else
        {
            array_push(kept_records, record);
        }
    }

    game_state.fieldstone_records = kept_records;
    return removed_count;
}

function fieldstone_regeneration_update()
{
    var game_state = game_state_ensure();
    var current_room = room_get_name(room);
    var sync_token = resource_regeneration_sync_room();
    var changed_records = 0;

    for (var i = 0; i < array_length(game_state.fieldstone_records); i++)
    {
        var record = game_state.fieldstone_records[i];

        if (record.room_name != current_room
        || !variable_struct_exists(record, "seen_token")
        || record.seen_token != sync_token)
        {
            continue;
        }

        var fieldstone = fieldstone_find_for_record(record);

        if (record.present)
        {
            if (!instance_exists(fieldstone)
            && resource_regeneration_spawn_is_clear(record.spawn_x, record.spawn_y, 5))
            {
                instance_create_depth(
                    record.spawn_x,
                    record.spawn_y,
                    0,
                    obj_fieldstone,
                    { spawn_world_id: record.world_id }
                );
            }

            continue;
        }

        if (!calendar_should_run()
        || game_state.time_of_day < FIELDSTONE_NOON_MINUTE
        || record.last_roll_day >= game_state.day_number)
        {
            continue;
        }

        record.last_roll_day = game_state.day_number;
        if (!variable_struct_exists(record, "spawn_chance"))
        {
            record.spawn_chance = FIELDSTONE_DAILY_SPAWN_CHANCE;
        }

        record.present = random(1) < record.spawn_chance;
        changed_records += 1;

        if (record.present
        && resource_regeneration_spawn_is_clear(record.spawn_x, record.spawn_y, 5))
        {
            instance_create_depth(
                record.spawn_x,
                record.spawn_y,
                0,
                obj_fieldstone,
                { spawn_world_id: record.world_id }
            );
        }
    }

    return changed_records;
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
    var record = fieldrock_record_ensure(_world_id, _room_name, _x, _y);
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
        {
            return fieldrock;
        }
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
        || !resource_regeneration_spawn_is_clear(record.spawn_x, record.spawn_y, 18))
        {
            continue;
        }

        fieldrock_record_make_available(record);
        instance_create_depth(record.spawn_x, record.spawn_y, 0, obj_fieldrock);
        respawned += 1;
    }

    return respawned;
}
