/// Durable production-job schema and normalization.

function production_input_inventory(_game_state, _definition)
{
    return _definition.input_source == ProductionInputSource.CARRIED
        ? _game_state.player_inventory
        : _game_state.home_inventory;
}

function production_job_create(_machine_id, _machine_type)
{
    return {
        machine_id: _machine_id,
        machine_type: _machine_type,
        recipe_id: -1,
        batch_total: 0,
        batch_completed: 0,
        seconds_remaining: 0
    };
}

function production_job_is_active(_job)
{
    return is_struct(_job)
        && variable_struct_exists(_job, "recipe_id")
        && _job.recipe_id >= 0
        && _job.batch_total > _job.batch_completed;
}

function production_job_sanitize(_job, _machine_id, _machine_type)
{
    if (!is_struct(_job)
    || !variable_struct_exists(_job, "machine_id")
    || _job.machine_id != _machine_id)
    {
        return production_job_create(_machine_id, _machine_type);
    }

    _job.machine_type = _machine_type;
    if (!variable_struct_exists(_job, "recipe_id")
    || !is_numeric(_job.recipe_id)
    || is_undefined(production_recipe_definition(_job.recipe_id)))
    {
        _job.recipe_id = -1;
    }
    if (!variable_struct_exists(_job, "batch_total")
    || !is_numeric(_job.batch_total))
        _job.batch_total = 0;
    if (!variable_struct_exists(_job, "batch_completed")
    || !is_numeric(_job.batch_completed))
        _job.batch_completed = 0;
    if (!variable_struct_exists(_job, "seconds_remaining")
    || !is_numeric(_job.seconds_remaining))
        _job.seconds_remaining = 0;

    _job.batch_total = max(0, floor(_job.batch_total));
    _job.batch_completed = clamp(
        floor(_job.batch_completed),
        0,
        _job.batch_total
    );
    _job.seconds_remaining = max(0, _job.seconds_remaining);

    if (_job.recipe_id < 0
    || _job.batch_completed >= _job.batch_total)
    {
        _job.recipe_id = -1;
        _job.batch_total = 0;
        _job.batch_completed = 0;
        _job.seconds_remaining = 0;
    }

    return _job;
}

function production_state_find_job_index(_game_state, _machine_id)
{
    for (var index = 0;
        index < array_length(_game_state.production_jobs);
        index++)
    {
        if (is_struct(_game_state.production_jobs[index])
        && _game_state.production_jobs[index].machine_id == _machine_id)
        {
            return index;
        }
    }

    return -1;
}

function production_state_set_job(_game_state, _index, _job)
{
    var jobs = _game_state.production_jobs;
    jobs[_index] = _job;
    _game_state.production_jobs = jobs;
    return _game_state;
}

function production_state_add_completed_batch(_game_state, _recipe_id)
{
    var completed = _game_state.production_completed_batches;
    completed[_recipe_id] += 1;
    _game_state.production_completed_batches = completed;
    return completed[_recipe_id];
}

function production_state_ensure_job(
    _game_state,
    _machine_id,
    _machine_type
)
{
    var index = production_state_find_job_index(
        _game_state,
        _machine_id
    );
    if (index < 0)
    {
        var jobs = _game_state.production_jobs;
        array_push(
            jobs,
            production_job_create(_machine_id, _machine_type)
        );
        _game_state.production_jobs = jobs;
        return array_length(jobs) - 1;
    }

    _game_state = production_state_set_job(
        _game_state,
        index,
        production_job_sanitize(
            _game_state.production_jobs[index],
            _machine_id,
            _machine_type
        )
    );
    return index;
}

function production_state_ensure(_game_state)
{
    if (!variable_struct_exists(_game_state, "production_jobs")
    || !is_array(_game_state.production_jobs))
    {
        _game_state.production_jobs = [
            production_job_create(
                PRODUCTION_MACHINE_SAWMILL,
                ProductionMachineType.SAWMILL
            ),
            production_job_create(
                PRODUCTION_MACHINE_LATHE,
                ProductionMachineType.LATHE
            )
        ];
    }

    if (!variable_struct_exists(
        _game_state,
        "production_completed_batches"
    ) || !is_array(_game_state.production_completed_batches))
    {
        _game_state.production_completed_batches =
            array_create(ProductionRecipeId.COUNT, 0);
    }
    while (array_length(_game_state.production_completed_batches)
        < ProductionRecipeId.COUNT)
    {
        var completed_batches = _game_state.production_completed_batches;
        array_push(completed_batches, 0);
        _game_state.production_completed_batches = completed_batches;
    }
    for (var recipe_id = 0;
        recipe_id < ProductionRecipeId.COUNT;
        recipe_id++)
    {
        var completed =
            _game_state.production_completed_batches[recipe_id];
        _game_state.production_completed_batches[recipe_id] =
            is_numeric(completed) ? max(0, floor(completed)) : 0;
    }

    production_state_ensure_job(
        _game_state,
        PRODUCTION_MACHINE_SAWMILL,
        ProductionMachineType.SAWMILL
    );
    production_state_ensure_job(
        _game_state,
        PRODUCTION_MACHINE_LATHE,
        ProductionMachineType.LATHE
    );
    return _game_state;
}

function production_job_get(
    _machine_id,
    _game_state = undefined
)
{
    var game_state = is_undefined(_game_state)
        ? game_state_ensure()
        : _game_state;
    production_state_ensure(game_state);
    var index = production_state_find_job_index(game_state, _machine_id);
    return index < 0 ? undefined : game_state.production_jobs[index];
}
