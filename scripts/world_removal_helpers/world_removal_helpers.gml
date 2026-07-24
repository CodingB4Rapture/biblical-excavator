/// Durable one-time world-object removal queries and commands.

function save_world_id_is_removed(_world_id)
{
    var game_state = game_state_ensure();

    for (var i = 0; i < array_length(game_state.removed_world_ids); i++)
    {
        if (game_state.removed_world_ids[i] == _world_id)
        {
            return true;
        }
    }

    return false;
}

function save_mark_world_removed(_world_id)
{
    if (_world_id == "" || save_world_id_is_removed(_world_id))
    {
        return;
    }

    var game_state = game_state_ensure();
    array_push(game_state.removed_world_ids, _world_id);
}

function save_unmark_world_removed(_world_id)
{
    var game_state = game_state_ensure();
    var kept_ids = [];
    var removed = false;

    for (var i = 0; i < array_length(game_state.removed_world_ids); i++)
    {
        var saved_id = game_state.removed_world_ids[i];

        if (saved_id == _world_id)
        {
            removed = true;
        }
        else
        {
            array_push(kept_ids, saved_id);
        }
    }

    game_state.removed_world_ids = kept_ids;
    return removed;
}
