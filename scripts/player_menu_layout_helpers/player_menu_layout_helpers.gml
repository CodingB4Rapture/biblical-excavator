/// Shared, read-only geometry for the Quest/Inventory/Map rail and menus.
/// Step and Draw consumers use these descriptors so art and hitboxes cannot drift.

function player_menu_get_rail_layout(_gui_w = -1, _gui_h = -1)
{
    if (_gui_w < 0) _gui_w = display_get_gui_width();
    if (_gui_h < 0) _gui_h = display_get_gui_height();

    var margin = 14;
    var button_gap = 8;
    var panel_gap = 12;
    var quest_width = sprite_get_width(spr_quest_button);
    var quest_height = sprite_get_height(spr_quest_button);
    var inventory_width = sprite_get_width(spr_inventory_button);
    var inventory_height = sprite_get_height(spr_inventory_button);
    var map_width = sprite_get_width(spr_map_button);
    var map_height = sprite_get_height(spr_map_button);
    var rail_width = max(quest_width, max(inventory_width, map_width));
    var quest_left = margin + (rail_width - quest_width) * 0.5;
    var quest_top = margin;
    var inventory_left = margin + (rail_width - inventory_width) * 0.5;
    var inventory_top = quest_top + quest_height + button_gap;
    var map_left = margin + (rail_width - map_width) * 0.5;
    var map_top = inventory_top + inventory_height + button_gap;
    var rail_right = margin + rail_width;

    return {
        gui_w: _gui_w,
        gui_h: _gui_h,
        quest_left: quest_left,
        quest_top: quest_top,
        quest_right: quest_left + quest_width,
        quest_bottom: quest_top + quest_height,
        quest_center_x: quest_left + quest_width * 0.5,
        quest_center_y: quest_top + quest_height * 0.5,
        inventory_left: inventory_left,
        inventory_top: inventory_top,
        inventory_right: inventory_left + inventory_width,
        inventory_bottom: inventory_top + inventory_height,
        inventory_center_x: inventory_left + inventory_width * 0.5,
        inventory_center_y: inventory_top + inventory_height * 0.5,
        map_left: map_left,
        map_top: map_top,
        map_right: map_left + map_width,
        map_bottom: map_top + map_height,
        map_center_x: map_left + map_width * 0.5,
        map_center_y: map_top + map_height * 0.5,
        panel_left: rail_right + panel_gap,
        panel_margin: margin
    };
}

function player_menu_get_panel_bounds(_gui_w = -1, _gui_h = -1)
{
    var rail = player_menu_get_rail_layout(_gui_w, _gui_h);

    return {
        gui_w: rail.gui_w,
        gui_h: rail.gui_h,
        panel_left: rail.panel_left,
        panel_top: rail.panel_margin,
        panel_right: rail.gui_w - rail.panel_margin,
        panel_bottom: rail.gui_h - rail.panel_margin
    };
}

function player_menu_get_quest_layout(_gui_w = -1, _gui_h = -1)
{
    var panel = player_menu_get_panel_bounds(_gui_w, _gui_h);
    var list_width = clamp(
        (panel.panel_right - panel.panel_left) * 0.32,
        150,
        230
    );

    return {
        gui_w: panel.gui_w,
        gui_h: panel.gui_h,
        panel_left: panel.panel_left,
        panel_top: panel.panel_top,
        panel_right: panel.panel_right,
        panel_bottom: panel.panel_bottom,
        list_left: panel.panel_left + 8,
        list_right: panel.panel_left + list_width,
        content_top: panel.panel_top + 48,
        content_bottom: panel.panel_bottom - 34,
        detail_left: panel.panel_left + list_width + 12
    };
}

function player_menu_get_inventory_layout(_gui_w = -1, _gui_h = -1)
{
    var panel = player_menu_get_panel_bounds(_gui_w, _gui_h);
    var tabs_left = panel.panel_left + 10;
    var tabs_right = panel.panel_right - 10;
    var tabs_top = panel.panel_top + 42;
    var tabs_bottom = tabs_top + 30;

    return {
        gui_w: panel.gui_w,
        gui_h: panel.gui_h,
        panel_left: panel.panel_left,
        panel_top: panel.panel_top,
        panel_right: panel.panel_right,
        panel_bottom: panel.panel_bottom,
        tabs_left: tabs_left,
        tabs_right: tabs_right,
        tabs_top: tabs_top,
        tabs_bottom: tabs_bottom,
        content_left: panel.panel_left + 18,
        content_right: panel.panel_right - 18,
        content_top: tabs_bottom + 16,
        content_bottom: panel.panel_bottom - 38
    };
}
