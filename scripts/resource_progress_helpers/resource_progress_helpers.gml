/// Early collection, XP, and Homebase delivery helpers.

function progress_ensure_inventory()
{
    return game_state_ensure();
}

function progress_get_vehicle()
{
    return instance_find(obj_skidsteer, 0);
}

function progress_can_crush_resource(_resource_id)
{
    var vehicle = progress_get_vehicle();
    var definition = resource_get_definition(_resource_id);
    var reward_definition = resource_get_definition(definition.crush_result_id);

    if (!instance_exists(vehicle)
    || definition.crush_result_id < 0
    || definition.crush_result_amount <= 0)
    {
        return false;
    }

    if (!reward_definition.can_vehicle_carry) return false;

    return inventory_can_add(
        vehicle.cargo_inventory,
        definition.crush_result_id,
        definition.crush_result_amount
    );
}

function progress_show_reward_summary(_line_one, _line_two)
{
    var reward_summary = instance_find(obj_gui_reward_summary, 0);

    if (reward_summary == noone)
    {
        reward_summary = instance_create_depth(0, 0, -1200, obj_gui_reward_summary);
    }

    reward_summary.line_one = _line_one;
    reward_summary.line_two = _line_two;
    reward_summary.life = reward_summary.life_max;
    reward_summary.age = 0;

    return reward_summary;
}

function progress_award_crushed_resource(_resource_id, _xp_amount, _source_instance)
{
    var game_state = game_state_ensure();
    var vehicle = _source_instance;
    var definition = resource_get_definition(_resource_id);
    var reward_id = definition.crush_result_id;
    var reward_amount = definition.crush_result_amount;
    var reward_definition = resource_get_definition(reward_id);

    if (!instance_exists(vehicle))
    {
        vehicle = progress_get_vehicle();
    }

    if (!instance_exists(vehicle)
    || reward_id < 0
    || reward_amount <= 0
    || !reward_definition.can_vehicle_carry
    || !inventory_can_add(vehicle.cargo_inventory, reward_id, reward_amount))
    {
        return 0;
    }

    inventory_add(vehicle.cargo_inventory, reward_id, reward_amount);

    game_state.trip_rocks_gathered += reward_amount;
    game_state.daily_resources_gathered[reward_id] += reward_amount;
    game_state.trip_xp_gained += _xp_amount;
    game_state.equipment_xp += _xp_amount;

    var reward_name = resource_get_name(reward_id);
    if (reward_amount != 1) reward_name += "s";
    progress_show_reward_summary(
        "Crushed " + definition.name + ": loaded "
        + string(reward_amount) + " " + reward_name,
        "+" + string(_xp_amount) + " Equipment XP"
    );

    var drop_x = vehicle.x + random_range(-5, 5);
    var drop_y = vehicle.y - 18;
    var xp_drop = instance_create_depth(drop_x, drop_y, -900, obj_xp_drop);
    xp_drop.xp_amount = _xp_amount;

    return _xp_amount;
}

function progress_collect_resource_by_hand(_resource_instance)
{
    var game_state = game_state_ensure();
    var resource_id = _resource_instance.resource_id;
    var definition = resource_get_definition(resource_id);
    var is_renewable_fieldstone = variable_instance_exists(
        _resource_instance,
        "renewable_spawn"
    ) && _resource_instance.renewable_spawn;

    if (!is_renewable_fieldstone
    && game_state.tutorial_stage != TutorialStage.TRIP_ONE_HAND_FIELDSTONE)
    {
        notification_show_hint("The Farmer's Wife has not asked for hand-gathered fieldstone yet.", game_get_speed(gamespeed_fps) * 2, false);
        return false;
    }

    if (is_renewable_fieldstone
    && game_state.tutorial_stage != TutorialStage.TRIP_ONE_HAND_FIELDSTONE
    && game_state.tutorial_stage != TutorialStage.COMPLETE)
    {
        return false;
    }

    if (!definition.can_pocket)
    {
        notification_show_hint(
            definition.name + " is too large to carry by hand.",
            game_get_speed(gamespeed_fps) * 2,
            false
        );
        return false;
    }

    if (!inventory_can_add(game_state.player_inventory, resource_id, 1))
    {
        notification_show_hint(
            "Your backpack is full. Bring its contents home.",
            game_get_speed(gamespeed_fps) * 3,
            false
        );

        return false;
    }

    inventory_add(game_state.player_inventory, resource_id, 1);
    game_state.trip_rocks_gathered += 1;
    game_state.daily_resources_gathered[resource_id] += 1;

    if (is_renewable_fieldstone)
    {
        fieldstone_record_mark_collected(_resource_instance.world_id);
    }
    else
    {
        save_mark_world_removed(_resource_instance.world_id);
    }

    progress_show_reward_summary(
        "Pocketed 1 " + definition.name,
        "Backpack " + string(inventory_get_total(game_state.player_inventory))
        + " / " + string(game_state.player_inventory.capacity)
    );

    if (game_state.tutorial_stage == TutorialStage.TRIP_ONE_HAND_FIELDSTONE)
    {
        tutorial_report_hand_collection(resource_id);
    }

    with (_resource_instance)
    {
        instance_destroy();
    }

    if (is_renewable_fieldstone)
    {
        save_write();
    }

    return true;
}

function progress_deliver_homebase(_dropoff)
{
    var game_state = game_state_ensure();
    var delivery = {
        total: 0,
        fieldstone: 0,
        timber_logs: 0,
        small_lumber: 0,
        vehicle_was_in_zone: false,
        mail_became_ready: false,
        quest_completed: false
    };

    delivery.fieldstone += inventory_transfer_resource(
        game_state.player_inventory,
        game_state.home_inventory,
        ResourceId.FIELDSTONE
    );

    delivery.timber_logs += inventory_transfer_resource(
        game_state.player_inventory,
        game_state.home_inventory,
        ResourceId.TIMBER_LOG
    );

    var vehicle = progress_get_vehicle();

    if (instance_exists(vehicle) && instance_exists(_dropoff))
    {
        delivery.vehicle_was_in_zone = point_distance(
            vehicle.x,
            vehicle.y,
            _dropoff.x,
            _dropoff.y
        ) <= _dropoff.dropoff_radius;

        if (delivery.vehicle_was_in_zone)
        {
            delivery.fieldstone += inventory_transfer_resource(
                vehicle.cargo_inventory,
                game_state.home_inventory,
                ResourceId.FIELDSTONE
            );

            delivery.timber_logs += inventory_transfer_resource(
                vehicle.cargo_inventory,
                game_state.home_inventory,
                ResourceId.TIMBER_LOG
            );
        }
    }

    if (instance_exists(_dropoff))
    {
        for (var i = instance_number(obj_log) - 1; i >= 0; i--)
        {
            var log = instance_find(obj_log, i);

            if (!instance_exists(log)
            || log.pullable_state == PullableState.DELIVERED
            || point_distance(log.x, log.y, _dropoff.x, _dropoff.y) > _dropoff.dropoff_radius)
            {
                continue;
            }

            if (instance_exists(log.tow_vehicle))
            {
                winch_detach_target(log.tow_vehicle);
            }

            if (inventory_add(game_state.home_inventory, log.resource_id, 1) > 0)
            {
                delivery.timber_logs += 1;
                game_state.daily_resources_gathered[ResourceId.TIMBER_LOG] += 1;
                log.pullable_state = PullableState.DELIVERED;
                save_mark_world_removed(log.world_id);
                if (log.tree_world_id != "")
                {
                    tree_record_update_downed(log.tree_world_id, log.x, log.y, false);
                }

                with (log)
                {
                    instance_destroy();
                }
            }
        }

        for (var j = instance_number(obj_stump) - 1; j >= 0; j--)
        {
            var stump = instance_find(obj_stump, j);

            if (!instance_exists(stump)
            || stump.pullable_state == PullableState.DELIVERED
            || point_distance(stump.x, stump.y, _dropoff.x, _dropoff.y) > _dropoff.dropoff_radius)
            {
                continue;
            }

            if (instance_exists(stump.tow_vehicle))
            {
                winch_detach_target(stump.tow_vehicle);
            }

            var stump_definition = resource_get_definition(stump.resource_id);
            var lumber_id = stump_definition.delivery_result_id;

            if (lumber_id == ResourceId.SMALL_LUMBER
            && inventory_add(game_state.home_inventory, lumber_id, 1) > 0)
            {
                delivery.small_lumber += 1;
                game_state.daily_resources_gathered[lumber_id] += 1;
                stump.pullable_state = PullableState.DELIVERED;
                save_mark_world_removed(stump.world_id);

                if (stump.tree_world_id != "")
                {
                    tree_record_update_stump(stump.tree_world_id, stump.x, stump.y, false);
                }

                with (stump)
                {
                    instance_destroy();
                }
            }
        }
    }

    delivery.total = delivery.fieldstone + delivery.timber_logs + delivery.small_lumber;

    if (delivery.total > 0)
    {
        game_state.completed_deliveries += 1;
        game_state.trip_rocks_gathered = 0;
        game_state.trip_xp_gained = 0;

        tutorial_process_delivery(delivery);

        // Home Delivery is an intentional, understandable autosave point.
        save_write();
    }

    return delivery;
}

function progress_get_delivery_line(_delivery)
{
    var delivery_line = "";

    if (_delivery.fieldstone > 0)
    {
        delivery_line = string(_delivery.fieldstone) + " Fieldstone";
    }

    if (_delivery.timber_logs > 0)
    {
        if (delivery_line != "")
        {
            delivery_line += ", ";
        }

        delivery_line += string(_delivery.timber_logs) + " Timber Log";
    }

    if (_delivery.small_lumber > 0)
    {
        if (delivery_line != "")
        {
            delivery_line += ", ";
        }

        delivery_line += string(_delivery.small_lumber) + " Small Lumber";
    }

    return delivery_line;
}

/// Compatibility wrapper retained while Homebase behavior moves to the wife.
function progress_dropoff_homebase()
{
    var dropoff = instance_find(obj_homebase_dropoff, 0);
    var delivery = progress_deliver_homebase(dropoff);
    return delivery.total > 0;
}
