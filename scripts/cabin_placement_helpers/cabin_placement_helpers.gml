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

function cabin_restore_predefined_flags()
{
    if (room_get_name(room) != "Room1") return 0;

    var game_state = game_state_ensure();
    if (game_state.cabin_fence_marked) return 0;

    var definitions = cabin_site_definitions();
    var restored = 0;

    for (var definition_index = 0;
        definition_index < array_length(definitions);
        definition_index++)
    {
        var definition = definitions[definition_index];
        if (game_state.cabin_selected_site_id != CABIN_SITE_NONE
        && game_state.cabin_selected_site_id != CABIN_SITE_LEGACY
        && game_state.cabin_selected_site_id != definition.id)
        {
            continue;
        }

        var corners = cabin_site_corner_positions(definition);
        for (var corner_index = 0;
            corner_index < array_length(corners);
            corner_index++)
        {
            var already_exists = false;

            for (var flag_index = 0;
                flag_index < instance_number(obj_cabin_site_flag);
                flag_index++)
            {
                var existing_flag = instance_find(
                    obj_cabin_site_flag,
                    flag_index
                );
                if (existing_flag.site_id == definition.id
                && existing_flag.corner_index == corner_index)
                {
                    already_exists = true;
                    break;
                }
            }

            if (already_exists) continue;

            var corner = corners[corner_index];
            var flag = instance_create_depth(
                corner.x,
                corner.y,
                10,
                obj_cabin_site_flag
            );
            flag.site_id = definition.id;
            flag.site_number = definition.number;
            flag.site_symbol = definition.symbol;
            flag.site_name = definition.name;
            flag.site_area_name = definition.area_name;
            flag.site_colour = definition.colour;
            flag.corner_index = corner_index;
            flag.image_index = corner_index
                mod max(1, sprite_get_number(spr_marker));
            restored += 1;
        }
    }

    return restored;
}

function cabin_find_guidance_flag(_actor = noone)
{
    var game_state = game_state_ensure();
    var best_flag = noone;
    var best_priority = -1;
    var best_distance = 1000000;

    for (var i = 0; i < instance_number(obj_cabin_site_flag); i++)
    {
        var flag = instance_find(obj_cabin_site_flag, i);
        if (!instance_exists(flag)
        || (game_state.cabin_selected_site_id != CABIN_SITE_NONE
            && game_state.cabin_selected_site_id != CABIN_SITE_LEGACY
            && flag.site_id != game_state.cabin_selected_site_id))
        {
            continue;
        }

        var taken = cabin_site_flag_is_taken(
            flag.site_id,
            flag.corner_index,
            game_state
        );
        var priority = taken ? 2 : 1;
        var distance = instance_exists(_actor)
            ? point_distance(_actor.x, _actor.y, flag.x, flag.y)
            : i;

        if (priority > best_priority
        || (priority == best_priority && distance < best_distance))
        {
            best_flag = flag;
            best_priority = priority;
            best_distance = distance;
        }
    }

    return best_flag;
}

function cabin_remove_unselected_site_flags(_selected_site_id)
{
    var removed_count = 0;

    for (var flag_index = instance_number(obj_cabin_site_flag) - 1;
        flag_index >= 0;
        flag_index--)
    {
        var candidate_flag = instance_find(
            obj_cabin_site_flag,
            flag_index
        );
        if (instance_exists(candidate_flag)
        && candidate_flag.site_id != _selected_site_id)
        {
            instance_destroy(candidate_flag);
            removed_count += 1;
        }
    }

    return removed_count;
}

function cabin_take_predefined_flag(_flag, _actor = noone)
{
    if (!instance_exists(_flag)) return false;

    var game_state = game_state_ensure();
    var selected_flag_site_id = _flag.site_id;
    var selected_flag_corner_index = _flag.corner_index;
    var definition = cabin_site_definition(selected_flag_site_id);
    if (is_undefined(definition)
    || !is_real(selected_flag_corner_index)
    || selected_flag_corner_index < 0
    || selected_flag_corner_index > 3
    || !task_is_active(TaskId.MARK_CABIN_SITE, game_state)
    || game_state.cabin_fence_marked
    || (game_state.cabin_selected_site_id != CABIN_SITE_NONE
        && game_state.cabin_selected_site_id != CABIN_SITE_LEGACY
        && game_state.cabin_selected_site_id != definition.id))
    {
        return false;
    }

    var selected_now =
        game_state.cabin_selected_site_id == CABIN_SITE_NONE
        || game_state.cabin_selected_site_id == CABIN_SITE_LEGACY;
    var repairing_unselected_site =
        selected_now && game_state.cabin_site_placed;
    if (selected_now)
    {
        if (!progression_record_cabin_site_state(
            game_state,
            definition.room_name,
            definition.x,
            definition.y,
            game_state.cabin_site_placed,
            definition.id
        ))
        {
            return false;
        }
    }

    if (repairing_unselected_site)
    {
        with (obj_cabin_site) instance_destroy();
        game_state.fence_records = fence_records_without_purpose(
            game_state.fence_records,
            FENCE_PURPOSE_CABIN_SITE
        );
        fence_restore_room();
    }

    if (!progression_take_cabin_site_flag_state(
        game_state,
        selected_flag_site_id,
        selected_flag_corner_index
    ))
    {
        return false;
    }

    if (!instance_exists(obj_cabin_site))
    {
        instance_create_depth(
            definition.x,
            definition.y,
            0,
            obj_cabin_site
        );
    }

    cabin_remove_unselected_site_flags(selected_flag_site_id);
    return cabin_confirm_site_from_flag(_flag, _actor);
}

function cabin_choose_predefined_site(_flag, _actor = noone)
{
    if (!instance_exists(_flag)) return false;

    var definition = cabin_site_definition(_flag.site_id);
    if (is_undefined(definition))
    {
        notification_show_hint(
            "This cabin marker has no valid site definition.",
            game_get_speed(gamespeed_fps) * 4,
            false
        );
        return false;
    }

    var game_state = game_state_ensure();
    if (!task_is_active(TaskId.MARK_CABIN_SITE, game_state))
    {
        notification_show_hint(
            "Accept Mark the Cabin Site at the Task Board first.",
            game_get_speed(gamespeed_fps) * 4,
            false
        );
        return false;
    }

    // This is an authored binary choice, so commit it atomically. Do not
    // route through relocation/legacy guards that can leave a partial save
    // with an active task and an unusable flag.
    if (!progression_choose_cabin_site_state(
        game_state,
        definition,
        _flag.corner_index
    ))
    {
        notification_show_hint(
            "The cabin site task could not be completed.",
            game_get_speed(gamespeed_fps) * 4,
            false
        );
        return false;
    }

    with (obj_cabin_site) instance_destroy();
    fence_restore_room();
    instance_create_depth(
        definition.x,
        definition.y,
        0,
        obj_cabin_site
    );

    with (obj_cabin_site_flag) instance_destroy();
    notification_show_hint(
        "Site "
            + definition.symbol
            + " selected. Claim this task, accept Build the Cabin, then retrieve 4 Timber Planks.",
        game_get_speed(gamespeed_fps) * 7,
        true
    );
    save_write();
    return true;
}

function cabin_confirm_site_from_flag(_flag, _actor = noone)
{
    if (!instance_exists(_flag)) return false;

    var game_state = game_state_ensure();
    if (!task_is_active(TaskId.MARK_CABIN_SITE, game_state)
    || game_state.cabin_selected_site_id != _flag.site_id
    || !cabin_site_flag_is_taken(
        _flag.site_id,
        _flag.corner_index,
        game_state
    ))
    {
        return false;
    }

    if (!progression_complete_cabin_site_selection_state(game_state))
    {
        return false;
    }

    with (obj_cabin_site_flag) instance_destroy();
    notification_show_hint(
        "Site selected. Claim this task, accept Build the Cabin, then retrieve 4 Timber Planks.",
        game_get_speed(gamespeed_fps) * 6,
        true
    );
    save_write();
    return true;
}

function cabin_create_fixed_fence(_actor = noone)
{
    var game_state = game_state_ensure();
    if (!game_state.cabin_site_placed || game_state.cabin_built)
    {
        return false;
    }

    var room_name = game_state.cabin_site_room;
    var bounds = cabin_fence_plot_bounds_at(
        game_state.cabin_site_x,
        game_state.cabin_site_y
    );
    var cabin_records = fence_make_rectangle_records(
        room_name,
        bounds.min_x,
        bounds.min_y,
        bounds.max_x,
        bounds.max_y,
        FENCE_PURPOSE_CABIN_SITE
    );
    var gate_result = fence_try_place_gate(
        cabin_records,
        room_name,
        bounds.min_x + fence_grid_size(),
        bounds.max_y,
        0,
        FENCE_PURPOSE_CABIN_SITE
    );

    if (!gate_result.valid
    || !cabin_fence_plot_status(
        gate_result.records,
        room_name,
        bounds
    ).valid)
    {
        notification_show_hint(
            "The cabin boundary could not be created. Please try the flag again.",
            game_get_speed(gamespeed_fps) * 4,
            false
        );
        return false;
    }

    var room_records = fence_records_without_purpose(
        fence_records_for_room(game_state.fence_records, room_name),
        FENCE_PURPOSE_CABIN_SITE
    );
    for (var record_index = 0;
        record_index < array_length(gate_result.records);
        record_index++)
    {
        array_push(
            room_records,
            fence_copy_record(gate_result.records[record_index])
        );
    }

    game_state.cabin_fence_marked = true;
    cabin_place_actor_at_exit(_actor);
    fence_commit_room_records(room_name, room_records);
    fence_refresh_room_instances(room_records, false, true);
    with (obj_cabin_site_flag) instance_destroy();
    return true;
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
    var predefined_site_id = cabin_site_id_at_position(
        room_get_name(room),
        _x,
        _y
    );
    var can_relocate = _relocating
        && game_state.cabin_site_placed
        && task_is_active(TaskId.MARK_CABIN_SITE, game_state)
        && !game_state.cabin_fence_marked;

    if (!game_state.cabin_placement_unlocked
    || predefined_site_id == CABIN_SITE_LEGACY
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
        can_relocate,
        predefined_site_id
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
    if (!game_state.cabin_placement_unlocked)
    {
        notification_show_hint("Complete A Firm Foundation to unlock a cabin site.", game_get_speed(gamespeed_fps) * 3, false);
        return false;
    }

    if (!task_is_active(TaskId.MARK_CABIN_SITE, game_state))
    {
        notification_show_hint(
            "Accept Mark the Cabin Site at the Task Board first.",
            game_get_speed(gamespeed_fps) * 4,
            false
        );
        return false;
    }

    if (game_state.cabin_site_placed)
    {
        notification_show_hint(
            "Your cabin location is committed. The other site is no longer available.",
            game_get_speed(gamespeed_fps) * 4,
            false
        );
        return false;
    }

    cabin_restore_predefined_flags();
    notification_show_hint(
        "Choose one marked site: gold Site I in Eireneikos Meadows or blue Site II in Farmer's Workfield. Take any flag to commit.",
        game_get_speed(gamespeed_fps) * 7,
        true
    );
    return true;
}

function cabin_build_at_site(_site, _actor = noone)
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

    if (!cabin_create_fixed_fence(_actor))
    {
        notification_show_hint(
            "The cabin fence could not be built. Please try adding the planks again.",
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
        "Planks added. The fence, front gate, and cabin are complete. Return to the Task Board.",
        game_get_speed(gamespeed_fps) * 5,
        true
    );
    save_write();
    return true;
}
