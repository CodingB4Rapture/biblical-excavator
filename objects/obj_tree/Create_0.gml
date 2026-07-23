/// obj_tree - Create Event

game_state_ensure();

world_id = "tree_" + room_get_name(room) + "_"
    + string(round(x)) + "_" + string(round(y));
original_x = x;
original_y = y;

var tree_record = tree_record_ensure(world_id, room_get_name(room), x, y);
if (tree_record.state == TreeState.FELLED)
{
    if (tree_record_can_regrow(tree_record))
    {
        tree_record_make_standing(tree_record);
    }
    else
    {
        tree_spawn_felled_pieces(tree_record);
        instance_destroy();
        exit;
    }
}

tree_state = TreeState.STANDING;
chop_progress = 0;
chop_duration = max(1, round(game_get_speed(gamespeed_fps) * 3));
chop_actor = noone;
chop_active_radius = 34;
chop_shake_timer = 0;
fall_timer = 0;
fall_duration = max(1, round(game_get_speed(gamespeed_fps) * 0.7));

interaction_enabled = true;
interaction_radius = 30;
interaction_priority = 25;

interaction_get_prompt = function(_actor)
{
    if (tree_state == TreeState.FALLING || tree_state == TreeState.FELLED)
    {
        return "";
    }

    if (!game_state_ensure().tools.axe_owned)
    {
        return "Inspect standing tree";
    }

    var game_state = game_state_ensure();
    if (game_state.tutorial_stage != TutorialStage.COMPLETE
    && !task_is_active(TaskId.FALLEN_TREE, game_state))
    {
        return "Accept A Fallen Tree at the Task Board";
    }

    if (tree_state == TreeState.CHOPPING)
    {
        return "Chopping - stay close";
    }

    return chop_progress > 0 ? "Resume chopping" : "Chop standing tree";
};

interaction_run = function(_actor)
{
    if (!game_state_ensure().tools.axe_owned)
    {
        notification_show_hint(
            "You would need an axe for this.",
            game_get_speed(gamespeed_fps) * 2,
            false
        );
        return;
    }

    var game_state = game_state_ensure();
    if (game_state.tutorial_stage != TutorialStage.COMPLETE
    && !task_is_active(TaskId.FALLEN_TREE, game_state))
    {
        notification_show_hint(
            "Accept A Fallen Tree at the Task Board before chopping.",
            game_get_speed(gamespeed_fps) * 3,
            false
        );
        return;
    }

    if (tree_state == TreeState.STANDING)
    {
        tree_state = TreeState.CHOPPING;
        chop_actor = _actor;
        notification_show_hint(
            "Chopping started. Stay close to the tree.",
            game_get_speed(gamespeed_fps) * 2,
            false
        );
    }
};

image_speed = 0;
