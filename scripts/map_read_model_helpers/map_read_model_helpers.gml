/// Pure map geometry plus read-only area and controlled-actor descriptors.

function map_get_layout(
    _gui_w = -1,
    _gui_h = -1,
    _world_w = -1,
    _world_h = -1
)
{
    if (_gui_w < 0) _gui_w = display_get_gui_width();
    if (_gui_h < 0) _gui_h = display_get_gui_height();
    if (_world_w < 0) _world_w = room_width;
    if (_world_h < 0) _world_h = room_height;

    var panel = player_menu_get_panel_bounds(_gui_w, _gui_h);
    var padding = 6;
    var available_left = panel.panel_left + padding;
    var available_top = panel.panel_top + padding;
    var available_right = panel.panel_right - padding;
    var available_bottom = panel.panel_bottom - padding;
    var available_width = max(1, available_right - available_left);
    var available_height = max(1, available_bottom - available_top);
    var map_scale = min(
        available_width / max(1, _world_w),
        available_height / max(1, _world_h)
    );
    var map_width = _world_w * map_scale;
    var map_height = _world_h * map_scale;
    var map_left = available_left
        + (available_width - map_width) * 0.5;
    var map_top = available_top
        + (available_height - map_height) * 0.5;

    return {
        gui_w: _gui_w,
        gui_h: _gui_h,
        panel_left: panel.panel_left,
        panel_top: panel.panel_top,
        panel_right: panel.panel_right,
        panel_bottom: panel.panel_bottom,
        map_left: map_left,
        map_top: map_top,
        map_right: map_left + map_width,
        map_bottom: map_top + map_height,
        map_width: map_width,
        map_height: map_height,
        world_width: _world_w,
        world_height: _world_h
    };
}

function map_world_to_gui(_world_x, _world_y, _layout)
{
    return {
        x: _layout.map_left
            + (_world_x / max(1, _layout.world_width))
            * _layout.map_width,
        y: _layout.map_top
            + (_world_y / max(1, _layout.world_height))
            * _layout.map_height
    };
}

function map_get_read_model(_layout, _room_name)
{
    var definitions = world_area_definition_records();
    var areas = [];
    var current_area_id = world_area_current_id();

    for (var i = 0; i < array_length(definitions); i++)
    {
        var definition = definitions[i];
        if (definition.room_name != _room_name) continue;

        var position = map_world_to_gui(
            (definition.min_x + definition.max_x) * 0.5,
            (definition.min_y + definition.max_y) * 0.5,
            _layout
        );
        array_push(areas, {
            id: definition.id,
            name: definition.name,
            x: position.x,
            y: position.y,
            current: definition.id == current_area_id
        });
    }

    var actor = world_area_tracking_actor();
    var marker = {
        valid: false,
        x: 0,
        y: 0,
        label: ""
    };

    if (instance_exists(actor))
    {
        var marker_position = map_world_to_gui(actor.x, actor.y, _layout);
        marker.valid = true;
        marker.x = marker_position.x;
        marker.y = marker_position.y;
        marker.label = actor.object_index == obj_skidsteer
            ? "SKIDSTEER"
            : "YOU";
    }

    return {
        room_name: _room_name,
        areas: areas,
        marker: marker
    };
}
