/// obj_inventory_menu - Draw GUI Event

draw_set_font(-1);

var layout = inventory_menu_get_layout();
var game_state = game_state_ensure();
var category_count = array_length(inventory_categories);
var panel_left = layout.panel_left;
var panel_top = layout.panel_top;
var panel_right = layout.panel_right;
var panel_bottom = layout.panel_bottom;

draw_set_alpha(0.72);
draw_set_color(make_color_rgb(14, 13, 11));
draw_rectangle(0, 0, layout.gui_w, layout.gui_h, false);

draw_set_alpha(0.98);
draw_set_color(make_color_rgb(70, 50, 27));
draw_roundrect(panel_left, panel_top, panel_right, panel_bottom, false);
draw_set_color(make_color_rgb(213, 164, 67));
draw_roundrect(panel_left + 2, panel_top + 2, panel_right - 2, panel_bottom - 2, true);
draw_set_color(make_color_rgb(31, 28, 23));
draw_roundrect(panel_left + 5, panel_top + 5, panel_right - 5, panel_bottom - 5, false);

draw_set_alpha(1);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(make_color_rgb(255, 220, 92));
draw_text(panel_left + 12, panel_top + 10, "INVENTORY");

var tab_width = (layout.tabs_right - layout.tabs_left) / category_count;
for (var tab = 0; tab < category_count; tab++)
{
    var tab_left = layout.tabs_left + tab * tab_width;
    var tab_right = tab_left + tab_width - 3;

    draw_set_color(tab == selected_category
        ? make_color_rgb(76, 66, 49)
        : make_color_rgb(45, 41, 34));
    draw_roundrect(tab_left, layout.tabs_top, tab_right, layout.tabs_bottom, false);

    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_set_color(tab == selected_category
        ? make_color_rgb(255, 220, 92)
        : make_color_rgb(190, 180, 157));
    draw_text(
        (tab_left + tab_right) * 0.5,
        (layout.tabs_top + layout.tabs_bottom) * 0.5,
        inventory_categories[tab]
    );
}

draw_set_halign(fa_left);
draw_set_valign(fa_top);

if (selected_category == 3)
{
    draw_set_color(make_color_rgb(255, 220, 92));
    draw_text(layout.content_left, layout.content_top, "TOOLS & ATTACHMENTS");

    draw_set_color(make_color_rgb(210, 200, 177));
    draw_text(
        layout.content_left,
        layout.content_top + 22,
        "Tool unlocks are persistent and do not use backpack space."
    );

    var tool_row_top = layout.content_top + 58;
    var tool_row_height = 52;

    draw_set_color(make_color_rgb(50, 45, 37));
    draw_roundrect(
        layout.content_left,
        tool_row_top,
        layout.content_right,
        tool_row_top + tool_row_height - 4,
        false
    );
    draw_set_color(make_color_rgb(238, 225, 195));
    draw_text(layout.content_left + 12, tool_row_top + 8, "Axe");
    draw_set_color(make_color_rgb(178, 166, 139));
    draw_text(layout.content_left + 12, tool_row_top + 26, "Used automatically when chopping standing trees.");
    draw_set_halign(fa_right);
    draw_set_color(game_state.tools.axe_owned
        ? make_color_rgb(151, 194, 126)
        : make_color_rgb(194, 72, 61));
    draw_text(
        layout.content_right - 12,
        tool_row_top + 8,
        game_state.tools.axe_owned ? "OWNED" : "LOCKED"
    );

    tool_row_top += tool_row_height;
    draw_set_halign(fa_left);
    draw_set_color(make_color_rgb(50, 45, 37));
    draw_roundrect(
        layout.content_left,
        tool_row_top,
        layout.content_right,
        tool_row_top + tool_row_height - 4,
        false
    );
    draw_set_color(make_color_rgb(238, 225, 195));
    draw_text(layout.content_left + 12, tool_row_top + 8, "Skidsteer Winch");
    draw_set_color(make_color_rgb(178, 166, 139));
    draw_text(layout.content_left + 12, tool_row_top + 26, "Pulls downed trees and stumps.");
    draw_set_halign(fa_right);
    draw_set_color(game_state.winch_attachment_state == AttachmentState.INSTALLED
        ? make_color_rgb(151, 194, 126)
        : make_color_rgb(232, 190, 65));
    draw_text(
        layout.content_right - 12,
        tool_row_top + 8,
        string_upper(attachment_get_status_text())
    );
}
else
{
    var shown_inventory = game_state.player_inventory;
    var storage_title = "PLAYER BACKPACK";
    var storage_description = "Supplies carried by hand.";
    var storage_available = true;

    if (selected_category == 1)
    {
        var vehicle = progress_get_vehicle();
        storage_title = "VEHICLE CARGO";
        storage_description = "Loose material carried by the skidsteer.";
        storage_available = instance_exists(vehicle);

        if (storage_available)
        {
            shown_inventory = vehicle.cargo_inventory;
        }
    }
    else if (selected_category == 2)
    {
        shown_inventory = game_state.home_inventory;
        storage_title = "HOMEBASE INVENTORY";
        storage_description = "Resources secured through Home Delivery.";
    }

    draw_set_color(make_color_rgb(255, 220, 92));
    draw_text(layout.content_left, layout.content_top, storage_title);
    draw_set_color(make_color_rgb(210, 200, 177));
    draw_text(layout.content_left, layout.content_top + 22, storage_description);

    if (!storage_available)
    {
        draw_set_color(make_color_rgb(178, 166, 139));
        draw_text(layout.content_left, layout.content_top + 62, "No work vehicle is available in this area.");
    }
    else
    {
        var storage_total = inventory_get_total(shown_inventory);
        var capacity_text = shown_inventory.capacity < 0
            ? "Storage: Unlimited"
            : "Capacity: " + string(storage_total) + " / " + string(shown_inventory.capacity);
        if (selected_category == 0)
        {
            capacity_text = "Limits: "
                + string(inventory_get_resource_capacity(
                    shown_inventory,
                    ResourceId.FIELDSTONE
                ))
                + " stone | "
                + string(inventory_get_resource_capacity(
                    shown_inventory,
                    ResourceId.TIMBER_PLANK
                ))
                + " planks";
        }

        draw_set_halign(fa_right);
        draw_set_color(make_color_rgb(232, 209, 158));
        draw_text(layout.content_right, layout.content_top, capacity_text);
        draw_set_halign(fa_left);

        var row_top = layout.content_top + 54;
        var available_height = layout.content_bottom - row_top;
        var resource_row_height = min(58, available_height / array_length(inventory_resource_rows));

        for (var row = 0; row < array_length(inventory_resource_rows); row++)
        {
            var resource_id = inventory_resource_rows[row];
            var definition = resource_get_definition(resource_id);
            var amount = inventory_get_amount(shown_inventory, resource_id);
            var item_top = row_top + row * resource_row_height;
            var item_bottom = item_top + resource_row_height - 5;

            draw_set_color(make_color_rgb(50, 45, 37));
            draw_roundrect(
                layout.content_left,
                item_top,
                layout.content_right,
                item_bottom,
                false
            );

            if (definition.world_sprite != -1)
            {
                var icon_scale = min(
                    28 / max(1, sprite_get_width(definition.world_sprite)),
                    28 / max(1, sprite_get_height(definition.world_sprite))
                );
                draw_sprite_ext(
                    definition.world_sprite,
                    0,
                    layout.content_left + 25,
                    (item_top + item_bottom) * 0.5,
                    icon_scale,
                    icon_scale,
                    0,
                    c_white,
                    amount > 0 ? 1 : 0.38
                );
            }
            else if (resource_id == ResourceId.TIMBER_PLANK)
            {
                draw_set_color(amount > 0
                    ? make_color_rgb(196, 143, 76)
                    : make_color_rgb(92, 76, 58));
                draw_rectangle(
                    layout.content_left + 11,
                    item_top + 13,
                    layout.content_left + 38,
                    item_top + 18,
                    false
                );
                draw_rectangle(
                    layout.content_left + 14,
                    item_top + 21,
                    layout.content_left + 41,
                    item_top + 26,
                    false
                );
            }

            draw_set_color(amount > 0
                ? make_color_rgb(238, 225, 195)
                : make_color_rgb(132, 125, 109));
            draw_text(layout.content_left + 52, item_top + 9, definition.name);

            var item_note = "Stored material";
            if (resource_id == ResourceId.FIELDSTONE)
            {
                item_note = "Gathered by hand or crushed from Fieldrocks";
            }
            else if (resource_id == ResourceId.TIMBER_LOG)
            {
                item_note = "Delivered downed trees";
            }
            else if (resource_id == ResourceId.SMALL_LUMBER)
            {
                item_note = "Recovered from delivered stumps";
            }
            else if (resource_id == ResourceId.TIMBER_PLANK)
            {
                item_note = "Finished craft retrieved from the chest";
            }

            draw_set_color(amount > 0
                ? make_color_rgb(178, 166, 139)
                : make_color_rgb(105, 99, 87));
            draw_text(layout.content_left + 52, item_top + 27, item_note);

            draw_set_halign(fa_right);
            draw_set_valign(fa_middle);
            draw_set_color(amount > 0
                ? make_color_rgb(255, 220, 92)
                : make_color_rgb(132, 125, 109));
            var row_capacity = inventory_get_resource_capacity(
                shown_inventory,
                resource_id
            );
            var amount_text = "x " + string(amount);
            if (row_capacity >= 0)
                amount_text += " / " + string(row_capacity);
            draw_text(
                layout.content_right - 14,
                (item_top + item_bottom) * 0.5,
                amount_text
            );
            draw_set_halign(fa_left);
            draw_set_valign(fa_top);
        }

        if (storage_total <= 0)
        {
            draw_set_halign(fa_right);
            draw_set_valign(fa_bottom);
            draw_set_color(make_color_rgb(178, 166, 139));
            draw_text(layout.content_right, layout.content_bottom, "No supplies stored here yet.");
        }
    }
}

draw_set_halign(fa_center);
draw_set_valign(fa_bottom);
draw_set_color(make_color_rgb(232, 209, 158));
draw_text(
    layout.gui_w * 0.5,
    panel_bottom - 8,
    "Click a category or use Left/Right    I, Tab, or Escape to close"
);

draw_set_alpha(1);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(c_white);
draw_set_font(-1);
