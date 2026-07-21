/// obj_tree - Step Event

if (gameplay_is_paused()) exit;

switch (tree_state)
{
    case TreeState.STANDING:
    {
        image_angle = 0;
        break;
    }

    case TreeState.CHOPPING:
    {
        if (!instance_exists(chop_actor)
        || point_distance(x, y, chop_actor.x, chop_actor.y) > chop_active_radius)
        {
            tree_state = TreeState.STANDING;
            chop_actor = noone;
            notification_show_hint(
                "Chopping paused. Move close and press E to continue.",
                game_get_speed(gamespeed_fps) * 2,
                false
            );
            break;
        }

        chop_progress = min(chop_duration, chop_progress + 1);
        chop_shake_timer += 1;

        if (chop_progress >= chop_duration)
        {
            tree_state = TreeState.FALLING;
            fall_timer = 0;
            chop_actor = noone;
            interaction_enabled = false;
            // Relinquish the standing mask so the rotating tree cannot trap
            // the player inside its changing collision bounds.
            mask_index = -1;
            notification_show_hint(
                "Timber! The tree is coming down.",
                game_get_speed(gamespeed_fps) * 2,
                false
            );
        }
        break;
    }

    case TreeState.FALLING:
    {
        fall_timer = min(fall_duration, fall_timer + 1);
        image_angle = lerp(0, 90, fall_timer / fall_duration);

        if (fall_timer >= fall_duration)
        {
            tree_state = TreeState.FELLED;
            image_angle = 90;
            var tree_record = tree_record_mark_felled(world_id, original_x, original_y);
            tree_spawn_felled_pieces(tree_record);
            tutorial_report_tree_felled();
            instance_destroy();
        }
        break;
    }

    case TreeState.FELLED:
    {
        image_angle = 90;
        break;
    }
}
