/// obj_finished_crafts_menu - Create Event

finished_craft_rows = finished_crafts_get_rows();
selected_row = 0;
quantity_mode = false;
selected_quantity = 1;
input_lock_frames = 2;
action_message = "";
source_chest = noone;

finished_crafts_menu_get_layout = function()
{
    var gui_w = display_get_gui_width();
    var gui_h = display_get_gui_height();
    var panel_width = min(gui_w - 36, 760);
    var panel_height = min(gui_h - 36, 420);
    var panel_left = (gui_w - panel_width) * 0.5;
    var panel_top = (gui_h - panel_height) * 0.5;
    var panel_right = panel_left + panel_width;
    var panel_bottom = panel_top + panel_height;
    var preview_width = clamp(panel_width * 0.34, 180, 250);

    return {
        gui_w: gui_w,
        gui_h: gui_h,
        panel_left: panel_left,
        panel_top: panel_top,
        panel_right: panel_right,
        panel_bottom: panel_bottom,
        content_top: panel_top + 68,
        content_bottom: panel_bottom - 72,
        list_left: panel_left + 24,
        list_right: panel_right - preview_width - 34,
        preview_left: panel_right - preview_width,
        preview_right: panel_right - 24,
        quantity_left: panel_left + 42,
        quantity_right: panel_right - preview_width - 52
    };
};

finished_crafts_menu_get_selected_resource = function()
{
    if (array_length(finished_craft_rows) <= 0) return -1;
    return finished_craft_rows[
        clamp(selected_row, 0, array_length(finished_craft_rows) - 1)
    ];
};

finished_crafts_menu_get_max_quantity = function()
{
    var resource_id = finished_crafts_menu_get_selected_resource();
    if (resource_id < 0) return 0;

    var game_state = game_state_ensure();
    return min(
        inventory_get_amount(
            game_state.finished_crafts_inventory,
            resource_id
        ),
        inventory_get_space(game_state.player_inventory, resource_id)
    );
};

finished_crafts_menu_close = function()
{
    if (instance_exists(source_chest))
        source_chest.image_index = 0;

    input_lock_interaction(3);
    gameplay_set_paused(false);
    instance_destroy();
};

finished_crafts_menu_take_selected = function()
{
    var resource_id = finished_crafts_menu_get_selected_resource();
    var maximum = finished_crafts_menu_get_max_quantity();
    if (resource_id < 0 || maximum <= 0)
    {
        action_message = "Nothing can be moved to your backpack.";
        quantity_mode = false;
        return false;
    }

    selected_quantity = clamp(selected_quantity, 1, maximum);
    var moved = finished_crafts_take(
        game_state_ensure(),
        resource_id,
        selected_quantity
    );
    if (moved <= 0)
    {
        action_message = "Nothing can be moved to your backpack.";
        quantity_mode = false;
        return false;
    }

    var item_name = resource_get_name(resource_id);
    action_message = "Took " + string(moved) + " " + item_name
        + (moved == 1 ? "." : "s.");
    quantity_mode = false;
    selected_quantity = 1;
    save_write();
    return true;
};

gameplay_set_paused(true);
