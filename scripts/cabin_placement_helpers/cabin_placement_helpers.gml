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

function cabin_plot_is_clear_of_object(
    _bounds,
    _object,
    _margin = 16
)
{
    for (var i = 0; i < instance_number(_object); i++)
    {
        var blocker = instance_find(_object, i);

        if (instance_exists(blocker)
        && point_in_rectangle(
            blocker.x,
            blocker.y,
            _bounds.min_x - _margin,
            _bounds.min_y - _margin,
            _bounds.max_x + _margin,
            _bounds.max_y + _margin
        ))
        {
            return false;
        }
    }

    return true;
}

function cabin_placement_is_valid(_x, _y, _ignore_existing_site = false)
{
    var half_size = 32;
    var fence_bounds = cabin_fence_plot_bounds_at(_x, _y);

    if (fence_bounds.min_x - fence_grid_size() * 0.5 < 0
    || fence_bounds.min_y - fence_grid_size() * 0.5 < 0
    || fence_bounds.max_x + fence_grid_size() * 0.5 > room_width
    || fence_bounds.max_y + fence_grid_size() * 0.5 > room_height)
    {
        return false;
    }

    if (!cabin_plot_is_clear_of_object(fence_bounds, obj_player)) return false;
    if (!cabin_plot_is_clear_of_object(fence_bounds, obj_skidsteer)) return false;
    if (!cabin_plot_is_clear_of_object(fence_bounds, obj_farmer)) return false;
    if (!cabin_plot_is_clear_of_object(fence_bounds, obj_farmers_wife)) return false;
    if (!cabin_plot_is_clear_of_object(fence_bounds, obj_tree, 24)) return false;
    if (!cabin_plot_is_clear_of_object(fence_bounds, obj_stump, 24)) return false;
    if (!cabin_plot_is_clear_of_object(fence_bounds, obj_fieldrock)) return false;
    if (!cabin_plot_is_clear_of_object(fence_bounds, obj_fieldstone)) return false;
    if (!cabin_plot_is_clear_of_object(fence_bounds, obj_small_fieldstone)) return false;
    if (!cabin_plot_is_clear_of_object(fence_bounds, obj_log)) return false;
    if (!cabin_plot_is_clear_of_object(fence_bounds, obj_pond, 64)) return false;
    if (!cabin_plot_is_clear_of_object(
        fence_bounds,
        obj_skidsteer_parking_pad,
        48
    )) return false;
    if (!_ignore_existing_site
    && !cabin_plot_is_clear_of_object(
        fence_bounds,
        obj_cabin_site,
        32
    )) return false;

    if (!cabin_point_is_clear_of_object(_x, _y, obj_player, 52)) return false;
    if (!cabin_point_is_clear_of_object(_x, _y, obj_skidsteer, 64)) return false;
    if (!cabin_point_is_clear_of_object(_x, _y, obj_farmer, 56)) return false;
    if (!cabin_point_is_clear_of_object(_x, _y, obj_farmers_wife, 56)) return false;
    if (!cabin_point_is_clear_of_object(_x, _y, obj_fieldrock, 48)) return false;
    if (!cabin_point_is_clear_of_object(_x, _y, obj_log, 52)) return false;
    if (!cabin_point_is_clear_of_object(_x, _y, obj_pond, 96)) return false;
    if (!cabin_point_is_clear_of_object(
        _x,
        _y,
        obj_skidsteer_parking_pad,
        112
    )) return false;
    if (!_ignore_existing_site
    && !cabin_point_is_clear_of_object(_x, _y, obj_cabin_site, 72)) return false;

    var home_dropoff = instance_find(obj_homebase_dropoff, 0);

    if (instance_exists(home_dropoff)
    && point_in_rectangle(
        home_dropoff.x,
        home_dropoff.y,
        fence_bounds.min_x - home_dropoff.dropoff_radius,
        fence_bounds.min_y - home_dropoff.dropoff_radius,
        fence_bounds.max_x + home_dropoff.dropoff_radius,
        fence_bounds.max_y + home_dropoff.dropoff_radius
    ))
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
        && task_is_active(TaskId.MARK_CABIN_SITE, game_state)
        && !game_state.cabin_fence_marked;

    if (!game_state.cabin_placement_unlocked
    || (!can_relocate
        && !task_is_active(TaskId.MARK_CABIN_SITE, game_state))
    || (game_state.cabin_site_placed && !can_relocate)
    || !cabin_placement_is_valid(_x, _y, can_relocate))
    {
        return false;
    }

    if (can_relocate)
    {
        with (obj_cabin_site) instance_destroy();
        game_state.fence_records = fence_records_without_purpose(
            game_state.fence_records,
            FENCE_PURPOSE_CABIN_SITE
        );
        fence_restore_room();
    }

    if (!progression_record_cabin_site_state(
        game_state,
        room_get_name(room),
        _x,
        _y,
        can_relocate
    ))
    {
        return false;
    }

    instance_create_depth(_x, _y, 0, obj_cabin_site);
    notification_show_hint(
        can_relocate
            ? "Cabin site moved. Go to the stakes and press E to mark its boundary."
            : "Site chosen. Go to the stakes and press E to mark its boundary.",
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
        && task_is_active(TaskId.MARK_CABIN_SITE, game_state)
        && !game_state.cabin_fence_marked;

    if (!game_state.cabin_placement_unlocked)
    {
        notification_show_hint("Complete A Firm Foundation to unlock a cabin site.", game_get_speed(gamespeed_fps) * 3, false);
        return false;
    }

    if (!can_relocate
    && !task_is_active(TaskId.MARK_CABIN_SITE, game_state))
    {
        notification_show_hint(
            "Accept Mark the Cabin Site at the Task Board first.",
            game_get_speed(gamespeed_fps) * 4,
            false
        );
        return false;
    }

    if (game_state.cabin_site_placed && !can_relocate)
    {
        notification_show_hint("Your cabin site is already marked.", game_get_speed(gamespeed_fps) * 3, false);
        return false;
    }

    if (!instance_exists(obj_cabin_placement_controller))
    {
        var placement = instance_create_depth(0, 0, -800, obj_cabin_placement_controller);
        placement.placement_relocating = can_relocate;
    }

    return true;
}

function cabin_build_at_site(_site)
{
    if (!instance_exists(_site))
    {
        return false;
    }

    var game_state = game_state_ensure();

    if (inventory_get_amount(
        game_state.player_inventory,
        ResourceId.TIMBER_PLANK
    ) < CABIN_TIMBER_PLANK_COST)
    {
        notification_show_hint(
            "Retrieve 4 Timber Planks from the Finished Crafts chest first.",
            game_get_speed(gamespeed_fps) * 4,
            false
        );
        return false;
    }

    if (!progression_build_cabin_state(game_state))
    {
        return false;
    }

    _site.sprite_index = spr_cabin_after;
    notification_show_hint(
        "Objective complete — return to the Task Board.",
        game_get_speed(gamespeed_fps) * 5,
        true
    );
    save_write();
    return true;
}
