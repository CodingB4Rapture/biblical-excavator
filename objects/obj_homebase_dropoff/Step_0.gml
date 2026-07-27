/// obj_homebase_dropoff - Step Event
///
/// Delivery behavior lives in this object's Create event interaction closure.

if (gameplay_is_paused()) exit;

var vehicle = instance_find(obj_skidsteer, 0);
vehicle_inside_dropoff = progress_vehicle_is_in_home_delivery(id, vehicle);

var has_vehicle_cargo = false;

if (vehicle_inside_dropoff
&& variable_instance_exists(vehicle, "cargo_inventory"))
{
    has_vehicle_cargo = inventory_get_total(vehicle.cargo_inventory) > 0;
}

var has_pending_delivery = has_vehicle_cargo;
var nearby_log = instance_nearest(x, y, obj_log);
var nearby_stump = instance_nearest(x, y, obj_stump);

if (instance_exists(nearby_log)
&& nearby_log.pullable_state != PullableState.DELIVERED
&& point_distance(nearby_log.x, nearby_log.y, x, y) <= dropoff_radius)
{
    has_pending_delivery = true;
}

if (instance_exists(nearby_stump)
&& nearby_stump.pullable_state != PullableState.DELIVERED
&& point_distance(nearby_stump.x, nearby_stump.y, x, y) <= dropoff_radius)
{
    has_pending_delivery = true;
}

var delivery_hint_text = "";
if (vehicle_inside_dropoff && has_pending_delivery)
{
    delivery_hint_text = vehicle.has_driver
        ? "Skidsteer parked. Press E to get out, then walk to the chest."
        : "Walk to the chest and press E to unload supplies.";
}

var current_hint = instance_find(obj_gui_hint, 0);
var owns_unload_hint = instance_exists(current_hint)
    && variable_instance_exists(current_hint, "context_key")
    && current_hint.context_key == unload_hint_context_key;

if (delivery_hint_text != "")
{
    if (!owns_unload_hint && !instance_exists(current_hint))
    {
        var unload_hint = notification_show_hint(
            delivery_hint_text,
            game_get_speed(gamespeed_fps) * 8,
            true
        );
        unload_hint.context_key = unload_hint_context_key;
    }
    else if (owns_unload_hint
    && current_hint.message_text != delivery_hint_text)
    {
        current_hint.message_text = delivery_hint_text;
        current_hint.age = 0;
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
