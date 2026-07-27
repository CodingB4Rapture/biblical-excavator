/// Explicit runtime transitions for the Quest, Inventory, and Map menus.
/// Open state is derived from live menu instances and is never saved.

function player_menu_is_open()
{
    return instance_exists(obj_quest_menu)
        || instance_exists(obj_inventory_menu)
        || instance_exists(obj_map_menu);
}

function player_menu_day_transition_is_active()
{
    var controller = instance_find(obj_game_controller, 0);
    return instance_exists(controller)
        && controller.day_transition_active;
}

function player_menu_navigation_is_available()
{
    if (room == rm_main_menu
    || dialogue_is_active()
    || player_menu_day_transition_is_active()
    || instance_exists(obj_pause_menu)
    || instance_exists(obj_cabin_placement_controller)
    || instance_exists(obj_fence_planning_controller))
    {
        return false;
    }

    // Player menus intentionally remain navigable while they own pause.
    return !gameplay_is_paused() || player_menu_is_open();
}

function player_menu_close()
{
    with (obj_quest_menu) instance_destroy();
    with (obj_inventory_menu) instance_destroy();
    with (obj_map_menu) instance_destroy();
    gameplay_set_paused(false);
    return true;
}

function player_menu_open_quest()
{
    if (!player_menu_navigation_is_available()) return false;

    with (obj_inventory_menu) instance_destroy();
    with (obj_map_menu) instance_destroy();
    if (!instance_exists(obj_quest_menu))
    {
        instance_create_depth(0, 0, -5000, obj_quest_menu);
    }

    gameplay_set_paused(true);
    return true;
}

function player_menu_open_inventory()
{
    if (!player_menu_navigation_is_available()) return false;

    with (obj_quest_menu) instance_destroy();
    with (obj_map_menu) instance_destroy();
    if (!instance_exists(obj_inventory_menu))
    {
        instance_create_depth(0, 0, -5000, obj_inventory_menu);
    }

    gameplay_set_paused(true);
    return true;
}

function player_menu_toggle_quest()
{
    if (!player_menu_navigation_is_available()) return false;
    if (instance_exists(obj_quest_menu)) return player_menu_close();
    return player_menu_open_quest();
}

function player_menu_toggle_inventory()
{
    if (!player_menu_navigation_is_available()) return false;
    if (instance_exists(obj_inventory_menu)) return player_menu_close();
    return player_menu_open_inventory();
}

function player_menu_open_map()
{
    if (!player_menu_navigation_is_available()) return false;

    with (obj_quest_menu) instance_destroy();
    with (obj_inventory_menu) instance_destroy();
    if (!instance_exists(obj_map_menu))
    {
        instance_create_depth(0, 0, -5000, obj_map_menu);
    }

    gameplay_set_paused(true);
    return true;
}

function player_menu_toggle_map()
{
    if (!player_menu_navigation_is_available()) return false;
    if (instance_exists(obj_map_menu)) return player_menu_close();
    return player_menu_open_map();
}
