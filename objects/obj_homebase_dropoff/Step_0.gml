/// obj_homebase_dropoff - Step Event
///
/// Delivery behavior lives in this object's Create event interaction closure.

if (gameplay_is_paused()) exit;

var vehicle = instance_find(obj_skidsteer, 0);
vehicle_inside_dropoff = false;

if (instance_exists(vehicle))
{
    vehicle_inside_dropoff =
        point_distance(vehicle.x, vehicle.y, x, y) <= dropoff_radius;
}

var has_vehicle_cargo = false;

if (vehicle_inside_dropoff
&& variable_instance_exists(vehicle, "cargo_inventory"))
{
    has_vehicle_cargo = inventory_get_total(vehicle.cargo_inventory) > 0;
}

var should_prompt_unload = false;

if (vehicle_inside_dropoff && has_vehicle_cargo)
{
    should_prompt_unload = vehicle.has_driver;
}
var current_hint = instance_find(obj_gui_hint, 0);
var owns_unload_hint = instance_exists(current_hint)
    && variable_instance_exists(current_hint, "context_key")
    && current_hint.context_key == unload_hint_context_key;

if (should_prompt_unload)
{
    if (!owns_unload_hint && !instance_exists(current_hint))
    {
        var unload_hint = notification_show_hint(
            "Hop off the skidsteer to deliver your goods.",
            game_get_speed(gamespeed_fps) * 8,
            true
        );
        unload_hint.context_key = unload_hint_context_key;
    }
}
else if (owns_unload_hint)
{
    with (current_hint)
    {
        instance_destroy();
    }
}

if (chest_open)
{
    if (!instance_exists(chest_open_actor)
    || point_distance(
        chest_open_actor.x,
        chest_open_actor.y,
        x,
        y
    ) > dropoff_radius)
    {
        chest_open = false;
        chest_open_actor = noone;
    }
}
