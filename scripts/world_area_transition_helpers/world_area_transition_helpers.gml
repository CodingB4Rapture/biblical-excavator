/// Ephemeral world-area state and the explicit area-entry event.
/// Area identity derives from position and intentionally does not enter saves.

function world_area_controller_configure(_controller)
{
    _controller.current_area_id = WORLD_AREA_NONE;
    _controller.current_area_name = "";
    _controller.current_music_key = "";
    _controller.previous_area_id = WORLD_AREA_NONE;
    _controller.banner_area_name = "";
    _controller.banner_duration = 220;
    _controller.banner_timer = 0;

    global.current_world_area_id = WORLD_AREA_NONE;
    global.current_world_area_name = "";
    global.current_world_music_key = "";
}

function world_area_enter(_controller, _area_id)
{
    var definition = world_area_definition(_area_id);
    if (is_undefined(definition)) return false;

    _controller.previous_area_id = _controller.current_area_id;
    _controller.current_area_id = definition.id;
    _controller.current_area_name = definition.name;
    _controller.current_music_key = definition.music_key;
    _controller.banner_area_name = definition.name;
    _controller.banner_timer = _controller.banner_duration;

    global.current_world_area_id = definition.id;
    global.current_world_area_name = definition.name;
    global.current_world_music_key = definition.music_key;
    return true;
}

function world_area_controller_step(_controller)
{
    if (gameplay_is_paused()) return;

    var actor = world_area_tracking_actor();
    if (instance_exists(actor))
    {
        var detected_area_id = world_area_id_at_position(
            room_get_name(room),
            actor.x,
            actor.y
        );

        if (detected_area_id != WORLD_AREA_NONE
        && detected_area_id != _controller.current_area_id)
        {
            world_area_enter(_controller, detected_area_id);
        }
    }

    if (_controller.banner_timer > 0)
        _controller.banner_timer -= 1;
}
