/// obj_fieldstone - Create Event
/// Place these in a room as renewable Fieldstone spawn markers.

resource_id = ResourceId.FIELDSTONE;
renewable_spawn = true;
world_id = variable_instance_exists(id, "spawn_world_id")
    ? spawn_world_id
    : "fieldstone_" + room_get_name(room) + "_"
        + string(round(x)) + "_" + string(round(y));

var fieldstone_record = fieldstone_record_ensure(
    world_id,
    room_get_name(room),
    x,
    y
);

if (!fieldstone_record.present
|| !resource_regeneration_spawn_is_clear(x, y, 5))
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

    if (game_state.tutorial_stage != TutorialStage.TRIP_ONE_HAND_FIELDSTONE
    && game_state.tutorial_stage != TutorialStage.COMPLETE)
    {
        return "";
    }

    if (!inventory_can_add(game_state.player_inventory, resource_id, 1))
    {
        return "Backpack full - deliver supplies";
    }

    return "Pick up Fieldstone";
};

interaction_run = function(_actor)
{
    progress_collect_resource_by_hand(id);
};
