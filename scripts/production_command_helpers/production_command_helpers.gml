/// Explicit production events. Inputs are reserved up front; completed output
/// is delivered one batch at a time.

function production_output_inventory(_game_state, _definition)
{
    return _definition.output_destination
        == ProductionOutputDestination.HOME
            ? _game_state.home_inventory
            : _game_state.finished_crafts_inventory;
}

function production_start_job(_machine_id, _recipe_id, _batches)
{
    var game_state = game_state_ensure();
    var job = production_job_get(_machine_id, game_state);
    var definition = production_recipe_definition(_recipe_id);
    var batches = max(1, floor(_batches));

    if (is_undefined(job)
    || is_undefined(definition)
    || production_job_is_active(job)
    || definition.machine_type != job.machine_type
    || !production_recipe_is_unlocked(_recipe_id, game_state)
    || batches > production_recipe_max_batches(
        _recipe_id,
        game_state
    ))
    {
        return false;
    }

    var input_total = definition.input_amount * batches;
    if (inventory_get_amount(
        game_state.home_inventory,
        definition.input_id
    ) < input_total)
    {
        return false;
    }

    inventory_remove(
        game_state.home_inventory,
        definition.input_id,
        input_total
    );
    job.recipe_id = _recipe_id;
    job.batch_total = batches;
    job.batch_completed = 0;
    job.seconds_remaining = definition.duration_seconds;
    var job_index = production_state_find_job_index(
        game_state,
        _machine_id
    );
    game_state = production_state_set_job(
        game_state,
        job_index,
        job
    );
    global.game_state = game_state;
    save_write();
    return true;
}

function production_complete_one_batch(_game_state, _job)
{
    if (!production_job_is_active(_job)) return _job;

    var definition = production_recipe_definition(_job.recipe_id);
    if (is_undefined(definition)) return _job;
    var finishing_job =
        _job.batch_completed + 1 >= _job.batch_total;
    var completed_output_total =
        definition.output_amount * _job.batch_total;

    inventory_add(
        production_output_inventory(_game_state, definition),
        definition.output_id,
        definition.output_amount
    );
    production_state_add_completed_batch(
        _game_state,
        _job.recipe_id
    );
    _job.batch_completed += 1;

    if (finishing_job)
    {
        progression_queue_announcement(
            "WORKSHOP READY",
            definition.name,
            [
                string(completed_output_total)
                    + " "
                    + resource_get_name(definition.output_id)
                    + " produced"
            ],
            definition.output_destination
                == ProductionOutputDestination.FINISHED_CRAFTS
                    ? "Pick up the finished pieces from the middle Finished Crafts chest."
                    : "The Timber Planks are in Homebase stock. Reopen the sawmill for the flashing next recipe."
        );
        _job.recipe_id = -1;
        _job.batch_total = 0;
        _job.batch_completed = 0;
        _job.seconds_remaining = 0;
    }
    else
    {
        _job.seconds_remaining = definition.duration_seconds;
    }

    return _job;
}

function production_update()
{
    var game_state = game_state_ensure();
    var elapsed_seconds = max(0, delta_time / 1000000);

    for (var index = 0;
        index < array_length(game_state.production_jobs);
        index++)
    {
        var job = game_state.production_jobs[index];
        if (!production_job_is_active(job)) continue;

        var was_active = true;
        job.seconds_remaining -= elapsed_seconds;
        var safety = 0;
        while (job.seconds_remaining <= 0
        && production_job_is_active(job)
        && safety < 64)
        {
            var overflow = -job.seconds_remaining;
            job = production_complete_one_batch(game_state, job);
            if (production_job_is_active(job))
                job.seconds_remaining -= overflow;
            safety += 1;
        }
        game_state = production_state_set_job(
            game_state,
            index,
            job
        );
        if (was_active && !production_job_is_active(job))
        {
            global.game_state = game_state;
            save_write();
        }
    }
    global.game_state = game_state;
}

function production_cancel_job(_machine_id)
{
    var game_state = game_state_ensure();
    var job = production_job_get(_machine_id, game_state);
    if (is_undefined(job) || !production_job_is_active(job))
        return false;

    var definition = production_recipe_definition(job.recipe_id);
    var unfinished_batches = job.batch_total - job.batch_completed;
    inventory_add(
        game_state.home_inventory,
        definition.input_id,
        definition.input_amount * unfinished_batches
    );
    job.recipe_id = -1;
    job.batch_total = 0;
    job.batch_completed = 0;
    job.seconds_remaining = 0;
    var job_index = production_state_find_job_index(
        game_state,
        _machine_id
    );
    game_state = production_state_set_job(
        game_state,
        job_index,
        job
    );
    global.game_state = game_state;
    save_write();
    return true;
}

function production_finish_all_jobs()
{
    var game_state = game_state_ensure();
    var changed = false;

    for (var index = 0;
        index < array_length(game_state.production_jobs);
        index++)
    {
        var job = game_state.production_jobs[index];
        while (production_job_is_active(job))
        {
            job = production_complete_one_batch(game_state, job);
            changed = true;
        }
        game_state = production_state_set_job(
            game_state,
            index,
            job
        );
    }

    if (changed)
    {
        global.game_state = game_state;
        save_write();
    }
    return changed;
}
