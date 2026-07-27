/// Stable Room1 area records and spatial resolution only.
/// The IDs are the seam future area-specific music should consume.

#macro WORLD_AREA_NONE ""
#macro WORLD_AREA_EIRENEIKOS "eireneikos_meadows"
#macro WORLD_AREA_POND_FOREST "pond_forest"
#macro WORLD_AREA_WORKFIELD "farmers_workfield"
#macro WORLD_AREA_FARMYARD "farmyard"
#macro WORLD_AREA_MINEFIELD "fieldrock_minefield"
#macro WORLD_AREA_HOMESTEAD "farmers_homestead"

function world_area_definition_records()
{
    return [
        {
            id: WORLD_AREA_FARMYARD,
            name: "Farmyard",
            room_name: "Room1",
            min_x: 320,
            min_y: 0,
            max_x: 832,
            max_y: 176,
            priority: 60,
            music_key: ""
        },
        {
            id: WORLD_AREA_HOMESTEAD,
            name: "Farmer's Homestead",
            room_name: "Room1",
            min_x: 1008,
            min_y: 96,
            max_x: 1280,
            max_y: 432,
            priority: 50,
            music_key: ""
        },
        {
            id: WORLD_AREA_POND_FOREST,
            name: "Pond Forest",
            room_name: "Room1",
            min_x: 0,
            min_y: 400,
            max_x: 304,
            max_y: 720,
            priority: 40,
            music_key: ""
        },
        {
            id: WORLD_AREA_MINEFIELD,
            name: "Fieldrock Minefield",
            room_name: "Room1",
            min_x: 880,
            min_y: 512,
            max_x: 1280,
            max_y: 720,
            priority: 30,
            music_key: ""
        },
        {
            id: WORLD_AREA_EIRENEIKOS,
            name: "Eireneikos Meadows",
            room_name: "Room1",
            min_x: 0,
            min_y: 0,
            max_x: 304,
            max_y: 400,
            priority: 20,
            music_key: ""
        },
        {
            id: WORLD_AREA_WORKFIELD,
            name: "Farmer's Workfield",
            room_name: "Room1",
            min_x: 0,
            min_y: 0,
            max_x: 1280,
            max_y: 720,
            priority: 0,
            music_key: ""
        }
    ];
}

function world_area_definition(_area_id)
{
    var definitions = world_area_definition_records();

    for (var i = 0; i < array_length(definitions); i++)
    {
        if (definitions[i].id == _area_id) return definitions[i];
    }

    return undefined;
}

function world_area_id_at_position(_room_name, _x, _y)
{
    var definitions = world_area_definition_records();
    var selected_id = WORLD_AREA_NONE;
    var selected_priority = -100000;

    for (var i = 0; i < array_length(definitions); i++)
    {
        var definition = definitions[i];
        if (definition.room_name == _room_name
        && definition.priority > selected_priority
        && point_in_rectangle(
            _x,
            _y,
            definition.min_x,
            definition.min_y,
            definition.max_x,
            definition.max_y
        ))
        {
            selected_id = definition.id;
            selected_priority = definition.priority;
        }
    }

    return selected_id;
}
