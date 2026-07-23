/// Shared room token and spawn-clear rules for renewable resources.
/// Each resource family owns its record lifecycle in a focused module.

#macro TREE_REGROWTH_DAYS 3

function resource_regeneration_begin_room()
{
    if (!variable_global_exists("resource_regeneration_token"))
        global.resource_regeneration_token = 0;

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
