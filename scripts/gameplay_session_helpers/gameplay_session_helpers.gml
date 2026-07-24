/// Runtime pause, actor recovery, and pending-room session coordination.

function gameplay_is_paused()
{
    return variable_global_exists("gameplay_paused")
        && global.gameplay_paused;
}

function gameplay_set_paused(_paused)
{
    global.gameplay_paused = _paused;
}

function gameplay_ensure_controllable_actor()
{
    var player = instance_find(obj_player, 0);
    var vehicle = instance_find(obj_skidsteer, 0);

    if (instance_exists(player))
    {
        return player;
    }

    if (instance_exists(vehicle) && vehicle.has_driver)
    {
        return vehicle;
    }

    // Recovery rule: a playable room must never leave the player stranded
    // without either an on-foot character or control of the work vehicle.
    var spawn_x = instance_exists(vehicle) ? vehicle.x - 24 : 64;
    var spawn_y = instance_exists(vehicle) ? vehicle.y + 18 : 208;
    player = instance_create_depth(spawn_x, spawn_y, -1, obj_player);

    if (instance_exists(vehicle))
    {
        player.vehicle = vehicle;
    }

    return player;
}

function save_get_restore_room(_fallback_room)
{
    if (!variable_global_exists("save_restore_scene")
    || !is_struct(global.save_restore_scene)
    || !variable_struct_exists(global.save_restore_scene, "room_name"))
    {
        return _fallback_room;
    }

    var saved_room = asset_get_index(global.save_restore_scene.room_name);
    return (saved_room == -1) ? _fallback_room : saved_room;
}
