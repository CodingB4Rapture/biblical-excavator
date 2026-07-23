/// obj_task_board - Create Event
/// Assign finished art directly to this object later; the interaction and save
/// behavior do not depend on a particular sprite.

interaction_enabled = true;
interaction_radius = 38;
interaction_priority = 52;

interaction_get_prompt = function(_actor)
{
    var game_state = game_state_ensure();
    if (!game_state.task_board_unlocked) return "Inspect Task Board";
    if (game_state.tutorial_board_assignment_pending) return "Accept First Task";
    return "Read Task Board";
};

interaction_run = function(_actor)
{
    var game_state = game_state_ensure();

    if (!game_state.task_board_unlocked)
    {
        notification_show_hint(
            "The board is empty for now. Speak with the Farmer's Wife about the first job.",
            game_get_speed(gamespeed_fps) * 4,
            false
        );
        return;
    }

    if (instance_exists(obj_task_board_menu)
    || instance_exists(obj_quest_menu)
    || instance_exists(obj_inventory_menu)
    || dialogue_is_active())
    {
        return;
    }

    input_lock_interaction(3);
    instance_create_depth(0, 0, -5000, obj_task_board_menu);
};
