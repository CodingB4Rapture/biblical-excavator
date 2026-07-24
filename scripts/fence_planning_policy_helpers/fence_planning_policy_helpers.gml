/// Fence-planning progression policy and tutorial-mode read models.

function fence_planning_is_unlocked(_game_state = undefined)
{
    var game_state = is_undefined(_game_state)
        ? game_state_read()
        : _game_state;
    var mark_status = task_get_status(
        TaskId.MARK_CABIN_SITE,
        game_state
    );

    if (mark_status >= TaskStatus.COMPLETE)
    {
        return true;
    }

    return mark_status == TaskStatus.ACTIVE
        && game_state.cabin_site_placed;
}

function fence_planning_is_tutorial_mode(_game_state)
{
    return task_is_active(TaskId.MARK_CABIN_SITE, _game_state)
        && _game_state.cabin_site_placed
        && !_game_state.cabin_fence_marked;
}

function fence_planning_get_purpose(_game_state)
{
    return fence_planning_is_tutorial_mode(_game_state)
        ? FENCE_PURPOSE_CABIN_SITE
        : "";
}
