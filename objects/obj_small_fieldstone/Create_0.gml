/// obj_small_fieldstone - Create Event

resource_id = ResourceId.FIELDSTONE;
world_id = "small_fieldstone_" + string(round(x)) + "_" + string(round(y));

if (save_world_id_is_removed(world_id))
{
    instance_destroy();
    exit;
}

interaction_enabled = true;
interaction_radius = 20;
interaction_priority = 12;

interaction_get_prompt = function(_actor)
{
    var game_state = game_state_ensure();

    if (game_state.tutorial_stage != TutorialStage.TRIP_ONE_HAND_FIELDSTONE)
    {
        return "";
    }

    if (!inventory_can_add(game_state.player_inventory, resource_id, 1))
    {
        return "Backpack full - deliver supplies";
    }

    return "Pick up small fieldstone";
};

interaction_run = function(_actor)
{
    progress_collect_rock_by_hand(id);
};
