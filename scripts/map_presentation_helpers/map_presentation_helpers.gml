/// Runtime-only map camera lifecycle and Draw GUI presentation.

function map_menu_configure(_menu)
{
    _menu.map_camera_restore_pending = false;
    if (instance_number(obj_map_menu) > 1)
    {
        with (_menu) instance_destroy();
        return false;
    }

    _menu.map_room_name = room_get_name(room);
    _menu.map_world_width = room_width;
    _menu.map_world_height = room_height;
    _menu.map_camera = view_camera[0];

    if (_menu.map_camera != -1)
    {
        _menu.saved_camera_x = camera_get_view_x(_menu.map_camera);
        _menu.saved_camera_y = camera_get_view_y(_menu.map_camera);
        _menu.saved_camera_width =
            camera_get_view_width(_menu.map_camera);
        _menu.saved_camera_height =
            camera_get_view_height(_menu.map_camera);
        _menu.map_camera_restore_pending = true;

        camera_set_view_size(
            _menu.map_camera,
            _menu.map_world_width,
            _menu.map_world_height
        );
        camera_set_view_pos(_menu.map_camera, 0, 0);
    }

    gameplay_set_paused(true);
    return true;
}

function map_menu_restore_camera(_menu)
{
    if (!_menu.map_camera_restore_pending) return false;

    if (_menu.map_camera != -1)
    {
        camera_set_view_size(
            _menu.map_camera,
            _menu.saved_camera_width,
            _menu.saved_camera_height
        );
        camera_set_view_pos(
            _menu.map_camera,
            _menu.saved_camera_x,
            _menu.saved_camera_y
        );
    }

    _menu.map_camera_restore_pending = false;
    return true;
}

function map_draw_area_label(_area, _layout)
{
    draw_set_font(-1);
    var text_width = string_width(_area.name);
    var half_width = text_width * 0.5 + 7;
    var label_x = clamp(
        _area.x,
        _layout.map_left + half_width + 4,
        _layout.map_right - half_width - 4
    );
    var label_y = clamp(
        _area.y,
        _layout.map_top + 18,
        _layout.map_bottom - 18
    );
    var panel_left = label_x - half_width;
    var panel_top = label_y - 9;
    var panel_right = label_x + half_width;
    var panel_bottom = label_y + 9;

    draw_set_alpha(_area.current ? 0.92 : 0.72);
    draw_set_color(_area.current
        ? make_color_rgb(116, 79, 31)
        : make_color_rgb(31, 29, 24));
    draw_roundrect(
        panel_left,
        panel_top,
        panel_right,
        panel_bottom,
        false
    );

    draw_set_alpha(1);
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_set_color(_area.current
        ? make_color_rgb(255, 220, 92)
        : make_color_rgb(238, 225, 195));
    draw_text(label_x, label_y, _area.name);
}

function map_draw_actor_marker(_marker)
{
    if (!_marker.valid) return;

    draw_set_alpha(0.82);
    draw_set_color(c_black);
    draw_circle(_marker.x, _marker.y, 8, false);
    draw_set_alpha(1);
    draw_set_color(make_color_rgb(255, 220, 92));
    draw_circle(_marker.x, _marker.y, 5, false);
    draw_set_color(make_color_rgb(45, 38, 28));
    draw_circle(_marker.x, _marker.y, 2, false);

    draw_set_font(-1);
    draw_set_halign(fa_center);
    draw_set_valign(fa_top);
    draw_set_color(c_black);
    draw_text(_marker.x + 1, _marker.y + 10, _marker.label);
    draw_set_color(make_color_rgb(255, 238, 196));
    draw_text(_marker.x, _marker.y + 9, _marker.label);
}

function map_menu_draw(_menu)
{
    var gui_w = display_get_gui_width();
    var gui_h = display_get_gui_height();
    var layout = map_get_layout(
        gui_w,
        gui_h,
        _menu.map_world_width,
        _menu.map_world_height
    );

    // Cover ordinary HUD Draw GUI output, then redraw only the live world.
    draw_set_alpha(1);
    draw_set_color(make_color_rgb(15, 14, 12));
    draw_rectangle(0, 0, gui_w, gui_h, false);

    if (surface_exists(application_surface))
    {
        draw_surface_stretched(
            application_surface,
            layout.map_left,
            layout.map_top,
            layout.map_width,
            layout.map_height
        );
    }
    else
    {
        draw_set_color(make_color_rgb(48, 55, 38));
        draw_rectangle(
            layout.map_left,
            layout.map_top,
            layout.map_right,
            layout.map_bottom,
            false
        );
    }

    draw_set_alpha(0.12);
    draw_set_color(c_black);
    draw_rectangle(
        layout.map_left,
        layout.map_top,
        layout.map_right,
        layout.map_bottom,
        false
    );

    draw_set_alpha(1);
    draw_set_color(make_color_rgb(70, 50, 27));
    draw_rectangle(
        layout.map_left - 4,
        layout.map_top - 4,
        layout.map_right + 4,
        layout.map_bottom + 4,
        true
    );
    draw_set_color(make_color_rgb(213, 164, 67));
    draw_rectangle(
        layout.map_left - 2,
        layout.map_top - 2,
        layout.map_right + 2,
        layout.map_bottom + 2,
        true
    );

    var model = map_get_read_model(layout, _menu.map_room_name);
    for (var area_index = 0;
        area_index < array_length(model.areas);
        area_index++)
    {
        map_draw_area_label(model.areas[area_index], layout);
    }

    map_draw_actor_marker(model.marker);

    var title = "AREA MAP";
    draw_set_font(-1);
    var title_width = string_width(title) + 30;
    var title_x = (layout.map_left + layout.map_right) * 0.5;
    draw_set_alpha(0.88);
    draw_set_color(make_color_rgb(31, 28, 23));
    draw_roundrect(
        title_x - title_width * 0.5,
        layout.map_top + 8,
        title_x + title_width * 0.5,
        layout.map_top + 32,
        false
    );
    draw_set_alpha(1);
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_set_color(make_color_rgb(255, 220, 92));
    draw_text(title_x, layout.map_top + 20, title);

    var footer = "M or Escape to close    Q Quest    I Inventory";
    var footer_width = string_width(footer) + 24;
    var footer_x = (layout.map_left + layout.map_right) * 0.5;
    draw_set_alpha(0.84);
    draw_set_color(make_color_rgb(31, 28, 23));
    draw_roundrect(
        footer_x - footer_width * 0.5,
        layout.map_bottom - 30,
        footer_x + footer_width * 0.5,
        layout.map_bottom - 8,
        false
    );
    draw_set_alpha(1);
    draw_set_color(make_color_rgb(238, 225, 195));
    draw_text(footer_x, layout.map_bottom - 19, footer);

    draw_set_alpha(1);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    draw_set_color(c_white);
    draw_set_font(-1);
    return true;
}
