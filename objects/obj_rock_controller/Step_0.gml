/// obj_rock_controller - Step Event

for (var i = 0; i < array_length(rock_spawns); i++)
{
    var spawn = rock_spawns[i];
    var nearest_rock = instance_nearest(spawn.x, spawn.y, obj_rock);
    var has_rock = nearest_rock != noone && point_distance(spawn.x, spawn.y, nearest_rock.x, nearest_rock.y) < 4;

    if (has_rock)
    {
        rock_respawn_timers[i] = 0;
    }
    else
    {
        if (rock_respawn_timers[i] <= 0)
        {
            rock_respawn_timers[i] = respawn_time;
        }
        else
        {
            rock_respawn_timers[i] -= 1;

            if (rock_respawn_timers[i] <= 0)
            {
                instance_create_depth(spawn.x, spawn.y, 0, obj_rock);
            }
        }
    }
}

