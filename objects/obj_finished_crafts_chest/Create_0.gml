/// obj_finished_crafts_chest - Create Event

image_speed = 0;
image_index = 0;

interaction_enabled = true;
interaction_radius = 48;
interaction_priority = 48;

interaction_get_prompt = function(_actor)
{
    return finished_crafts_is_available(game_state_read())
        ? "Open Finished Crafts"
        : "Finished Crafts (Reserved)";
};

interaction_run = function(_actor)
{
    var game_state = game_state_ensure();
    if (!finished_crafts_is_available(game_state))
    {
        var cabin_task_available = task_get_status(
            TaskId.PLACE_CABIN,
            game_state
        ) == TaskStatus.AVAILABLE;
        notification_show_hint(
            cabin_task_available
                ? "Accept Build the Cabin at the Task Board before taking the finished planks."
                : "The finished planks are reserved until the cabin build begins.",
            game_get_speed(gamespeed_fps) * 4,
            false
        );
        return;
    }

    if (instance_exists(obj_finished_crafts_menu)
    || instance_exists(obj_task_board_menu)
    || instance_exists(obj_quest_menu)
    || instance_exists(obj_inventory_menu)
    || dialogue_is_active())
    {
        return;
    }

    input_lock_interaction(3);
    var chest_menu = instance_create_depth(
        0,
        0,
        -5000,
        obj_finished_crafts_menu
    );
    chest_menu.source_chest = id;
    image_index = 1;
};
