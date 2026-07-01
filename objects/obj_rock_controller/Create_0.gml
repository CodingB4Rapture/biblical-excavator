/// obj_rock_controller - Create Event

respawn_time = game_get_speed(gamespeed_fps) * 12;
rock_spawns = [];
rock_respawn_timers = [];

for (var i = 0; i < instance_number(obj_rock); i++)
{
    var rock = instance_find(obj_rock, i);

    array_push(rock_spawns, { x: rock.x, y: rock.y });
    array_push(rock_respawn_timers, 0);
}
