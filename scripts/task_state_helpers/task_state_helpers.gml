/// Task structural normalization, saved-state restoration, and legacy derivation.

function task_status_is_valid(_status)
{
    return _status == TaskStatus.LOCKED
        || _status == TaskStatus.AVAILABLE
        || _status == TaskStatus.ACTIVE
        || _status == TaskStatus.COMPLETE
        || _status == TaskStatus.CLAIMED;
}

function task_tutorial_rank(_game_state)
{
    return tutorial_stage_rank(_game_state.tutorial_stage);
}

function task_state_ensure(_game_state)
{
    if (!variable_struct_exists(_game_state, "task_board_unlocked"))
        _game_state.task_board_unlocked = false;

    if (_game_state.tutorial_board_assignment_pending)
        _game_state.task_board_unlocked = true;

    if (!variable_struct_exists(_game_state, "task_statuses")
    || !is_array(_game_state.task_statuses))
    {
        _game_state.task_statuses =
            array_create(TaskId.COUNT, TaskStatus.LOCKED);
    }

    while (array_length(_game_state.task_statuses) < TaskId.COUNT)
        array_push(_game_state.task_statuses, TaskStatus.LOCKED);

    for (var task_id = 0; task_id < TaskId.COUNT; task_id++)
    {
        if (!task_status_is_valid(_game_state.task_statuses[task_id]))
            _game_state.task_statuses[task_id] = TaskStatus.LOCKED;
    }

    return _game_state;
}

function task_legacy_current_id(_game_state)
{
    var rank = tutorial_stage_rank(_game_state.tutorial_stage);

    if (_game_state.tutorial_board_assignment_pending)
        return TaskId.FIELDSTONE_BY_HAND;
    if (rank == 2) return TaskId.FIELDSTONE_BY_HAND;
    if (rank >= 3 && rank <= 4) return TaskId.FALLEN_TREE;
    if (rank == 5) return TaskId.STONE_HAUL;
    if (rank >= 6 && rank <= 7) return TaskId.FIT_THE_WINCH;
    if (rank >= 8 && rank <= 12) return TaskId.TIMBER_DELIVERY;
    if (rank >= 13 && !_game_state.cabin_built)
        return TaskId.PARK_SKIDSTEER;

    return -1;
}

function task_state_migrate_from_tutorial(_game_state)
{
    _game_state.task_board_unlocked =
        task_board_should_be_unlocked(_game_state);
    _game_state.task_statuses =
        array_create(TaskId.COUNT, TaskStatus.LOCKED);

    var current_task = task_legacy_current_id(_game_state);
    if (current_task < 0)
    {
        if (_game_state.cabin_site_placed)
        {
            for (var completed_id = 0;
                completed_id < TaskId.COUNT;
                completed_id++)
            {
                _game_state.task_statuses[completed_id] = TaskStatus.CLAIMED;
            }
            _game_state.task_board_unlocked = true;
        }
        return _game_state;
    }

    _game_state.task_board_unlocked = true;
    var story_order = task_get_story_order();
    var current_order_index = task_order_index_of(current_task, story_order);
    for (var prior_index = 0;
        prior_index < current_order_index;
        prior_index++)
    {
        _game_state.task_statuses[story_order[prior_index]] =
            TaskStatus.CLAIMED;
    }

    _game_state.task_statuses[current_task] =
        _game_state.tutorial_board_assignment_pending
            ? TaskStatus.AVAILABLE
            : TaskStatus.ACTIVE;
    return _game_state;
}

function task_state_restore_from_saved(
    _game_state,
    _saved_state
)
{
    if (!variable_struct_exists(_saved_state, "task_board_unlocked")
    || !variable_struct_exists(_saved_state, "task_statuses")
    || !is_array(_saved_state.task_statuses))
    {
        return task_state_migrate_from_tutorial(_game_state);
    }

    _game_state.task_board_unlocked = _saved_state.task_board_unlocked;
    _game_state.task_statuses = save_clone_array(_saved_state.task_statuses);
    return task_state_ensure(_game_state);
}
