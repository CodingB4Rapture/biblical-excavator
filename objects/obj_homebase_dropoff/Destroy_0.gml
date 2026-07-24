/// obj_homebase_dropoff - Destroy Event

if (instance_exists(chest_blocker))
{
    with (chest_blocker)
    {
        instance_destroy();
    }
}
