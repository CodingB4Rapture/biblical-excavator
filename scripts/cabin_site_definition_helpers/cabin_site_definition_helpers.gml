/// Authored cabin-site definitions and read models.
/// Flags are presentation for these records; they never define the footprint.

#macro CABIN_SITE_NONE ""
#macro CABIN_SITE_EIRENEIKOS "cabin_site_eireneikos"
#macro CABIN_SITE_WORKFIELD "cabin_site_workfield"
#macro CABIN_SITE_LEGACY "cabin_site_legacy"

function cabin_site_definitions()
{
    return [
        {
            id: CABIN_SITE_EIRENEIKOS,
            number: 1,
            symbol: "I",
            name: "Eireneikos Meadows Site",
            area_name: "Eireneikos Meadows",
            room_name: "Room1",
            x: 112,
            y: 144,
            colour: make_color_rgb(238, 188, 67)
        },
        {
            id: CABIN_SITE_WORKFIELD,
            number: 2,
            symbol: "II",
            name: "Farmer's Workfield Site",
            area_name: "Farmer's Workfield",
            room_name: "Room1",
            x: 720,
            y: 592,
            colour: make_color_rgb(91, 181, 207)
        }
    ];
}

function cabin_site_definition(_site_id)
{
    var definitions = cabin_site_definitions();

    for (var i = 0; i < array_length(definitions); i++)
    {
        if (definitions[i].id == _site_id)
        {
            return definitions[i];
        }
    }

    return undefined;
}

function cabin_site_id_at_position(_room_name, _x, _y)
{
    var definitions = cabin_site_definitions();

    for (var i = 0; i < array_length(definitions); i++)
    {
        var definition = definitions[i];
        if (definition.room_name == _room_name
        && definition.x == _x
        && definition.y == _y)
        {
            return definition.id;
        }
    }

    return CABIN_SITE_LEGACY;
}

function cabin_site_corner_positions(_definition)
{
    var bounds = cabin_fence_plot_bounds_at(
        _definition.x,
        _definition.y
    );

    return [
        { x: bounds.min_x, y: bounds.min_y },
        { x: bounds.max_x, y: bounds.min_y },
        { x: bounds.max_x, y: bounds.max_y },
        { x: bounds.min_x, y: bounds.max_y }
    ];
}

function cabin_site_flag_bit(_corner_index)
{
    return 1 << clamp(round(_corner_index), 0, 3);
}

function cabin_site_flag_is_taken(
    _site_id,
    _corner_index,
    _game_state = undefined
)
{
    var game_state = is_undefined(_game_state)
        ? game_state_read()
        : _game_state;

    return game_state.cabin_selected_site_id == _site_id
        && (game_state.cabin_site_flags_taken
            & cabin_site_flag_bit(_corner_index)) != 0;
}

function cabin_site_flag_count_taken(_game_state = undefined)
{
    var game_state = is_undefined(_game_state)
        ? game_state_read()
        : _game_state;
    var count = 0;

    for (var corner_index = 0; corner_index < 4; corner_index++)
    {
        if ((game_state.cabin_site_flags_taken
            & cabin_site_flag_bit(corner_index)) != 0)
        {
            count += 1;
        }
    }

    return count;
}
