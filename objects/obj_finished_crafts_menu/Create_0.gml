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
    var content_bottom = panel_bottom - 72;
    var list_left = panel_left + 24;
    var list_right = panel_right - preview_width - 34;
    var quantity_left = panel_left + 42;
    var quantity_right = panel_right - preview_width - 52;

    return {
        gui_w: gui_w,
        gui_h: gui_h,
        panel_left: panel_left,
        panel_top: panel_top,
        panel_right: panel_right,
        panel_bottom: panel_bottom,
        content_top: panel_top + 68,
        content_bottom: content_bottom,
        list_left: list_left,
        list_right: list_right,
        preview_left: panel_right - preview_width,
        preview_right: panel_right - 24,
        row_height: 54,
        close_left: panel_right - 50,
        close_top: panel_top + 14,
        close_right: panel_right - 18,
        close_bottom: panel_top + 42,
        quantity_panel_top: content_bottom - 104,
        quantity_left: quantity_left,
        quantity_right: quantity_right,
        quantity_track_left: quantity_left + 30,
        quantity_track_right: quantity_right - 30,
        quantity_track_y: content_bottom - 25,
        quantity_back_left: list_left + 12,
        quantity_back_top: content_bottom - 92,
        quantity_back_right: list_left + 112,
        quantity_back_bottom: content_bottom - 56,
        quantity_take_left: list_right - 132,
        quantity_take_top: content_bottom - 92,
        quantity_take_right: list_right - 12,
        quantity_take_bottom: content_bottom - 56
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

finished_crafts_menu_leave_quantity = function()
{
    quantity_mode = false;
    selected_quantity = 1;
    action_message = "";
};

finished_crafts_menu_begin_quantity = function()
{
    var maximum = finished_crafts_menu_get_max_quantity();
    if (maximum > 0)
    {
        quantity_mode = true;
        selected_quantity = 1;
        action_message = "";
        return true;
    }

    var resource_id = finished_crafts_menu_get_selected_resource();
    var game_state = game_state_ensure();
    var chest_amount = resource_id < 0
        ? 0
        : inventory_get_amount(
            game_state.finished_crafts_inventory,
            resource_id
        );
    action_message = chest_amount <= 0
        ? "This finished craft is out of stock."
        : "Your backpack is at its limit for this item.";
    return false;
};

finished_crafts_menu_set_quantity_from_x = function(_mouse_x, _layout)
{
    var maximum = finished_crafts_menu_get_max_quantity();
    if (maximum <= 1)
    {
        selected_quantity = 1;
        return;
    }

    var track_width = max(
        1,
        _layout.quantity_track_right - _layout.quantity_track_left
    );
    var track_ratio = clamp(
        (_mouse_x - _layout.quantity_track_left) / track_width,
        0,
        1
    );
    selected_quantity = 1 + round(track_ratio * (maximum - 1));
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
