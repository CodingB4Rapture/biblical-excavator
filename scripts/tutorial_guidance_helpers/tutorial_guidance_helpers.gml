/// Tutorial guidance: resolves the one world position marked by the yellow arrow.
/// It never advances progress; it only reads the current stage and inventories.

function tutorial_ensure_winch_package()
{
    var game_state = game_state_ensure();
    if (game_state.tutorial_stage != TutorialStage.WINCH_PACKAGE_READY
    || game_state.winch_attachment_state != AttachmentState.MAIL_READY) return noone;

    var package_instance = instance_find(obj_winch_package, 0);
    if (instance_exists(package_instance)) return package_instance;

    var dropoff = instance_find(obj_homebase_dropoff, 0);
    if (!instance_exists(dropoff)) return noone;
    return instance_create_depth(dropoff.x + 52, dropoff.y, -20, obj_winch_package);
}

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

function tutorial_guidance_target()
{
    var game_state = game_state_ensure();
    var target = noone;

    if (game_state.homestead_stage == HomesteadStage.FIRST_REST_REQUIRED)
    {
        target = instance_find(obj_cabin_site, 0);

        if (instance_exists(target))
        {
            return { valid: true, x: target.x, y: target.y };
        }

        if (game_state.cabin_site_placed
        && game_state.cabin_site_room == room_get_name(room))
        {
            return {
                valid: true,
                x: game_state.cabin_site_x,
                y: game_state.cabin_site_y
            };
        }

        return { valid: false, x: 0, y: 0 };
    }

    switch (game_state.tutorial_stage)
    {
        case TutorialStage.TALK_TO_FARMER: target = instance_find(obj_farmer, 0); break;
        case TutorialStage.TALK_TO_FARMERS_WIFE: target = instance_find(obj_farmers_wife, 0); break;

        case TutorialStage.TRIP_ONE_HAND_FIELDSTONE:
        {
            if (inventory_get_amount(game_state.player_inventory, ResourceId.FIELDSTONE) >= 6)
                target = instance_find(obj_homebase_dropoff, 0);
            else
            {
                var actor = instance_find(obj_player, 0);
                if (instance_exists(actor)) target = tutorial_find_nearest_hand_fieldstone(actor);
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

            if (secured_stones >= 16) target = instance_find(obj_homebase_dropoff, 0);
            else if (!vehicle.has_driver) target = vehicle;
            else target = instance_nearest(vehicle.x, vehicle.y, obj_fieldrock);
            break;
        }

        case TutorialStage.CHOP_TREE: target = instance_find(obj_tree, 0); break;
        case TutorialStage.INSPECT_FALLEN_TREE:
        {
            target = tree_find_felled_log();
            if (!instance_exists(target)) target = instance_find(obj_stump, 0);
            break;
        }

        case TutorialStage.WINCH_PACKAGE_READY: target = tutorial_ensure_winch_package(); break;
        case TutorialStage.WINCH_INSTALL_REQUIRED: target = instance_find(obj_skidsteer, 0); break;
        case TutorialStage.INSPECT_FIRST_LOG:
        case TutorialStage.ATTACH_CABLE_TO_LOG:
        {
            target = tree_find_felled_log();
            if (!instance_exists(target)) target = instance_find(obj_log, 0);
            break;
        }

        case TutorialStage.TAKE_WINCH_CABLE:
        {
            var vehicle = instance_find(obj_skidsteer, 0);
            if (instance_exists(vehicle))
                return { valid: true, x: winch_get_hitch_x(vehicle), y: winch_get_hitch_y(vehicle) };
            break;
        }

        case TutorialStage.HAUL_FIRST_LOG:
        {
            var haul_log = tree_find_felled_log();
            if (!instance_exists(haul_log)) haul_log = instance_find(obj_log, 0);
            var haul_vehicle = instance_find(obj_skidsteer, 0);

            if (!instance_exists(haul_log))
            {
                target = instance_find(obj_homebase_dropoff, 0);
                break;
            }

            if (!instance_exists(haul_vehicle))
            {
                target = haul_log;
                break;
            }

            if (haul_vehicle.winch_state == WinchState.STOWED)
            {
                return {
                    valid: true,
                    x: winch_get_hitch_x(haul_vehicle),
                    y: winch_get_hitch_y(haul_vehicle)
                };
            }

            if (haul_vehicle.winch_state == WinchState.ATTACHED
            && instance_exists(haul_vehicle.winch_target)
            && haul_vehicle.winch_target.resource_id == ResourceId.TIMBER_LOG)
            {
                target = instance_find(obj_homebase_dropoff, 0);
                break;
            }

            target = haul_log;
            break;
        }

        case TutorialStage.PULL_STUMP:
        {
            var stump = instance_find(obj_stump, 0);
            var stump_vehicle = instance_find(obj_skidsteer, 0);

            if (!instance_exists(stump))
            {
                target = instance_find(obj_homebase_dropoff, 0);
                break;
            }

            if (!instance_exists(stump_vehicle))
            {
                target = stump;
                break;
            }

            if (stump_vehicle.winch_state == WinchState.STOWED)
            {
                return {
                    valid: true,
                    x: winch_get_hitch_x(stump_vehicle),
                    y: winch_get_hitch_y(stump_vehicle)
                };
            }

            if (stump_vehicle.winch_state == WinchState.ATTACHED
            && stump_vehicle.winch_target == stump)
            {
                target = instance_find(obj_homebase_dropoff, 0);
                break;
            }

            target = stump;
            break;
        }
    }

    if (!instance_exists(target)) return { valid: false, x: 0, y: 0 };
    return { valid: true, x: target.x, y: target.y };
}
