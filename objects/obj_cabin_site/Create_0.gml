/// obj_cabin_site - Create Event

interaction_enabled = true;
interaction_radius = 42;
interaction_priority = 18;
sprite_index = game_state_ensure().cabin_built
    ? spr_cabin_after
    : spr_cabin_before;

interaction_get_prompt = function(_actor)
{
    var game_state = game_state_ensure();

    if (task_is_active(TaskId.MARK_CABIN_SITE, game_state)
    && !game_state.cabin_fence_marked)
    {
        return "Plan the cabin boundary";
    }

    if (task_get_status(TaskId.MARK_CABIN_SITE) == TaskStatus.COMPLETE)
    {
        return "Claim site task at the Task Board";
    }

    if (task_is_active(TaskId.PLACE_CABIN, game_state)
    && !game_state.cabin_built)
    {
        return "Build the cabin";
    }

    if (task_get_status(TaskId.PLACE_CABIN) == TaskStatus.COMPLETE)
    {
        return "Claim cabin task at the Task Board";
    }

    if (homestead_stage_get() == HomesteadStage.FIRST_REST_REQUIRED)
    {
        return "Rest and begin tomorrow";
    }

    return calendar_is_nighttime()
        ? "Sleep until morning"
        : "Rest at cabin";
};

interaction_run = function(_actor)
{
    var game_state = game_state_ensure();

    if (task_is_active(TaskId.MARK_CABIN_SITE, game_state)
    && !game_state.cabin_fence_marked)
    {
        if (!instance_exists(obj_fence_planning_controller))
        {
            instance_create_depth(
                0,
                0,
                -800,
                obj_fence_planning_controller
            );
        }
        return;
    }

    if (task_get_status(TaskId.MARK_CABIN_SITE) == TaskStatus.COMPLETE)
    {
        notification_show_hint(
            "Return to the Task Board and claim the completed site task.",
            game_get_speed(gamespeed_fps) * 4,
            false
        );
        return;
    }

    if (task_is_active(TaskId.PLACE_CABIN, game_state)
    && !game_state.cabin_built)
    {
        cabin_build_at_site(id);
        return;
    }

    if (task_get_status(TaskId.PLACE_CABIN) == TaskStatus.COMPLETE)
    {
        notification_show_hint(
            "Return to the Task Board and claim the completed cabin task.",
            game_get_speed(gamespeed_fps) * 4,
            false
        );
        return;
    }

    cabin_sleep_until_morning(_actor);
};
