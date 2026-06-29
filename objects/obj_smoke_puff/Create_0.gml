/// obj_smoke_puff - Create Event

// The puff lives for about 0.6 seconds.
life_max = round(
    game_get_speed(gamespeed_fps) * 0.6
);

life = life_max;

// Each puff receives slightly different movement.
horizontal_speed = random_range(-0.4, 0.4);
vertical_speed   = random_range(-0.8, -0.25);

// Each puff begins at a slightly different size.
puff_size = random_range(1.5, 3);