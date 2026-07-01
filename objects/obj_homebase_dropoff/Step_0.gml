/// obj_homebase_dropoff - Step Event

if (dropoff_cooldown > 0)
{
    dropoff_cooldown -= 1;
}

var vehicle = instance_nearest(x, y, obj_skidsteer);

if (vehicle != noone && dropoff_cooldown <= 0)
{
    if (point_distance(x, y, vehicle.x, vehicle.y) <= dropoff_radius)
    {
        if (progress_dropoff_homebase())
        {
            dropoff_cooldown = game_get_speed(gamespeed_fps);
        }
    }
}

