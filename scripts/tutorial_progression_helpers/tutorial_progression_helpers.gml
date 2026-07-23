/// Tutorial progression: decides when objectives advance.
/// Collection and delivery code reports facts here; this script changes stages.

function tutorial_spawn_hand_fieldstones()
{
    var game_state = game_state_ensure();
    if (game_state.tutorial_stage != TutorialStage.TRIP_ONE_HAND_FIELDSTONE) return;

    var remaining_stones = max(
        0,
        6 - game_state.tutorial_fieldstones_collected
    );
    var available_stones = instance_number(obj_fieldstone)
        + instance_number(obj_small_fieldstone);

    if (available_stones < remaining_stones)
    {
        fieldstone_tutorial_ensure_visible_count(remaining_stones);
        available_stones = instance_number(obj_fieldstone)
            + instance_number(obj_small_fieldstone);
    }

    if (available_stones >= remaining_stones) return;

    game_state.tutorial_hand_stones_spawned = true;
    var actor = instance_find(obj_player, 0);
    if (!instance_exists(actor)) actor = instance_find(obj_farmers_wife, 0);
    var center_x = instance_exists(actor) ? actor.x : 128;
    var center_y = instance_exists(actor) ? actor.y : 112;

    // Spiral through nearby clear positions. Removed IDs are skipped so a
    // partial tutorial save can always restore exactly the stones still owed.
    for (var fallback_index = 0;
        fallback_index < 24 && available_stones < remaining_stones;
        fallback_index++)
    {
        var fallback_angle = fallback_index * 137.5;
        var fallback_radius = 36 + floor(fallback_index / 8) * 18;
        var fallback_x = clamp(
            center_x + lengthdir_x(fallback_radius, fallback_angle),
            8,
            room_width - 8
        );
        var fallback_y = clamp(
            center_y + lengthdir_y(fallback_radius, fallback_angle),
            8,
            room_height - 8
        );
        var fallback_world_id = "small_fieldstone_"
            + string(round(fallback_x)) + "_" + string(round(fallback_y));

        if (save_world_id_is_removed(fallback_world_id)
        || !resource_regeneration_spawn_is_clear(fallback_x, fallback_y, 5))
        {
            continue;
        }

        var fallback_stone = instance_create_depth(
            fallback_x,
            fallback_y,
            0,
            obj_small_fieldstone
        );

        if (instance_exists(fallback_stone)) available_stones += 1;
    }
}

function tutorial_report_hand_collection(_resource_id)
{
    if (_resource_id != ResourceId.FIELDSTONE) return false;

    var game_state = game_state_ensure();
    if (!task_is_active(TaskId.FIELDSTONE_BY_HAND, game_state)
    || game_state.tutorial_stage
        != TutorialStage.TRIP_ONE_HAND_FIELDSTONE)
    {
        return false;
    }

    game_state.tutorial_fieldstones_collected = min(
        6,
        game_state.tutorial_fieldstones_collected + 1
    );

    if (!progression_complete_hand_gathering_state(game_state))
    {
        return false;
    }

    var wife = instance_find(obj_farmers_wife, 0);
    notification_show_dialogue(
        [
            "Six good Fieldstones. The Farmer has gifted you an axe for the next part of the work.",
            "Your assignment is complete. Return to the Task Board to record it and accept the next work."
        ],
        wife,
        0,
        NotificationStyle.PROMPT,
        "FARMER'S WIFE"
    );

    notification_show_hint(
        "Task complete - return to the Task Board to claim it.",
        game_get_speed(gamespeed_fps) * 6,
        false
    );

    save_write();
    return true;
}

function tutorial_can_use_skidsteer()
{
    var game_state = game_state_ensure();
    if (game_state.tutorial_stage == TutorialStage.COMPLETE) return true;

    return task_is_active(TaskId.STONE_HAUL, game_state)
        || task_is_active(TaskId.FIT_THE_WINCH, game_state)
        || task_is_active(TaskId.TIMBER_DELIVERY, game_state);
}

function tutorial_report_tree_felled()
{
    var game_state = game_state_ensure();
    if (!task_is_active(TaskId.FALLEN_TREE, game_state)
    || game_state.tutorial_stage != TutorialStage.CHOP_TREE)
    {
        return false;
    }

    progression_set_tutorial_stage(
        game_state,
        TutorialStage.INSPECT_FALLEN_TREE
    );
    notification_show_hint(
        "The trunk and stump are too heavy to carry. Inspect the fallen tree.",
        game_get_speed(gamespeed_fps) * 5,
        false
    );
    save_write();
    return true;
}

function tutorial_report_felled_tree_inspected()
{
    var game_state = game_state_ensure();
    if (!task_is_active(TaskId.FALLEN_TREE, game_state)
    || game_state.tutorial_stage
        != TutorialStage.INSPECT_FALLEN_TREE)
    {
        return false;
    }

    task_complete(TaskId.FALLEN_TREE);
    notification_show_hint(
        "Task complete - return to the Task Board to claim it.",
        game_get_speed(gamespeed_fps) * 6,
        false
    );
    save_write();
    return true;
}

function tutorial_process_delivery(_delivery)
{
    var game_state = game_state_ensure();
    var home_stones = inventory_get_amount(game_state.home_inventory, ResourceId.FIELDSTONE);
    var home_logs = inventory_get_amount(game_state.home_inventory, ResourceId.TIMBER_LOG);
    var home_small_lumber = inventory_get_amount(
        game_state.home_inventory,
        ResourceId.SMALL_LUMBER
    );

    if (task_is_active(TaskId.STONE_HAUL, game_state)
    && game_state.tutorial_stage
        == TutorialStage.TRIP_TWO_VEHICLE_FIELDSTONE
    && home_stones >= 16
    && game_state.tutorial_fieldrocks_crushed >= 10)
    {
        _delivery.task_completed = task_complete(TaskId.STONE_HAUL);
        if (_delivery.task_completed)
        {
            notification_show_hint(
                "Stone Haul complete - return to the Task Board.",
                game_get_speed(gamespeed_fps) * 6,
                false
            );
        }
    }

    if (task_is_active(TaskId.TIMBER_DELIVERY, game_state)
    && game_state.tutorial_stage == TutorialStage.HAUL_FIRST_LOG
    && home_stones >= 16
    && home_logs >= 1)
    {
        progression_set_tutorial_stage(
            game_state,
            TutorialStage.PULL_STUMP
        );

        if (home_small_lumber < 1)
        {
            notification_show_hint(
                "Timber Log stored. Take the winch cable back to the stump and deliver it as Small Lumber.",
                game_get_speed(gamespeed_fps) * 6,
                false
            );
        }
    }

    // Separate checks intentionally allow a player who delivered both physical
    // pieces together to complete the sequence in the same unloading action.
    if (task_is_active(TaskId.TIMBER_DELIVERY, game_state)
    && game_state.tutorial_stage == TutorialStage.PULL_STUMP
    && home_stones >= 16
    && home_logs >= 1
    && home_small_lumber >= 1)
    {
        progression_set_tutorial_stage(
            game_state,
            TutorialStage.COMPLETE
        );
        _delivery.task_completed =
            task_complete(TaskId.TIMBER_DELIVERY);
        notification_show_hint(
            "Timber Delivery complete - return to the Task Board.",
            game_get_speed(gamespeed_fps) * 6,
            false
        );
    }
}

function tutorial_collect_winch_package()
{
    var game_state = game_state_ensure();
    if (!progression_collect_winch_package_state(game_state))
        return false;

    save_write();
    return true;
}
