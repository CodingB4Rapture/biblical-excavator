/// obj_rock - Step Event

if (gameplay_is_paused()) exit;

switch (rock_state)
{
    case RockState.WAITING:
    {
        break;
    }

    case RockState.STRUGGLING:
    {
        rock_tick_timer -= 1;

        var base_frame = rock_stage_frame[rock_stage];
        var frame_wobble = ((rock_tick_timer div 6) mod 2);
        image_index = clamp(base_frame - frame_wobble, 0, image_number - 1);

        if (rock_tick_timer <= 0)
        {
            var break_chance = rock_stage_chance[rock_stage];

            if (random(1) <= break_chance || rock_stage >= 2)
            {
                var xp_amount = rock_stage_xp[rock_stage];

                // Mark it now so saving during the short breaking animation
                // cannot duplicate an already-awarded fieldstone.
                save_mark_world_removed(world_id);

                progress_award_rock(
                    1,
                    xp_amount,
                    rock_reward_source
                );

                image_index = image_number - 1;
                image_speed = 0;
                rock_break_timer = 16;
                rock_state = RockState.BREAKING;
            }
            else
            {
                rock_stage += 1;
                rock_tick_timer = rock_tick_time;
            }
        }

        break;
    }

    case RockState.BREAKING:
    {
        rock_break_timer -= 1;

        if (rock_break_timer <= 0)
        {
            repeat (8)
            {
                instance_create_depth(
                    x + random_range(-5, 5),
                    y + random_range(-3, 3),
                    depth - 1,
                    obj_smoke_puff
                );
            }

            instance_destroy();
        }

        break;
    }
}

