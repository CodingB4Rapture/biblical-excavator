/// obj_rock - Step Event

switch (rock_state)
{
    // NORMAL ROCK
    case 0:
    {
        // Wait for the skidsteer.
        break;
    }

    // CRUSHING ANIMATION
    case 1:
    {
        // Has the animation reached its final frame?
        if (image_index >= image_number - 1)
        {
            // Lock the animation onto its final frame.
            image_index = image_number - 1;
            image_speed = 0;

            // Hold the final frame for one second.
            hold_timer = game_get_speed(gamespeed_fps);

            // Enter the holding state.
            rock_state = 2;
        }

        break;
    }

    // HOLD FINAL FRAME
    case 2:
    {
        hold_timer -= 1;

        if (hold_timer <= 0)
        {
            // Create several smoke/dust puffs.
            repeat (8)
            {
                instance_create_depth(
                    x + random_range(-5, 5),
                    y + random_range(-3, 3),
                    depth - 1,
                    obj_smoke_puff
                );
            }

            // The rock is finally crushed.
            instance_destroy();
        }

        break;
    }
}