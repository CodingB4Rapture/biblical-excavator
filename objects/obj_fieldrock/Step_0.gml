/// obj_fieldrock - Step Event

if (gameplay_is_paused()) exit;

switch (fieldrock_state)
{
    case FieldrockState.WAITING:
    {
        break;
    }

    case FieldrockState.STRUGGLING:
    {
        fieldrock_tick_timer -= 1;

        var base_frame = fieldrock_stage_frame[fieldrock_stage];
        var frame_wobble = ((fieldrock_tick_timer div 6) mod 2);
        image_index = clamp(base_frame - frame_wobble, 0, image_number - 1);

        if (fieldrock_tick_timer <= 0)
        {
            var break_chance = fieldrock_stage_chance[fieldrock_stage];

            if (random(1) <= break_chance || fieldrock_stage >= 2)
            {
                var xp_amount = fieldrock_stage_xp[fieldrock_stage];

                // Mark it now so saving during the short breaking animation
                // cannot duplicate an already-awarded fieldstone.
                fieldrock_record_mark_depleted(
                    world_id,
                    room_get_name(room),
                    x,
                    y
                );

                progress_award_crushed_resource(
                    resource_id,
                    xp_amount,
                    fieldrock_reward_source
                );

                image_index = image_number - 1;
                image_speed = 0;
                fieldrock_break_timer = 16;
                fieldrock_state = FieldrockState.BREAKING;
            }
            else
            {
                fieldrock_stage += 1;
                fieldrock_tick_timer = fieldrock_tick_time;
            }
        }

        break;
    }

    case FieldrockState.BREAKING:
    {
        fieldrock_break_timer -= 1;

        if (fieldrock_break_timer <= 0)
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

