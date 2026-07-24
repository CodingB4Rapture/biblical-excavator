/// obj_finished_crafts_menu - Draw GUI Event

draw_set_font(-1);

var layout = finished_crafts_menu_get_layout();
var game_state = game_state_ensure();
var resource_id = finished_crafts_menu_get_selected_resource();
var panel_color = make_color_rgb(39, 30, 23);
var panel_edge = make_color_rgb(79, 50, 25);
var panel_gold = make_color_rgb(224, 169, 73);
var text_color = make_color_rgb(247, 229, 198);
var muted_color = make_color_rgb(191, 171, 139);
var selected_color = make_color_rgb(255, 220, 92);

draw_set_alpha(0.74);
draw_set_color(make_color_rgb(14, 11, 9));
draw_rectangle(0, 0, layout.gui_w, layout.gui_h, false);

draw_set_alpha(0.98);
draw_set_color(panel_edge);
draw_roundrect(
    layout.panel_left,
    layout.panel_top,
    layout.panel_right,
    layout.panel_bottom,
    false
);
draw_set_color(panel_gold);
draw_roundrect(
    layout.panel_left + 2,
    layout.panel_top + 2,
    layout.panel_right - 2,
    layout.panel_bottom - 2,
    true
);
draw_set_color(panel_color);
draw_roundrect(
    layout.panel_left + 6,
    layout.panel_top + 6,
    layout.panel_right - 6,
    layout.panel_bottom - 6,
    false
);

draw_set_alpha(1);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(make_color_rgb(255, 216, 112));
draw_text(
    layout.panel_left + 18,
    layout.panel_top + 15,
    "FINISHED CRAFTS"
);
draw_set_color(muted_color);
draw_text(
    layout.panel_left + 18,
    layout.panel_top + 36,
    "Completed materials ready for use."
);

var row_height = 54;
for (var row = 0; row < array_length(finished_craft_rows); row++)
{
    var row_resource_id = finished_craft_rows[row];
    var row_top = layout.content_top + row * row_height;
    var row_bottom = row_top + row_height - 6;
    var row_amount = inventory_get_amount(
        game_state.finished_crafts_inventory,
        row_resource_id
    );

    draw_set_color(row == selected_row
        ? make_color_rgb(68, 53, 37)
        : make_color_rgb(49, 42, 34));
    draw_roundrect(
        layout.list_left,
        row_top,
        layout.list_right,
        row_bottom,
        false
    );

    if (row == selected_row)
    {
        draw_set_color(selected_color);
        draw_triangle(
            layout.list_left + 10,
            row_top + 18,
            layout.list_left + 10,
            row_top + 32,
            layout.list_left + 17,
            row_top + 25,
            false
        );
    }

    draw_set_color(row_amount > 0 ? text_color : muted_color);
    draw_text(
        layout.list_left + 26,
        row_top + 8,
        resource_get_name(row_resource_id)
    );
    draw_set_color(muted_color);
    draw_text(
        layout.list_left + 26,
        row_top + 28,
        "Available"
    );
    draw_set_halign(fa_right);
    draw_set_color(row_amount > 0 ? selected_color : muted_color);
    draw_text(
        layout.list_right - 12,
        row_top + 18,
        "x " + string(row_amount)
    );
    draw_set_halign(fa_left);
}

draw_set_color(make_color_rgb(49, 42, 34));
draw_roundrect(
    layout.preview_left,
    layout.content_top,
    layout.preview_right,
    layout.content_bottom,
    false
);

if (resource_id >= 0)
{
    var definition = resource_get_definition(resource_id);
    var preview_center_x = (
        layout.preview_left + layout.preview_right
    ) * 0.5;
    var preview_center_y = layout.content_top + 78;

    if (definition.world_sprite != -1)
    {
        var preview_scale = min(
            80 / max(1, sprite_get_width(definition.world_sprite)),
            80 / max(1, sprite_get_height(definition.world_sprite))
        );
        draw_sprite_ext(
            definition.world_sprite,
            0,
            preview_center_x,
            preview_center_y,
            preview_scale,
            preview_scale,
            0,
            c_white,
            1
        );
    }
    else
    {
        // Temporary readable plank icon; dedicated item art can replace this
        // through resource_get_definition without changing the menu.
        draw_set_color(make_color_rgb(103, 67, 35));
        draw_rectangle(
            preview_center_x - 47,
            preview_center_y - 24,
            preview_center_x + 43,
            preview_center_y - 9,
            false
        );
        draw_set_color(make_color_rgb(201, 146, 76));
        draw_rectangle(
            preview_center_x - 43,
            preview_center_y - 20,
            preview_center_x + 47,
            preview_center_y - 5,
            false
        );
        draw_set_color(make_color_rgb(111, 72, 38));
        draw_rectangle(
            preview_center_x - 45,
            preview_center_y + 3,
            preview_center_x + 45,
            preview_center_y + 18,
            false
        );
        draw_set_color(make_color_rgb(213, 158, 84));
        draw_rectangle(
            preview_center_x - 41,
            preview_center_y + 7,
            preview_center_x + 49,
            preview_center_y + 22,
            false
        );
    }

    var player_amount = inventory_get_amount(
        game_state.player_inventory,
        resource_id
    );
    var player_capacity = inventory_get_resource_capacity(
        game_state.player_inventory,
        resource_id
    );
    draw_set_halign(fa_center);
    draw_set_color(text_color);
    draw_text(
        preview_center_x,
        layout.content_top + 142,
        definition.name
    );
    draw_set_color(muted_color);
    draw_text(
        preview_center_x,
        layout.content_top + 166,
        "Backpack  " + string(player_amount)
            + " / " + string(player_capacity)
    );
    draw_set_halign(fa_left);
}

if (quantity_mode)
{
    var maximum = max(1, finished_crafts_menu_get_max_quantity());
    var track_left = layout.quantity_left + 30;
    var track_right = layout.quantity_right - 30;
    var track_y = layout.content_bottom - 28;
    var knob_ratio = maximum <= 1
        ? 0.5
        : (selected_quantity - 1) / (maximum - 1);
    var knob_x = lerp(track_left, track_right, knob_ratio);

    draw_set_color(make_color_rgb(60, 49, 37));
    draw_roundrect(
        layout.list_left,
        layout.content_bottom - 96,
        layout.list_right,
        layout.content_bottom,
        false
    );
    draw_set_halign(fa_center);
    draw_set_color(selected_color);
    draw_text(
        (layout.list_left + layout.list_right) * 0.5,
        layout.content_bottom - 84,
        "TAKE " + string(selected_quantity)
    );

    draw_set_color(muted_color);
    draw_line(track_left, track_y, track_right, track_y);
    draw_triangle(
        layout.quantity_left,
        track_y,
        layout.quantity_left + 10,
        track_y - 7,
        layout.quantity_left + 10,
        track_y + 7,
        false
    );
    draw_triangle(
        layout.quantity_right,
        track_y,
        layout.quantity_right - 10,
        track_y - 7,
        layout.quantity_right - 10,
        track_y + 7,
        false
    );
    draw_set_color(selected_color);
    draw_circle(knob_x, track_y, 7, false);
    draw_set_halign(fa_left);
}

draw_set_halign(fa_center);
draw_set_valign(fa_bottom);
draw_set_color(action_message == ""
    ? muted_color
    : make_color_rgb(151, 194, 126));
draw_text(
    layout.gui_w * 0.5,
    layout.panel_bottom - 34,
    action_message
);
draw_set_color(muted_color);
draw_text(
    layout.gui_w * 0.5,
    layout.panel_bottom - 12,
    quantity_mode
        ? "Left/Right choose amount    E/Space take    Escape back"
        : "Up/Down select    E/Space choose    Escape close"
);

draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_alpha(1);
draw_set_color(c_white);
