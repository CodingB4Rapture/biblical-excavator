/// Durable water-supply tutorial policy and inventory transactions.
///
/// Only the broad story state is persisted. The current instruction is
/// derived from the lathe job and real inventories so crafting, collection,
/// filling, and depositing cannot drift out of sync.

function water_tutorial_stage_is_valid(_stage)
{
    return _stage == WaterTutorialStage.LOCKED
        || _stage == WaterTutorialStage.ACTIVE
        || _stage == WaterTutorialStage.COMPLETE;
}

function water_supply_state_ensure(_game_state)
{
    if (!variable_struct_exists(_game_state, "water_tank_amount")
    || !is_numeric(_game_state.water_tank_amount))
    {
        _game_state.water_tank_amount = WATER_TANK_START_AMOUNT;
    }
    _game_state.water_tank_amount = clamp(
        floor(_game_state.water_tank_amount),
        0,
        WATER_TANK_CAPACITY
    );

    if (!variable_struct_exists(_game_state, "water_tutorial_stage")
    || !water_tutorial_stage_is_valid(
        _game_state.water_tutorial_stage
    ))
    {
        _game_state.water_tutorial_stage =
            !_game_state.cabin_built
                ? WaterTutorialStage.LOCKED
                : (
                    _game_state.day_number > 1
                    || _game_state.homestead_stage
                        == HomesteadStage.HUB_OPEN
                        ? WaterTutorialStage.COMPLETE
                        : WaterTutorialStage.ACTIVE
                );
    }

    if (!_game_state.cabin_built)
    {
        _game_state.water_tutorial_stage = WaterTutorialStage.LOCKED;
        _game_state.homestead_stage = HomesteadStage.TUTORIAL;
        return _game_state;
    }

    if (_game_state.day_number > 1
    || _game_state.homestead_stage == HomesteadStage.HUB_OPEN)
    {
        _game_state.water_tutorial_stage = WaterTutorialStage.COMPLETE;
        _game_state.water_tank_amount = max(
            WATER_TANK_START_AMOUNT + 1,
            _game_state.water_tank_amount
        );
        return _game_state;
    }

    if (_game_state.water_tutorial_stage == WaterTutorialStage.LOCKED)
        _game_state.water_tutorial_stage = WaterTutorialStage.ACTIVE;

    if (_game_state.water_tutorial_stage == WaterTutorialStage.ACTIVE
    && _game_state.water_tank_amount > WATER_TANK_START_AMOUNT)
    {
        _game_state.water_tutorial_stage = WaterTutorialStage.COMPLETE;
    }

    _game_state.homestead_stage =
        _game_state.water_tutorial_stage == WaterTutorialStage.ACTIVE
            ? HomesteadStage.WATER_SUPPLY_REQUIRED
            : HomesteadStage.FIRST_REST_REQUIRED;
    return _game_state;
}

function water_tutorial_is_active(_game_state = undefined)
{
    var game_state = is_undefined(_game_state)
        ? game_state_read()
        : _game_state;
    return game_state.water_tutorial_stage
        == WaterTutorialStage.ACTIVE;
}

function water_tutorial_next_step(_game_state = undefined)
{
    var game_state = is_undefined(_game_state)
        ? game_state_read()
        : _game_state;

    if (game_state.water_tutorial_stage
        == WaterTutorialStage.COMPLETE)
    {
        return {kind: "complete"};
    }
    if (game_state.water_tutorial_stage
        != WaterTutorialStage.ACTIVE)
    {
        return {kind: "locked"};
    }

    if (inventory_get_amount(
        game_state.player_inventory,
        ResourceId.WATER_BUCKET
    ) > 0)
    {
        return {kind: "deposit"};
    }

    if (inventory_get_amount(
        game_state.player_inventory,
        ResourceId.EMPTY_BUCKET
    ) > 0)
    {
        return {kind: "fill"};
    }

    if (inventory_get_amount(
        game_state.finished_crafts_inventory,
        ResourceId.EMPTY_BUCKET
    ) > 0)
    {
        return {kind: "collect"};
    }

    var lathe_job = production_job_get(
        PRODUCTION_MACHINE_LATHE,
        game_state
    );
    if (production_job_is_active(lathe_job)
    && lathe_job.recipe_id == ProductionRecipeId.TURN_EMPTY_BUCKET)
    {
        return {kind: "wait"};
    }

    return {kind: "make"};
}

function water_fill_bucket_state(_game_state)
{
    if (!is_struct(_game_state)
    || inventory_get_amount(
        _game_state.player_inventory,
        ResourceId.EMPTY_BUCKET
    ) <= 0
    || !inventory_can_add(
        _game_state.player_inventory,
        ResourceId.WATER_BUCKET,
        1
    ))
    {
        return false;
    }

    inventory_remove(
        _game_state.player_inventory,
        ResourceId.EMPTY_BUCKET,
        1
    );
    inventory_add(
        _game_state.player_inventory,
        ResourceId.WATER_BUCKET,
        1
    );
    return true;
}

function water_deposit_bucket_state(_game_state)
{
    if (!is_struct(_game_state)
    || _game_state.water_tank_amount >= WATER_TANK_CAPACITY
    || inventory_get_amount(
        _game_state.player_inventory,
        ResourceId.WATER_BUCKET
    ) <= 0
    || !inventory_can_add(
        _game_state.player_inventory,
        ResourceId.EMPTY_BUCKET,
        1
    ))
    {
        return false;
    }

    inventory_remove(
        _game_state.player_inventory,
        ResourceId.WATER_BUCKET,
        1
    );
    inventory_add(
        _game_state.player_inventory,
        ResourceId.EMPTY_BUCKET,
        1
    );
    _game_state.water_tank_amount = min(
        WATER_TANK_CAPACITY,
        _game_state.water_tank_amount + 1
    );

    if (_game_state.water_tutorial_stage
        == WaterTutorialStage.ACTIVE
    && _game_state.water_tank_amount > WATER_TANK_START_AMOUNT)
    {
        _game_state.water_tutorial_stage = WaterTutorialStage.COMPLETE;
        _game_state.homestead_stage =
            HomesteadStage.FIRST_REST_REQUIRED;
    }
    return true;
}
