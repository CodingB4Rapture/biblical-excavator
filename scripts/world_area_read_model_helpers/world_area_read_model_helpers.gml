/// Read-only access to the controlled actor and current derived area.

function world_area_tracking_actor()
{
    var vehicle = instance_find(obj_skidsteer, 0);
    if (instance_exists(vehicle) && vehicle.has_driver) return vehicle;

    var player = instance_find(obj_player, 0);
    if (instance_exists(player)) return player;

    return instance_exists(vehicle) ? vehicle : noone;
}

function world_area_current_id()
{
    var controller = instance_find(obj_world_area_controller, 0);
    return instance_exists(controller)
        ? controller.current_area_id
        : WORLD_AREA_NONE;
}

function world_area_current_definition()
{
    return world_area_definition(world_area_current_id());
}
