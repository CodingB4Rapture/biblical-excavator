/// Task reward validation and atomic application.

function task_reward_is_valid(_reward)
{
    if (!is_struct(_reward)
    || !variable_struct_exists(_reward, "type")
    || !variable_struct_exists(_reward, "amount")
    || !is_real(_reward.amount)
    || _reward.amount < 0)
    {
        return false;
    }

    switch (_reward.type)
    {
        case TaskRewardType.EQUIPMENT_XP:
            return true;

        case TaskRewardType.HOME_RESOURCE:
            return variable_struct_exists(_reward, "resource_id")
                && _reward.resource_id >= 0
                && _reward.resource_id < ResourceId.COUNT;
    }

    return false;
}

function task_apply_reward(_reward, _game_state)
{
    if (!task_reward_is_valid(_reward)) return false;

    switch (_reward.type)
    {
        case TaskRewardType.EQUIPMENT_XP:
            _game_state.equipment_xp += _reward.amount;
            return true;

        case TaskRewardType.HOME_RESOURCE:
            inventory_add(
                _game_state.home_inventory,
                _reward.resource_id,
                _reward.amount
            );
            return true;
    }

    return false;
}

function task_apply_rewards_atomically(_rewards, _game_state)
{
    if (!is_array(_rewards)) return false;

    for (var validation_index = 0;
        validation_index < array_length(_rewards);
        validation_index++)
    {
        if (!task_reward_is_valid(_rewards[validation_index]))
            return false;
    }

    for (var apply_index = 0;
        apply_index < array_length(_rewards);
        apply_index++)
    {
        task_apply_reward(_rewards[apply_index], _game_state);
    }

    return true;
}
