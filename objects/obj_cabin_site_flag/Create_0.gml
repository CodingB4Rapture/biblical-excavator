/// obj_cabin_site_flag - Create Event

site_id = CABIN_SITE_NONE;
site_number = 0;
site_symbol = "";
site_name = "";
site_area_name = "";
site_colour = c_white;
corner_index = -1;
image_speed = 0.08;
interaction_enabled = true;
interaction_radius = 26;
interaction_priority = 46;

interaction_get_prompt = function(_actor)
{
    var game_state = game_state_ensure();

    if (!task_is_active(TaskId.MARK_CABIN_SITE, game_state)
    || game_state.cabin_fence_marked
    || (game_state.cabin_selected_site_id != CABIN_SITE_NONE
        && game_state.cabin_selected_site_id != site_id))
    {
        return "";
    }

    return cabin_site_flag_is_taken(site_id, corner_index, game_state)
        ? "Place Fence"
        : "Take Flag";
};

interaction_run = function(_actor)
{
    if (cabin_site_flag_is_taken(site_id, corner_index))
    {
        cabin_begin_fence_from_flag(id);
        return;
    }

    cabin_take_predefined_flag(id);
};
