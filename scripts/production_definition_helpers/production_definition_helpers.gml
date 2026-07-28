/// Stable machine and recipe definitions.

function production_machine_definitions()
{
    return [
        {
            id: PRODUCTION_MACHINE_SAWMILL,
            machine_type: ProductionMachineType.SAWMILL,
            display_name: "Sawmill",
            room_name: "Room1",
            x: 496,
            y: 32,
            object_type: obj_sawmill,
            unlock_rule: "cabin_boundary",
            recipe_ids: [
                ProductionRecipeId.SAW_TIMBER_PLANKS,
                ProductionRecipeId.CUT_STRAIGHT_FENCE,
                ProductionRecipeId.CUT_FENCE_CORNERS,
                ProductionRecipeId.CUT_FENCE_GATE
            ]
        },
        {
            id: PRODUCTION_MACHINE_LATHE,
            machine_type: ProductionMachineType.LATHE,
            display_name: "Lathe",
            room_name: "Room1",
            x: 400,
            y: 32,
            object_type: obj_lathe,
            unlock_rule: "cabin_built",
            recipe_ids: [ProductionRecipeId.TURN_EMPTY_BUCKET]
        }
    ];
}

function production_machine_definition(_machine_id)
{
    var definitions = production_machine_definitions();
    for (var index = 0; index < array_length(definitions); index++)
    {
        if (definitions[index].id == _machine_id)
            return definitions[index];
    }
    return undefined;
}

function production_machine_definition_for_type(_machine_type)
{
    var definitions = production_machine_definitions();
    for (var index = 0; index < array_length(definitions); index++)
    {
        if (definitions[index].machine_type == _machine_type)
            return definitions[index];
    }
    return undefined;
}

function production_recipe_definition(_recipe_id)
{
    switch (_recipe_id)
    {
        case ProductionRecipeId.SAW_TIMBER_PLANKS:
            return {
                id: _recipe_id,
                machine_type: ProductionMachineType.SAWMILL,
                name: "Saw Timber Planks",
                input_id: ResourceId.TIMBER_LOG,
                input_amount: 1,
                input_source: ProductionInputSource.HOME,
                output_id: ResourceId.TIMBER_PLANK,
                output_amount: 4,
                duration_seconds: 12,
                output_destination:
                    ProductionOutputDestination.FINISHED_CRAFTS
            };

        case ProductionRecipeId.CUT_STRAIGHT_FENCE:
            return {
                id: _recipe_id,
                machine_type: ProductionMachineType.SAWMILL,
                name: "Cut Straight Fence",
                input_id: ResourceId.TIMBER_PLANK,
                input_amount: 1,
                input_source: ProductionInputSource.CARRIED,
                output_id: ResourceId.FENCE_STRAIGHT,
                output_amount: 5,
                duration_seconds: 8,
                output_destination:
                    ProductionOutputDestination.FINISHED_CRAFTS
            };

        case ProductionRecipeId.CUT_FENCE_CORNERS:
            return {
                id: _recipe_id,
                machine_type: ProductionMachineType.SAWMILL,
                name: "Cut Fence Corners",
                input_id: ResourceId.TIMBER_PLANK,
                input_amount: 1,
                input_source: ProductionInputSource.CARRIED,
                output_id: ResourceId.FENCE_CORNER,
                output_amount: 4,
                duration_seconds: 8,
                output_destination:
                    ProductionOutputDestination.FINISHED_CRAFTS
            };

        case ProductionRecipeId.CUT_FENCE_GATE:
            return {
                id: _recipe_id,
                machine_type: ProductionMachineType.SAWMILL,
                name: "Cut Fence Gate",
                input_id: ResourceId.TIMBER_PLANK,
                input_amount: 1,
                input_source: ProductionInputSource.CARRIED,
                output_id: ResourceId.FENCE_GATE,
                output_amount: 1,
                duration_seconds: 10,
                output_destination:
                    ProductionOutputDestination.FINISHED_CRAFTS
            };

        case ProductionRecipeId.TURN_EMPTY_BUCKET:
            return {
                id: _recipe_id,
                machine_type: ProductionMachineType.LATHE,
                name: "Turn Empty Bucket",
                input_id: ResourceId.SMALL_LUMBER,
                input_amount: 1,
                input_source: ProductionInputSource.HOME,
                output_id: ResourceId.EMPTY_BUCKET,
                output_amount: 1,
                duration_seconds: 12,
                output_destination:
                    ProductionOutputDestination.FINISHED_CRAFTS
            };
    }

    return undefined;
}

function production_machine_recipe_ids(_machine_type)
{
    var definition = production_machine_definition_for_type(_machine_type);
    return is_undefined(definition) ? [] : definition.recipe_ids;
}

function production_machine_name(_machine_type)
{
    var definition = production_machine_definition_for_type(_machine_type);
    return is_undefined(definition)
        ? "Unknown Machine"
        : definition.display_name;
}

function production_recipe_is_unlocked(_recipe_id, _game_state)
{
    if (_recipe_id == ProductionRecipeId.TURN_EMPTY_BUCKET)
    {
        return _game_state.cabin_built;
    }

    return task_is_active(TaskId.BUILD_CABIN_FENCE, _game_state)
        || task_get_status(
            TaskId.BUILD_CABIN_FENCE,
            _game_state
        ) >= TaskStatus.COMPLETE
        || _game_state.free_build_unlocked;
}
