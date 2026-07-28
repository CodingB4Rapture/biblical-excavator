/// Read models for machine animation, prompts, progress, and menus.

function production_machine_read_model(
    _machine_id,
    _machine_type,
    _game_state = undefined
)
{
    var game_state = is_undefined(_game_state)
        ? game_state_ensure()
        : _game_state;
    var job = production_job_get(_machine_id, game_state);
    var running = !is_undefined(job)
        && production_job_is_active(job);
    var recipe = running
        ? production_recipe_definition(job.recipe_id)
        : undefined;
    var progress = running
        ? 1 - job.seconds_remaining / max(1, recipe.duration_seconds)
        : 0;
    var unlocked = running
        || array_length(production_machine_available_recipes(
            _machine_type,
            game_state
        )) > 0;

    return {
        machine_id: _machine_id,
        machine_type: _machine_type,
        machine_name: production_machine_name(_machine_type),
        running: running,
        unlocked: unlocked,
        recipe_id: running ? job.recipe_id : -1,
        recipe_name: running ? recipe.name : "",
        batch_number: running ? job.batch_completed + 1 : 0,
        batch_total: running ? job.batch_total : 0,
        progress: clamp(progress, 0, 1),
        prompt: running
            ? "Check " + production_machine_name(_machine_type)
            : (
                unlocked
                    ? "Use " + production_machine_name(_machine_type)
                    : production_machine_name(_machine_type) + " (Locked)"
            )
    };
}

function production_machine_available_recipes(
    _machine_type,
    _game_state = undefined
)
{
    var game_state = is_undefined(_game_state)
        ? game_state_ensure()
        : _game_state;
    var result = [];
    var recipe_ids = production_machine_recipe_ids(_machine_type);

    for (var index = 0; index < array_length(recipe_ids); index++)
    {
        var recipe_id = recipe_ids[index];
        if (production_recipe_is_unlocked(recipe_id, game_state))
            array_push(result, recipe_id);
    }

    return result;
}

function production_recipe_max_batches(_recipe_id, _game_state = undefined)
{
    var game_state = is_undefined(_game_state)
        ? game_state_ensure()
        : _game_state;
    var definition = production_recipe_definition(_recipe_id);
    if (is_undefined(definition)) return 0;
    var stock_max = floor(
        inventory_get_amount(
            game_state.home_inventory,
            definition.input_id
        ) / max(1, definition.input_amount)
    );

    if (task_is_active(TaskId.BUILD_CABIN_FENCE, game_state))
    {
        switch (_recipe_id)
        {
            case ProductionRecipeId.SAW_TIMBER_PLANKS:
            case ProductionRecipeId.CUT_STRAIGHT_FENCE:
            case ProductionRecipeId.CUT_FENCE_CORNERS:
            case ProductionRecipeId.CUT_FENCE_GATE:
                stock_max = min(
                    stock_max,
                    production_tutorial_recipe_remaining_batches(
                        _recipe_id,
                        game_state
                    )
                );
                break;
        }
    }

    return stock_max;
}

function production_tutorial_missing_output(
    _resource_id,
    _game_state = undefined
)
{
    var game_state = is_undefined(_game_state)
        ? game_state_read()
        : _game_state;
    var piece_type = build_resource_piece_type(_resource_id);
    if (piece_type == FencePieceType.LEGACY) return 0;

    var required = cabin_blueprint_missing_piece_count(
        piece_type,
        game_state
    );
    var available =
        inventory_get_amount(game_state.player_inventory, _resource_id)
        + inventory_get_amount(
            game_state.finished_crafts_inventory,
            _resource_id
        );
    return max(0, required - available);
}

function production_tutorial_piece_recipe_batches(
    _recipe_id,
    _game_state
)
{
    var definition = production_recipe_definition(_recipe_id);
    if (is_undefined(definition)
    || !build_resource_is_placeable(definition.output_id))
    {
        return 0;
    }

    return ceil(
        production_tutorial_missing_output(
            definition.output_id,
            _game_state
        ) / max(1, definition.output_amount)
    );
}

function production_tutorial_planks_needed(_game_state)
{
    var required = 0;
    required += production_tutorial_piece_recipe_batches(
        ProductionRecipeId.CUT_STRAIGHT_FENCE,
        _game_state
    );
    required += production_tutorial_piece_recipe_batches(
        ProductionRecipeId.CUT_FENCE_CORNERS,
        _game_state
    );
    required += production_tutorial_piece_recipe_batches(
        ProductionRecipeId.CUT_FENCE_GATE,
        _game_state
    );
    return max(
        0,
        required - inventory_get_amount(
            _game_state.home_inventory,
            ResourceId.TIMBER_PLANK
        )
    );
}

function production_tutorial_recipe_remaining_batches(
    _recipe_id,
    _game_state = undefined
)
{
    var game_state = is_undefined(_game_state)
        ? game_state_read()
        : _game_state;

    if (!task_is_active(TaskId.BUILD_CABIN_FENCE, game_state))
        return 0;

    switch (_recipe_id)
    {
        case ProductionRecipeId.SAW_TIMBER_PLANKS:
            var definition = production_recipe_definition(_recipe_id);
            return ceil(
                production_tutorial_planks_needed(game_state)
                / max(1, definition.output_amount)
            );

        case ProductionRecipeId.CUT_STRAIGHT_FENCE:
        case ProductionRecipeId.CUT_FENCE_CORNERS:
        case ProductionRecipeId.CUT_FENCE_GATE:
            return production_tutorial_piece_recipe_batches(
                _recipe_id,
                game_state
            );
    }
    return 0;
}

function production_tutorial_recipe_target(_game_state = undefined)
{
    var game_state = is_undefined(_game_state)
        ? game_state_read()
        : _game_state;
    if (!task_is_active(TaskId.BUILD_CABIN_FENCE, game_state))
        return undefined;

    var ordered_recipes = [
        ProductionRecipeId.SAW_TIMBER_PLANKS,
        ProductionRecipeId.CUT_STRAIGHT_FENCE,
        ProductionRecipeId.CUT_FENCE_CORNERS,
        ProductionRecipeId.CUT_FENCE_GATE
    ];
    for (var index = 0;
        index < array_length(ordered_recipes);
        index++)
    {
        var recipe_id = ordered_recipes[index];
        var batches = production_tutorial_recipe_remaining_batches(
            recipe_id,
            game_state
        );
        if (batches > 0)
        {
            var definition = production_recipe_definition(recipe_id);
            return {
                recipe_id: recipe_id,
                batches: batches,
                output_total: batches * definition.output_amount,
                definition: definition
            };
        }
    }
    return undefined;
}

function production_tutorial_usable_piece_count(
    _inventory,
    _game_state
)
{
    var count = 0;
    var resources = [
        ResourceId.FENCE_STRAIGHT,
        ResourceId.FENCE_CORNER,
        ResourceId.FENCE_GATE
    ];
    for (var index = 0; index < array_length(resources); index++)
    {
        var resource_id = resources[index];
        count += min(
            cabin_blueprint_missing_piece_count(
                build_resource_piece_type(resource_id),
                _game_state
            ),
            inventory_get_amount(_inventory, resource_id)
        );
    }
    return count;
}

function production_tutorial_next_step(_game_state = undefined)
{
    var game_state = is_undefined(_game_state)
        ? game_state_read()
        : _game_state;
    var blueprint = cabin_blueprint_status(game_state);

    if (blueprint.complete)
    {
        return {
            kind: "complete",
            blueprint: blueprint,
            target: undefined
        };
    }

    if (production_tutorial_usable_piece_count(
        game_state.player_inventory,
        game_state
    ) > 0)
    {
        return {
            kind: "place",
            blueprint: blueprint,
            target: undefined
        };
    }

    if (production_tutorial_usable_piece_count(
        game_state.finished_crafts_inventory,
        game_state
    ) > 0)
    {
        return {
            kind: "collect",
            blueprint: blueprint,
            target: undefined
        };
    }

    var saw_job = production_job_get(
        PRODUCTION_MACHINE_SAWMILL,
        game_state
    );
    if (production_job_is_active(saw_job))
    {
        return {
            kind: "wait",
            blueprint: blueprint,
            target: production_recipe_definition(saw_job.recipe_id)
        };
    }

    var target = production_tutorial_recipe_target(game_state);
    if (is_undefined(target))
    {
        return {
            kind: "place",
            blueprint: blueprint,
            target: undefined
        };
    }

    var input_available = inventory_get_amount(
        game_state.home_inventory,
        target.definition.input_id
    );
    if (target.recipe_id == ProductionRecipeId.SAW_TIMBER_PLANKS
    && input_available < target.definition.input_amount)
    {
        return {
            kind: "recover_log",
            blueprint: blueprint,
            target: target
        };
    }

    return {
        kind: "craft",
        blueprint: blueprint,
        target: target
    };
}
