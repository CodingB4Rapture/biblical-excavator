/// obj_water_tank - Destroy Event

if (instance_exists(collision_blocker))
{
    with (collision_blocker) instance_destroy();
}
