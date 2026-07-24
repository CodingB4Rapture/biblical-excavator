/// Tutorial guidance resolves one read-only target descriptor.
/// Room reconciliation owns any missing-instance creation.

function tutorial_find_nearest_hand_fieldstone(_actor)
{
    if (!instance_exists(_actor)) return noone;

    var tutorial_stone = instance_nearest(_actor.x, _actor.y, obj_small_fieldstone);
    var spawned_stone = instance_nearest(_actor.x, _actor.y, obj_fieldstone);

    if (!instance_exists(tutorial_stone)) return spawned_stone;
    if (!instance_exists(spawned_stone)) return tutorial_stone;

    return point_distance(_actor.x, _actor.y, spawned_stone.x, spawned_stone.y)
        < point_distance(_actor.x, _actor.y, tutorial_stone.x, tutorial_stone.y)
        ? spawned_stone
        : tutorial_stone;
}

function tutorial_guidance_actor()
{
    var actor = instance_find(obj_player, 0);
    if (instance_exists(actor)) return actor;

    var vehicle = instance_find(obj_skidsteer, 0);
    if (instance_exists(vehicle) && vehicle.has_driver) return vehicle;
    return noone;
}

function tutorial_find_nearest_target(_object, _actor = noone)
{
    if (instance_exists(_actor))
        return instance_nearest(_actor.x, _actor.y, _object);
    return instance_find(_object, 0);
}

function tutorial_guidance_invalid()
{
    return {
        valid: false,
        room_name: "",
        target_kind: "",
        target_world_id: "",
        x: 0,
        y: 0,
        label: ""
    };
}

function tutorial_guidance_at(
    _x,
    _y,
    _label,
    _room_name = "",
    _target_kind = "position",
    _target_world_id = ""
)
{
    return {
        valid: true,
        room_name: _room_name == ""
            ? room_get_name(room)
            : _room_name,
        target_kind: _target_kind,
        target_world_id: _target_world_id,
        x: _x,
        y: _y,
        label: _label
    };
}

function tutorial_guidance_from_instance(_target, _label)
{
    if (!instance_exists(_target)) return tutorial_guidance_invalid();
    var target_world_id = variable_instance_exists(_target, "world_id")
        ? _target.world_id
        : "";
    return tutorial_guidance_at(
        _target.x,
        _target.y,
        _label,
        room_get_name(room),
        object_get_name(_target.object_index),
        target_world_id
    );
}

function tutorial_guidance_gui_edge(
    _target_gui_x,
    _target_gui_y,
    _gui_width,
    _gui_height,
    _margin = 42
)
{
    if (point_in_rectangle(
        _target_gui_x,
        _target_gui_y,
        0,
        0,
        _gui_width,
        _gui_height
    ))
    {
        return {
            visible: true,
            x: _target_gui_x,
            y: _target_gui_y,
            direction: 0
        };
    }

    var center_x = _gui_width * 0.5;
    var center_y = _gui_height * 0.5;
    var offset_x = _target_gui_x - center_x;
    var offset_y = _target_gui_y - center_y;
    var left = _margin;
    var top = _margin;
    var right = _gui_width - _margin;
    var bottom = _gui_height - _margin;
    var edge_scale = 1;

    if (offset_x > 0)
        edge_scale = min(edge_scale, (right - center_x) / offset_x);
    else if (offset_x < 0)
        edge_scale = min(edge_scale, (left - center_x) / offset_x);

    if (offset_y > 0)
        edge_scale = min(edge_scale, (bottom - center_y) / offset_y);
    else if (offset_y < 0)
        edge_scale = min(edge_scale, (top - center_y) / offset_y);

    return {
        visible: false,
        x: center_x + offset_x * edge_scale,
        y: center_y + offset_y * edge_scale,
        direction: point_direction(
            center_x,
            center_y,
            _target_gui_x,
            _target_gui_y
        )
    };
}

function tutorial_guidance_target()
{
    var game_state = game_state_ensure();
    var guidance_actor = tutorial_guidance_actor();
    var target = noone;
    var label = "NEXT TASK";

    var board_attention_id = task_get_attention_id(game_state);
    if (game_state.tutorial_board_assignment_pending
    || board_attention_id >= 0)
    {
        var board_label = "TASK BOARD";
        if (board_attention_id >= 0
        && game_state.task_statuses[board_attention_id]
            == TaskStatus.COMPLETE)
        {
            board_label = "CLAIM REWARD";
        }

        return tutorial_guidance_from_instance(
            instance_find(obj_task_board, 0),
            board_label
        );
    }

    if (task_is_active(TaskId.PARK_SKIDSTEER, game_state))
    {
        var parking_vehicle = instance_find(obj_skidsteer, 0);

        if (instance_exists(parking_vehicle) && parking_vehicle.has_driver)
        {
            return tutorial_guidance_from_instance(
                instance_find(obj_skidsteer_parking_pad, 0),
                "PARKING PAD"
            );
        }

        return tutorial_guidance_from_instance(
            parking_vehicle,
            "SKIDSTEER"
        );
    }

    if (task_is_active(TaskId.MARK_CABIN_SITE, game_state))
    {
        var marked_site = instance_find(obj_cabin_site, 0);

        if (instance_exists(marked_site))
        {
            return tutorial_guidance_from_instance(
                marked_site,
                "CABIN SITE"
            );
        }

        return tutorial_guidance_invalid();
    }

    if (task_is_active(TaskId.PLACE_CABIN, game_state))
    {
        if (inventory_get_amount(
            game_state.player_inventory,
            ResourceId.TIMBER_PLANK
        ) < CABIN_TIMBER_PLANK_COST)
        {
            return tutorial_guidance_from_instance(
                instance_find(obj_finished_crafts_chest, 0),
                "FINISHED CRAFTS"
            );
        }

        return tutorial_guidance_from_instance(
            instance_find(obj_cabin_site, 0),
            "CABIN SITE"
        );
    }

    if (game_state.homestead_stage == HomesteadStage.FIRST_REST_REQUIRED)
    {
        target = instance_find(obj_cabin_site, 0);

        if (instance_exists(target))
        {
            return tutorial_guidance_from_instance(target, "CABIN SITE");
        }

        if (game_state.cabin_site_placed
        && game_state.cabin_site_room == room_get_name(room))
        {
            return tutorial_guidance_at(
                game_state.cabin_site_x,
                game_state.cabin_site_y,
                "CABIN SITE",
                game_state.cabin_site_room,
                "cabin_site"
            );
        }

        return tutorial_guidance_invalid();
    }

    switch (game_state.tutorial_stage)
    {
        case TutorialStage.TALK_TO_FARMER:
            target = instance_find(obj_farmer, 0);
            label = "FARMER";
            break;

        case TutorialStage.TALK_TO_FARMERS_WIFE:
            target = instance_find(obj_farmers_wife, 0);
            label = "FARMER'S WIFE";
            break;

        case TutorialStage.TRIP_ONE_HAND_FIELDSTONE:
        {
            if (inventory_get_amount(game_state.player_inventory, ResourceId.FIELDSTONE) >= 6)
            {
                target = instance_find(obj_homebase_dropoff, 0);
                label = "HOME DELIVERY";
            }
            else
            {
                var actor = instance_find(obj_player, 0);
                if (instance_exists(actor))
                    target = tutorial_find_nearest_hand_fieldstone(actor);
                label = "LOOSE FIELDSTONE";
            }
            break;
        }

        case TutorialStage.TRIP_TWO_VEHICLE_FIELDSTONE:
        {
            var vehicle = instance_find(obj_skidsteer, 0);
            if (!instance_exists(vehicle)) break;

            var secured_stones = inventory_get_amount(game_state.home_inventory, ResourceId.FIELDSTONE)
                + inventory_get_amount(vehicle.cargo_inventory, ResourceId.FIELDSTONE)
                + inventory_get_amount(game_state.player_inventory, ResourceId.FIELDSTONE);

            if (secured_stones >= 16)
            {
                target = instance_find(obj_homebase_dropoff, 0);
                label = "HOME DELIVERY";
            }
            else if (!vehicle.has_driver)
            {
                target = vehicle;
                label = "SKIDSTEER";
            }
            else
            {
                target = instance_nearest(vehicle.x, vehicle.y, obj_fieldrock);
                label = "FIELDROCK";
            }
            break;
        }

        case TutorialStage.CHOP_TREE:
            target = tutorial_find_nearest_target(
                obj_tree,
                guidance_actor
            );
            label = "STANDING TREE";
            break;

        case TutorialStage.INSPECT_FALLEN_TREE:
        {
            target = tutorial_find_nearest_target(
                obj_log,
                guidance_actor
            );
            if (!instance_exists(target))
            {
                target = tutorial_find_nearest_target(
                    obj_stump,
                    guidance_actor
                );
            }
            label = "FALLEN TREE";
            break;
        }

        case TutorialStage.WINCH_PACKAGE_READY:
            target = instance_find(obj_winch_package, 0);
            label = "WINCH PACKAGE";
            break;

        case TutorialStage.WINCH_INSTALL_REQUIRED:
            target = instance_find(obj_skidsteer, 0);
            label = "SKIDSTEER";
            break;

        case TutorialStage.INSPECT_FIRST_LOG:
        {
            var approach_vehicle = instance_find(obj_skidsteer, 0);
            if (instance_exists(approach_vehicle)
            && !approach_vehicle.has_driver)
            {
                target = approach_vehicle;
                label = "SKIDSTEER";
            }
            else
            {
                target = tutorial_find_nearest_target(
                    obj_log,
                    guidance_actor
                );
                if (!instance_exists(target))
                    target = instance_find(obj_log, 0);
                label = "TIMBER LOG";
            }
            break;
        }

        case TutorialStage.ATTACH_CABLE_TO_LOG:
        {
            target = tutorial_find_nearest_target(
                obj_log,
                guidance_actor
            );
            if (!instance_exists(target))
                target = instance_find(obj_log, 0);
            label = "TIMBER LOG";
            break;
        }

        case TutorialStage.TAKE_WINCH_CABLE:
        {
            var cable_vehicle = instance_find(obj_skidsteer, 0);
            if (instance_exists(cable_vehicle))
            {
                return tutorial_guidance_at(
                    winch_get_hitch_x(cable_vehicle),
                    winch_get_hitch_y(cable_vehicle),
                    "REAR HITCH"
                );
            }
            break;
        }

        case TutorialStage.HAUL_FIRST_LOG:
        {
            var haul_log = tutorial_find_nearest_target(
                obj_log,
                guidance_actor
            );
            if (!instance_exists(haul_log)) haul_log = instance_find(obj_log, 0);
            var haul_vehicle = instance_find(obj_skidsteer, 0);

            if (!instance_exists(haul_log))
            {
                target = instance_find(obj_homebase_dropoff, 0);
                label = "HOME DELIVERY";
                break;
            }

            if (!instance_exists(haul_vehicle))
            {
                target = haul_log;
                label = "TIMBER LOG";
                break;
            }

            if (haul_vehicle.winch_state == WinchState.STOWED)
            {
                return tutorial_guidance_at(
                    winch_get_hitch_x(haul_vehicle),
                    winch_get_hitch_y(haul_vehicle),
                    "REAR HITCH"
                );
            }

            if (haul_vehicle.winch_state == WinchState.ATTACHED
            && instance_exists(haul_vehicle.winch_target)
            && haul_vehicle.winch_target.resource_id == ResourceId.TIMBER_LOG)
            {
                target = instance_find(obj_homebase_dropoff, 0);
                label = "HOME DELIVERY";
                break;
            }

            target = haul_log;
            label = "TIMBER LOG";
            break;
        }

        case TutorialStage.PULL_STUMP:
        {
            var stump = tutorial_find_nearest_target(
                obj_stump,
                guidance_actor
            );
            if (!instance_exists(stump))
                stump = instance_find(obj_stump, 0);
            var stump_vehicle = instance_find(obj_skidsteer, 0);

            if (!instance_exists(stump))
            {
                target = instance_find(obj_homebase_dropoff, 0);
                label = "HOME DELIVERY";
                break;
            }

            if (!instance_exists(stump_vehicle))
            {
                target = stump;
                label = "STUMP";
                break;
            }

            if (stump_vehicle.winch_state == WinchState.ATTACHED
            && stump_vehicle.winch_target == stump)
            {
                target = instance_find(obj_homebase_dropoff, 0);
                label = "HOME DELIVERY";
                break;
            }

            var stump_in_cable_range = point_distance(
                winch_get_hitch_x(stump_vehicle),
                winch_get_hitch_y(stump_vehicle),
                stump.x,
                stump.y
            ) <= stump_vehicle.winch_cable_length;

            if (stump_vehicle.has_driver)
            {
                target = stump;
                label = "STUMP";
                break;
            }

            if (stump_vehicle.winch_state == WinchState.STOWED
            && !stump_in_cable_range)
            {
                target = stump_vehicle;
                label = "SKIDSTEER";
                break;
            }

            if (stump_vehicle.winch_state == WinchState.STOWED)
            {
                return tutorial_guidance_at(
                    winch_get_hitch_x(stump_vehicle),
                    winch_get_hitch_y(stump_vehicle),
                    "REAR HITCH"
                );
            }

            target = stump;
            label = "STUMP";
            break;
        }
    }

    return tutorial_guidance_from_instance(target, label);
}
