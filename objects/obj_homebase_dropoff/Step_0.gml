/// obj_homebase_dropoff - Step Event
///
/// Delivery behavior lives in this object's Create event interaction closure.

if (gameplay_is_paused()) exit;

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
