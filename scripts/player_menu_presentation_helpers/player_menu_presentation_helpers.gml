/// Derived state, input routing, and presentation for the persistent Q/I/S/M rail.

function player_menu_build_read_model(
    _quest_open,
    _inventory_open,
    _map_open,
    _build_open = false,
    _skills_open = false
)
{
    return {
        quest_open: _quest_open,
        inventory_open: _inventory_open,
        map_open: _map_open,
        build_open: _build_open,
        skills_open: _skills_open,
        quest_frame: _quest_open ? 1 : 0,
        inventory_frame: _inventory_open ? 1 : 0,
        map_frame: _map_open ? 1 : 0,
        build_frame: _build_open ? 1 : 0,
        skills_frame: _skills_open ? 1 : 0
    };
}

function player_menu_get_read_model()
{
    return player_menu_build_read_model(
        instance_exists(obj_quest_menu),
        instance_exists(obj_inventory_menu),
        instance_exists(obj_map_menu),
        instance_exists(obj_build_menu),
        instance_exists(obj_skills_menu)
    );
}

function player_menu_rail_is_visible()
{
    return player_menu_navigation_is_available();
}

function player_menu_skills_shortcut_from_state(
    _shift_down,
    _s_pressed
)
{
    return _shift_down && _s_pressed;
}

function player_menu_rail_ensure()
{
    if (room == rm_main_menu) return noone;

    var rail = instance_find(obj_player_menu_rail, 0);
    if (instance_exists(rail)) return rail;

    // Draw just above the full-screen menus so the sprite buttons stay usable.
    return instance_create_depth(0, 0, -5100, obj_player_menu_rail);
}

function player_menu_rail_configure(_rail)
{
    if (instance_number(obj_player_menu_rail) > 1)
    {
        with (_rail) instance_destroy();
        return false;
    }

    _rail.hovered_button = -1;
    return true;
}

function player_menu_rail_step(_rail)
{
    _rail.hovered_button = -1;
    if (!player_menu_rail_is_visible()) return false;

    var layout = player_menu_get_rail_layout();
    var gui_mouse_x = device_mouse_x_to_gui(0);
    var gui_mouse_y = device_mouse_y_to_gui(0);

    if (point_in_rectangle(
        gui_mouse_x,
        gui_mouse_y,
        layout.quest_left,
        layout.quest_top,
        layout.quest_right,
        layout.quest_bottom
    ))
    {
        _rail.hovered_button = 0;
    }
    else if (point_in_rectangle(
        gui_mouse_x,
        gui_mouse_y,
        layout.skills_left,
        layout.skills_top,
        layout.skills_right,
        layout.skills_bottom
    ))
    {
        _rail.hovered_button = 2;
    }
    else if (point_in_rectangle(
        gui_mouse_x,
        gui_mouse_y,
        layout.inventory_left,
        layout.inventory_top,
        layout.inventory_right,
        layout.inventory_bottom
    ))
    {
        _rail.hovered_button = 1;
    }
    else if (point_in_rectangle(
        gui_mouse_x,
        gui_mouse_y,
        layout.map_left,
        layout.map_top,
        layout.map_right,
        layout.map_bottom
    ))
    {
        _rail.hovered_button = 3;
    }
    else if (point_in_rectangle(
        gui_mouse_x,
        gui_mouse_y,
        layout.build_left,
        layout.build_top,
        layout.build_right,
        layout.build_bottom
    ))
    {
        _rail.hovered_button = 4;
    }

    if (keyboard_check_pressed(ord("Q")))
    {
        return player_menu_toggle_quest();
    }

    if (keyboard_check_pressed(ord("I"))
    || keyboard_check_pressed(vk_tab))
    {
        return player_menu_toggle_inventory();
    }

    if (keyboard_check_pressed(ord("M")))
    {
        return player_menu_toggle_map();
    }

    if (player_menu_skills_shortcut_from_state(
        keyboard_check(vk_shift),
        keyboard_check_pressed(ord("S"))
    ))
    {
        return player_menu_toggle_skills();
    }

    if (keyboard_check_pressed(ord("B")))
    {
        return player_menu_toggle_build();
    }

    if (keyboard_check_pressed(vk_escape) && player_menu_is_open())
    {
        return player_menu_close();
    }

    if (!mouse_check_button_pressed(mb_left)) return false;
    if (_rail.hovered_button == 0) return player_menu_toggle_quest();
    if (_rail.hovered_button == 1) return player_menu_toggle_inventory();
    if (_rail.hovered_button == 2) return player_menu_toggle_skills();
    if (_rail.hovered_button == 3) return player_menu_toggle_map();
    if (_rail.hovered_button == 4) return player_menu_toggle_build();
    return false;
}

function player_menu_rail_draw(_rail)
{
    if (cutscene_is_active()) return false;

    // The calendar belongs above both gameplay and full-screen player menus.
    // Draw it from this topmost persistent UI layer, not the covered HUD.
    calendar_draw_status();

    if (!player_menu_rail_is_visible()) return false;

    var layout = player_menu_get_rail_layout();
    var model = player_menu_get_read_model();

    draw_set_alpha(_rail.hovered_button == 0 ? 1 : 0.92);
    draw_sprite(
        spr_quest_button,
        model.quest_frame,
        layout.quest_center_x,
        layout.quest_center_y
    );

    draw_set_alpha(_rail.hovered_button == 1 ? 1 : 0.92);
    draw_sprite(
        spr_inventory_button,
        model.inventory_frame,
        layout.inventory_center_x,
        layout.inventory_center_y
    );

    draw_set_alpha(_rail.hovered_button == 2 ? 1 : 0.92);
    draw_sprite(
        spr_skills_button,
        model.skills_frame,
        layout.skills_center_x,
        layout.skills_center_y
    );

    draw_set_alpha(_rail.hovered_button == 3 ? 1 : 0.92);
    draw_sprite(
        spr_map_button,
        model.map_frame,
        layout.map_center_x,
        layout.map_center_y
    );

    draw_set_alpha(_rail.hovered_button == 4 ? 1 : 0.92);
    draw_sprite(
        spr_build_button,
        model.build_frame,
        layout.build_center_x,
        layout.build_center_y
    );

    draw_set_alpha(1);
    draw_set_color(c_white);
    return true;
}
