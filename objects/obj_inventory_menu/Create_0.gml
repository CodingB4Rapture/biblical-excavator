/// obj_inventory_menu - Create Event

inventory_categories = [
    "BACKPACK",
    "VEHICLE",
    "HOMEBASE",
    "TOOLS"
];
inventory_resource_rows = [
    ResourceId.FIELDSTONE,
    ResourceId.TIMBER_LOG,
    ResourceId.SMALL_LUMBER
];
selected_category = 0;

// Step and Draw share this layout so mouse tabs match the rendered panels.
inventory_menu_get_layout = function()
{
    var gui_w = display_get_gui_width();
    var gui_h = display_get_gui_height();
    var margin = 14;
    var panel_left = margin;
    var panel_top = margin;
    var panel_right = gui_w - margin;
    var panel_bottom = gui_h - margin;
    var tabs_left = panel_left + 10;
    var tabs_right = panel_right - 10;
    var tabs_top = panel_top + 42;
    var tabs_bottom = tabs_top + 30;

    return {
        gui_w: gui_w,
        gui_h: gui_h,
        panel_left: panel_left,
        panel_top: panel_top,
        panel_right: panel_right,
        panel_bottom: panel_bottom,
        tabs_left: tabs_left,
        tabs_right: tabs_right,
        tabs_top: tabs_top,
        tabs_bottom: tabs_bottom,
        content_left: panel_left + 18,
        content_right: panel_right - 18,
        content_top: tabs_bottom + 16,
        content_bottom: panel_bottom - 38
    };
};

inventory_menu_close = function()
{
    gameplay_set_paused(false);
    instance_destroy();
};

gameplay_set_paused(true);
