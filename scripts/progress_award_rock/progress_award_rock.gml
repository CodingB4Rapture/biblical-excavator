/// Early collection, XP, and Homebase delivery helpers.

function progress_ensure_inventory()
{
    return game_state_ensure();
}

function progress_get_vehicle()
{
    return instance_find(obj_skidsteer, 0);
}

function progress_can_collect_rocks(_amount)
{
    var vehicle = progress_get_vehicle();

    if (!instance_exists(vehicle))
    {
        return false;
    }

    return inventory_can_add(vehicle.cargo_inventory, ResourceId.FIELDSTONE, _amount);
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

function progress_award_rock(_rock_amount, _xp_amount, _source_instance)
{
    var game_state = game_state_ensure();
    var vehicle = _source_instance;

    if (!instance_exists(vehicle))
    {
        vehicle = progress_get_vehicle();
    }

    if (!instance_exists(vehicle)
    || !inventory_can_add(vehicle.cargo_inventory, ResourceId.FIELDSTONE, _rock_amount))
    {
        return 0;
    }

    inventory_add(vehicle.cargo_inventory, ResourceId.FIELDSTONE, _rock_amount);

    game_state.trip_rocks_gathered += _rock_amount;
    game_state.trip_xp_gained += _xp_amount;
    game_state.equipment_xp += _xp_amount;

    var rock_word = (_rock_amount == 1) ? "Fieldstone" : "Fieldstones";
    progress_show_reward_summary(
        "Loaded " + string(_rock_amount) + " " + rock_word,
        "+" + string(_xp_amount) + " Equipment XP"
    );

    var drop_x = vehicle.x + random_range(-5, 5);
    var drop_y = vehicle.y - 18;
    var xp_drop = instance_create_depth(drop_x, drop_y, -900, obj_xp_drop);
    xp_drop.xp_amount = _xp_amount;

    return _xp_amount;
}

function progress_collect_rock_by_hand(_rock_instance)
{
    var game_state = game_state_ensure();

    if (game_state.tutorial_stage != TutorialStage.TRIP_ONE_HAND_FIELDSTONE)
    {
        notification_show_hint("The Farmer's Wife has not asked for hand-gathered fieldstone yet.", game_get_speed(gamespeed_fps) * 2, false);
        return false;
    }

    if (!inventory_can_add(game_state.player_inventory, ResourceId.FIELDSTONE, 1))
    {
        notification_show_hint(
            "Your backpack is full. Bring its contents home.",
            game_get_speed(gamespeed_fps) * 3,
            false
        );

        return false;
    }

    inventory_add(game_state.player_inventory, ResourceId.FIELDSTONE, 1);
    game_state.trip_rocks_gathered += 1;
    save_mark_world_removed(_rock_instance.world_id);

    progress_show_reward_summary(
        "Pocketed 1 Fieldstone",
        "Backpack " + string(inventory_get_total(game_state.player_inventory))
        + " / " + string(game_state.player_inventory.capacity)
    );

    with (_rock_instance)
    {
        instance_destroy();
    }

    return true;
}

function tutorial_spawn_hand_fieldstones()
{
    var game_state = game_state_ensure();

    if (game_state.tutorial_stage != TutorialStage.TRIP_ONE_HAND_FIELDSTONE
    || instance_number(obj_small_fieldstone) > 0)
    {
        return;
    }

    game_state.tutorial_hand_stones_spawned = true;

    // One six-stone hand load: the first of the three designated work trips.
    var positions = [
        [112, 112], [128, 112], [144, 112], [160, 112], [176, 112], [192, 112]
    ];

    for (var i = 0; i < array_length(positions); i++)
    {
        instance_create_depth(positions[i][0], positions[i][1], 0, obj_small_fieldstone);
    }
}

function progress_deliver_homebase(_dropoff)
{
    var game_state = game_state_ensure();
    var delivery = {
        total: 0,
        fieldstone: 0,
        timber_logs: 0,
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
                log.pullable_state = PullableState.DELIVERED;
                save_mark_world_removed(log.world_id);

                with (log)
                {
                    instance_destroy();
                }
            }
        }
    }

    delivery.total = delivery.fieldstone + delivery.timber_logs;

    if (delivery.total > 0)
    {
        game_state.completed_deliveries += 1;
        game_state.trip_rocks_gathered = 0;
        game_state.trip_xp_gained = 0;

        if (game_state.tutorial_stage == TutorialStage.TRIP_ONE_HAND_FIELDSTONE
        && inventory_get_amount(game_state.home_inventory, ResourceId.FIELDSTONE) >= 6)
        {
            game_state.tutorial_stage = TutorialStage.TRIP_TWO_VEHICLE_FIELDSTONE;
            notification_show_hint("Trip 1 complete. The skidsteer is ready for the remaining 10 fieldstones.", game_get_speed(gamespeed_fps) * 5, false);
        }

        if (game_state.tutorial_stage == TutorialStage.TRIP_TWO_VEHICLE_FIELDSTONE
        && inventory_get_amount(game_state.home_inventory, ResourceId.FIELDSTONE) >= 16
        && game_state.winch_attachment_state == AttachmentState.LOCKED)
        {
            game_state.winch_attachment_state = AttachmentState.MAIL_READY;
            game_state.tutorial_stage = TutorialStage.WINCH_READY;
            delivery.mail_became_ready = true;
        }

        if (game_state.tutorial_stage == TutorialStage.HAUL_FIRST_LOG
        && inventory_get_amount(game_state.home_inventory, ResourceId.FIELDSTONE) >= 16
        && inventory_get_amount(game_state.home_inventory, ResourceId.TIMBER_LOG) >= 1)
        {
            game_state.tutorial_stage = TutorialStage.COMPLETE;
            delivery.quest_completed = quest_complete(QuestId.FIRM_FOUNDATION);
            notification_show_hint("Cabin materials are home. The foundation is ready for the next build step.", game_get_speed(gamespeed_fps) * 5, false);
        }

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

    return delivery_line;
}

function progress_receive_winch_mail()
{
    var game_state = game_state_ensure();

    if (game_state.winch_attachment_state != AttachmentState.MAIL_READY)
    {
        return false;
    }

    game_state.winch_attachment_state = AttachmentState.STORED_AT_HOME;
    return true;
}

/// Compatibility wrapper retained while Homebase behavior moves to the wife.
function progress_dropoff_homebase()
{
    var dropoff = instance_find(obj_homebase_dropoff, 0);
    var delivery = progress_deliver_homebase(dropoff);
    return delivery.total > 0;
}
