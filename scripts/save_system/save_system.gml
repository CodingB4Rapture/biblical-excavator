/// Single-slot, versioned save system.
/// Save plain data only. Room instances are recreated, then restored from it.

function save_file_name()
{
    return working_directory + "save_slot_1.json";
}

function save_slot_exists()
{
    return file_exists(save_file_name());
}

function gameplay_is_paused()
{
    return variable_global_exists("gameplay_paused")
        && global.gameplay_paused;
}

function gameplay_set_paused(_paused)
{
    global.gameplay_paused = _paused;
}

function gameplay_ensure_controllable_actor()
{
    var player = instance_find(obj_player, 0);
    var vehicle = instance_find(obj_skidsteer, 0);

    if (instance_exists(player))
    {
        return player;
    }

    if (instance_exists(vehicle) && vehicle.has_driver)
    {
        return vehicle;
    }

    // Recovery rule: a playable room must never leave the player stranded
    // without either an on-foot character or control of the work vehicle.
    var spawn_x = instance_exists(vehicle) ? vehicle.x - 24 : 64;
    var spawn_y = instance_exists(vehicle) ? vehicle.y + 18 : 208;
    player = instance_create_depth(spawn_x, spawn_y, -1, obj_player);

    if (instance_exists(vehicle))
    {
        player.vehicle = vehicle;
    }

    return player;
}

function save_get_restore_room(_fallback_room)
{
    if (!variable_global_exists("save_restore_scene")
    || !is_struct(global.save_restore_scene)
    || !variable_struct_exists(global.save_restore_scene, "room_name"))
    {
        return _fallback_room;
    }

    var saved_room = asset_get_index(global.save_restore_scene.room_name);
    return (saved_room == -1) ? _fallback_room : saved_room;
}

function settings_ensure()
{
    if (!variable_global_exists("game_settings") || !is_struct(global.game_settings))
    {
        global.game_settings = {
            master_volume: 1,
            fullscreen: window_get_fullscreen()
        };
    }

    return global.game_settings;
}

function settings_apply()
{
    var settings = settings_ensure();
    audio_master_gain(settings.master_volume);
    window_set_fullscreen(settings.fullscreen);
}

function save_world_id_is_removed(_world_id)
{
    var game_state = game_state_ensure();

    for (var i = 0; i < array_length(game_state.removed_world_ids); i++)
    {
        if (game_state.removed_world_ids[i] == _world_id)
        {
            return true;
        }
    }

    return false;
}

function save_mark_world_removed(_world_id)
{
    if (_world_id == "" || save_world_id_is_removed(_world_id))
    {
        return;
    }

    var game_state = game_state_ensure();
    array_push(game_state.removed_world_ids, _world_id);
}

function save_clone_array(_source)
{
    var result = array_create(array_length(_source), 0);

    for (var i = 0; i < array_length(_source); i++)
    {
        result[i] = _source[i];
    }

    return result;
}

function save_copy_amounts(_inventory)
{
    return save_clone_array(_inventory.amounts);
}

function save_apply_amounts(_inventory, _amounts)
{
    for (var i = 0; i < min(array_length(_inventory.amounts), array_length(_amounts)); i++)
    {
        _inventory.amounts[i] = _amounts[i];
    }
}

function save_build_snapshot()
{
    var game_state = game_state_ensure();
    var settings = settings_ensure();
    var player = instance_find(obj_player, 0);
    var vehicle = instance_find(obj_skidsteer, 0);
    var log = instance_find(obj_log, 0);
    var dialogue = instance_find(obj_dialogue_bubble, 0);

    var scene = {
        room_name: room_get_name(room),
        player_active: instance_exists(player),
        player_x: instance_exists(player) ? player.x : 0,
        player_y: instance_exists(player) ? player.y : 0,
        vehicle_x: instance_exists(vehicle) ? vehicle.x : 0,
        vehicle_y: instance_exists(vehicle) ? vehicle.y : 0,
        vehicle_angle: instance_exists(vehicle) ? vehicle.image_angle : 0,
        vehicle_has_driver: instance_exists(vehicle) ? vehicle.has_driver : false,
        vehicle_cargo: instance_exists(vehicle)
            ? save_copy_amounts(vehicle.cargo_inventory)
            : array_create(ResourceId.COUNT, 0),
        log_exists: instance_exists(log),
        log_x: instance_exists(log) ? log.x : 0,
        log_y: instance_exists(log) ? log.y : 0,
        dialogue_active: instance_exists(dialogue),
        dialogue_pages: instance_exists(dialogue)
            ? save_clone_array(dialogue.pages)
            : [],
        dialogue_page_index: instance_exists(dialogue) ? dialogue.page_index : 0,
        dialogue_speaker: instance_exists(dialogue) ? dialogue.speaker_name : "",
        dialogue_completion_action: instance_exists(dialogue)
            ? dialogue.completion_action
            : "",
        dialogue_style: instance_exists(dialogue)
            ? dialogue.notification_style
            : NotificationStyle.PROMPT
    };

    return {
        format_version: 1,
        game_state: {
            player_inventory: save_copy_amounts(game_state.player_inventory),
            home_inventory: save_copy_amounts(game_state.home_inventory),
            trip_rocks_gathered: game_state.trip_rocks_gathered,
            trip_xp_gained: game_state.trip_xp_gained,
            daily_resources_gathered: save_clone_array(game_state.daily_resources_gathered),
            equipment_xp: game_state.equipment_xp,
            completed_deliveries: game_state.completed_deliveries,
            winch_attachment_state: game_state.winch_attachment_state,
            tutorial_intro_seen: game_state.tutorial_intro_seen,
            tutorial_stage: game_state.tutorial_stage,
            tutorial_hand_stones_spawned: game_state.tutorial_hand_stones_spawned,
            quest_statuses: save_clone_array(game_state.quest_statuses),
            cabin_placement_unlocked: game_state.cabin_placement_unlocked,
            cabin_site_placed: game_state.cabin_site_placed,
            cabin_site_room: game_state.cabin_site_room,
            cabin_site_x: game_state.cabin_site_x,
            cabin_site_y: game_state.cabin_site_y,
            homestead_stage: game_state.homestead_stage,
            first_hub_hint_pending: game_state.first_hub_hint_pending,
            day_number: game_state.day_number,
            time_of_day: game_state.time_of_day,
            removed_world_ids: save_clone_array(game_state.removed_world_ids)
        },
        scene: scene,
        settings: {
            master_volume: settings.master_volume,
            fullscreen: settings.fullscreen
        }
    };
}

function save_write_snapshot(_snapshot)
{
    var save_file = file_text_open_write(save_file_name());

    if (save_file < 0)
    {
        return false;
    }

    file_text_write_string(save_file, json_stringify(_snapshot));
    file_text_close(save_file);
    return true;
}

function save_write()
{
    return save_write_snapshot(save_build_snapshot());
}

function save_update_settings()
{
    if (!save_slot_exists())
    {
        return false;
    }

    var save_file = file_text_open_read(save_file_name());
    var save_text = file_text_read_string(save_file);
    file_text_close(save_file);

    try
    {
        var data = json_parse(save_text);
        var settings = settings_ensure();
        data.settings.master_volume = settings.master_volume;
        data.settings.fullscreen = settings.fullscreen;
        return save_write_snapshot(data);
    }
    catch (_error)
    {
        return false;
    }
}

function save_new_game()
{
    gameplay_set_paused(false);
    global.game_state = game_state_create_default();
    global.save_restore_pending = false;
    global.save_new_game_pending = true;
    return true;
}

function save_load()
{
    gameplay_set_paused(false);

    if (!save_slot_exists())
    {
        return false;
    }

    var save_file = file_text_open_read(save_file_name());
    var save_text = file_text_read_string(save_file);
    file_text_close(save_file);

    var data = undefined;

    try
    {
        data = json_parse(save_text);
    }
    catch (_error)
    {
        return false;
    }

    if (!is_struct(data)
    || !variable_struct_exists(data, "format_version")
    || data.format_version != 1)
    {
        return false;
    }

    if (!variable_struct_exists(data, "game_state")
    || !is_struct(data.game_state)
    || !variable_struct_exists(data, "scene")
    || !is_struct(data.scene))
    {
        return false;
    }

    // Small version-one additions remain compatible with an earlier v1 file.
    if (!variable_struct_exists(data.scene, "dialogue_active"))
    {
        data.scene.dialogue_active = false;
        data.scene.dialogue_pages = [];
        data.scene.dialogue_page_index = 0;
        data.scene.dialogue_speaker = "";
        data.scene.dialogue_completion_action = "";
        data.scene.dialogue_style = NotificationStyle.PROMPT;
    }

    if (!variable_struct_exists(data.scene, "dialogue_completion_action"))
    {
        data.scene.dialogue_completion_action = "";
    }

    if (!variable_struct_exists(data, "settings") || !is_struct(data.settings))
    {
        var current_settings = settings_ensure();
        data.settings = {
            master_volume: current_settings.master_volume,
            fullscreen: current_settings.fullscreen
        };
    }

    var saved_state = data.game_state;
    var game_state = game_state_create_default();
    save_apply_amounts(game_state.player_inventory, saved_state.player_inventory);
    save_apply_amounts(game_state.home_inventory, saved_state.home_inventory);
    game_state.trip_rocks_gathered = saved_state.trip_rocks_gathered;
    game_state.trip_xp_gained = saved_state.trip_xp_gained;
    if (variable_struct_exists(saved_state, "daily_resources_gathered"))
    {
        game_state.daily_resources_gathered = save_clone_array(saved_state.daily_resources_gathered);
    }
    game_state.equipment_xp = saved_state.equipment_xp;
    game_state.completed_deliveries = saved_state.completed_deliveries;
    game_state.winch_attachment_state = saved_state.winch_attachment_state;
    game_state.tutorial_intro_seen = saved_state.tutorial_intro_seen;
    game_state.tutorial_stage = saved_state.tutorial_stage;
    game_state.tutorial_hand_stones_spawned = saved_state.tutorial_hand_stones_spawned;

    if (variable_struct_exists(saved_state, "quest_statuses"))
    {
        game_state.quest_statuses = save_clone_array(saved_state.quest_statuses);
    }
    else
    {
        game_state.quest_statuses[QuestId.FIRM_FOUNDATION] =
            game_state.tutorial_stage == TutorialStage.COMPLETE
                ? QuestStatus.COMPLETE
                : QuestStatus.ACTIVE;
    }

    // Quest 1 does not become active until the Farmer's first conversation
    // reaches its final page.
    if (game_state.tutorial_stage == TutorialStage.TALK_TO_FARMER)
    {
        game_state.quest_statuses[QuestId.FIRM_FOUNDATION] = QuestStatus.LOCKED;
    }

    if (variable_struct_exists(saved_state, "cabin_placement_unlocked"))
    {
        game_state.cabin_placement_unlocked = saved_state.cabin_placement_unlocked;
    }
    else
    {
        game_state.cabin_placement_unlocked =
            game_state.tutorial_stage == TutorialStage.COMPLETE;
    }

    if (variable_struct_exists(saved_state, "cabin_site_placed"))
    {
        game_state.cabin_site_placed = saved_state.cabin_site_placed;
    }

    if (variable_struct_exists(saved_state, "cabin_site_room"))
    {
        game_state.cabin_site_room = saved_state.cabin_site_room;
    }

    if (variable_struct_exists(saved_state, "cabin_site_x"))
    {
        game_state.cabin_site_x = saved_state.cabin_site_x;
    }

    if (variable_struct_exists(saved_state, "cabin_site_y"))
    {
        game_state.cabin_site_y = saved_state.cabin_site_y;
    }

    // These optional fields keep earlier format-version-one saves compatible.
    if (variable_struct_exists(saved_state, "day_number"))
    {
        game_state.day_number = saved_state.day_number;
    }

    if (variable_struct_exists(saved_state, "time_of_day"))
    {
        game_state.time_of_day = saved_state.time_of_day;
    }

    if (variable_struct_exists(saved_state, "homestead_stage"))
    {
        game_state.homestead_stage = homestead_stage_sanitize(
            saved_state.homestead_stage,
            game_state
        );
    }
    else
    {
        game_state.homestead_stage = homestead_stage_infer(game_state);
    }

    if (variable_struct_exists(saved_state, "first_hub_hint_pending"))
    {
        game_state.first_hub_hint_pending = saved_state.first_hub_hint_pending;
    }

    game_state.removed_world_ids = variable_struct_exists(saved_state, "removed_world_ids")
        ? saved_state.removed_world_ids
        : [];
    global.game_state = game_state;

    global.game_settings = {
        master_volume: data.settings.master_volume,
        fullscreen: data.settings.fullscreen
    };
    settings_apply();

    global.save_restore_scene = data.scene;
    global.save_restore_pending = true;
    global.save_new_game_pending = false;
    return true;
}

function save_restore_room_state()
{
    if (!variable_global_exists("save_restore_scene")
    || !is_struct(global.save_restore_scene))
    {
        return;
    }

    var scene = global.save_restore_scene;
    var vehicle = instance_find(obj_skidsteer, 0);
    var player = instance_find(obj_player, 0);
    var log = instance_find(obj_log, 0);

    if (instance_exists(vehicle))
    {
        var restore_driver = scene.vehicle_has_driver && !scene.player_active;

        vehicle.x = scene.vehicle_x;
        vehicle.y = scene.vehicle_y;
        vehicle.image_angle = scene.vehicle_angle;
        save_apply_amounts(vehicle.cargo_inventory, scene.vehicle_cargo);

        vehicle.has_driver = restore_driver;
        vehicle.skidsteer_state = restore_driver
            ? SkidsteerState.DRIVING
            : SkidsteerState.EMPTY;
        vehicle.winch_handler = noone;
        vehicle.winch_target = noone;
        vehicle.winch_state = (game_state_ensure().winch_attachment_state == AttachmentState.INSTALLED)
            ? WinchState.STOWED
            : WinchState.UNAVAILABLE;

        // A held cable is intentionally reconstructed as stowed on load.
        // Return its tutorial objective to the rear hitch as well.
        if (game_state_ensure().tutorial_stage == TutorialStage.ATTACH_CABLE_TO_LOG)
        {
            game_state_ensure().tutorial_stage = TutorialStage.TAKE_WINCH_CABLE;
        }
    }

    if (scene.player_active)
    {
        if (!instance_exists(player))
        {
            player = instance_create_depth(scene.player_x, scene.player_y, -1, obj_player);
        }

        player.x = scene.player_x;
        player.y = scene.player_y;
        player.vehicle = vehicle;
    }
    else if (instance_exists(player))
    {
        with (player) instance_destroy();
    }

    if (scene.log_exists && instance_exists(log))
    {
        log.x = scene.log_x;
        log.y = scene.log_y;
        log.pullable_state = PullableState.FREE;
        log.tow_vehicle = noone;
    }

    if (game_state_ensure().tutorial_stage == TutorialStage.TRIP_ONE_HAND_FIELDSTONE)
    {
        tutorial_spawn_hand_fieldstones();
    }

    if (scene.dialogue_active && array_length(scene.dialogue_pages) > 0)
    {
        var dialogue = notification_show_dialogue(
            scene.dialogue_pages,
            noone,
            0,
            scene.dialogue_style,
            scene.dialogue_speaker,
            scene.dialogue_completion_action
        );

        dialogue.page_index = clamp(
            scene.dialogue_page_index,
            0,
            array_length(dialogue.pages) - 1
        );
    }
}
