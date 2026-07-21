/// obj_fieldstone_spawn_area - Create Event
/// Editor marker only: it registers persistent spawn points, then disappears.

spawn_radius = clamp(spawn_radius, 16, 512);
spawn_points = clamp(round(spawn_points), 1, 64);
spawn_chance = clamp(spawn_chance, 0, 1);

var area_world_id = "fieldstone_area_" + room_get_name(room) + "_"
    + string(round(x)) + "_" + string(round(y));

fieldstone_spawn_area_register(
    area_world_id,
    room_get_name(room),
    x,
    y,
    spawn_radius,
    spawn_points,
    spawn_chance
);

instance_destroy();
