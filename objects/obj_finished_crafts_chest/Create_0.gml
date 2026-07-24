/// obj_finished_crafts_chest - Create Event

image_speed = 0;
image_index = 0;

interaction_enabled = true;
interaction_radius = 48;
interaction_priority = 48;

interaction_get_prompt = function(_actor)
{
    return "Open Finished Crafts";
};

interaction_run = function(_actor)
{
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
