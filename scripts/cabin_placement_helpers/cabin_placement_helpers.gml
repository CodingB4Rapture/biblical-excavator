/// Cabin placement is the bridge between Quest 1 and the future crafting
/// system. It places a saved construction site, not a finished cabin.

function cabin_point_is_clear_of_object(_x, _y, _object, _distance)
{
    for (var i = 0; i < instance_number(_object); i++)
    {
        var blocker = instance_find(_object, i);

        if (instance_exists(blocker)
        && point_distance(_x, _y, blocker.x, blocker.y) < _distance)
        {
            return false;
        }
    }

    return true;
}

function cabin_placement_is_valid(_x, _y, _ignore_existing_site = false)
{
    var half_size = 32;

    if (_x - half_size < 0
    || _y - half_size < 0
    || _x + half_size > room_width
    || _y + half_size > room_height)
    {
        return false;
    }

    if (!cabin_point_is_clear_of_object(_x, _y, obj_player, 52)) return false;
    if (!cabin_point_is_clear_of_object(_x, _y, obj_skidsteer, 64)) return false;
    if (!cabin_point_is_clear_of_object(_x, _y, obj_farmer, 56)) return false;
    if (!cabin_point_is_clear_of_object(_x, _y, obj_farmers_wife, 56)) return false;
    if (!cabin_point_is_clear_of_object(_x, _y, obj_fieldrock, 48)) return false;
    if (!cabin_point_is_clear_of_object(_x, _y, obj_log, 52)) return false;
    if (!cabin_point_is_clear_of_object(_x, _y, obj_pond, 96)) return false;
    if (!_ignore_existing_site
    && !cabin_point_is_clear_of_object(_x, _y, obj_cabin_site, 72)) return false;

    var home_dropoff = instance_find(obj_homebase_dropoff, 0);

    if (instance_exists(home_dropoff)
    && point_distance(_x, _y, home_dropoff.x, home_dropoff.y)
        < home_dropoff.dropoff_radius + half_size)
    {
        return false;
    }

    return true;
}

function cabin_restore_site()
{
    var game_state = game_state_ensure();

    if (!game_state.cabin_site_placed
    || game_state.cabin_site_room != room_get_name(room)
    || instance_exists(obj_cabin_site))
    {
        return noone;
    }

    return instance_create_depth(
        game_state.cabin_site_x,
        game_state.cabin_site_y,
        0,
        obj_cabin_site
    );
}

function cabin_get_exit_position()
{
    var game_state = game_state_ensure();

    return {
        x: clamp(game_state.cabin_site_x, 8, room_width - 8),
        y: clamp(game_state.cabin_site_y + 50, 8, room_height - 8)
    };
}

function cabin_place_actor_at_exit(_actor)
{
    if (!instance_exists(_actor))
    {
        return false;
    }

    var exit_position = cabin_get_exit_position();
    _actor.x = exit_position.x;
    _actor.y = exit_position.y;
    return true;
}

function cabin_place_site(_x, _y, _relocating = false)
{
    var game_state = game_state_ensure();
    var can_relocate = _relocating
        && game_state.cabin_site_placed
        && game_state.homestead_stage == HomesteadStage.FIRST_REST_REQUIRED;

    if (!game_state.cabin_placement_unlocked
    || (game_state.cabin_site_placed && !can_relocate)
    || !cabin_placement_is_valid(_x, _y, can_relocate))
    {
        return false;
    }

    if (can_relocate)
    {
        with (obj_cabin_site) instance_destroy();
    }

    game_state.cabin_site_placed = true;
    game_state.cabin_site_room = room_get_name(room);
    game_state.cabin_site_x = _x;
    game_state.cabin_site_y = _y;
    game_state.homestead_stage = HomesteadStage.FIRST_REST_REQUIRED;
    instance_create_depth(_x, _y, 0, obj_cabin_site);
    notification_show_hint(
        can_relocate
            ? "Cabin site moved. Rest there when you are ready for morning."
            : "Cabin site placed. Rest there to begin the first homestead morning.",
        game_get_speed(gamespeed_fps) * 6,
        true
    );
    save_write();
    return true;
}

function cabin_begin_placement(_allow_relocate = false)
{
    var game_state = game_state_ensure();
    var can_relocate = _allow_relocate
        && game_state.cabin_site_placed
        && game_state.homestead_stage == HomesteadStage.FIRST_REST_REQUIRED;

    if (!game_state.cabin_placement_unlocked)
    {
        notification_show_hint("Complete A Firm Foundation to unlock a cabin site.", game_get_speed(gamespeed_fps) * 3, false);
        return false;
    }

    if (game_state.cabin_site_placed && !can_relocate)
    {
        notification_show_hint("Your cabin site is already established.", game_get_speed(gamespeed_fps) * 3, false);
        return false;
    }

    if (!instance_exists(obj_cabin_placement_controller))
    {
        var placement = instance_create_depth(0, 0, -800, obj_cabin_placement_controller);
        placement.placement_relocating = can_relocate;
        notification_show_hint(
            can_relocate
                ? "Move around, then left-click a clear 64 x 64 area to move the cabin site."
                : "Move around, then left-click a clear 64 x 64 area for the cabin site.",
            game_get_speed(gamespeed_fps) * 6,
            false
        );
    }

    return true;
}

function cabin_unlock_placement()
{
    var game_state = game_state_ensure();
    game_state.cabin_placement_unlocked = true;
    save_write();
    notification_show_hint(
        "Cabin site unlocked. Walk to the spot you want, then press B to place it.",
        game_get_speed(gamespeed_fps) * 6,
        false
    );
}
