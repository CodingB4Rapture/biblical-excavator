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
    if (game_state.tutorial_stage != TutorialStage.TRIP_ONE_HAND_FIELDSTONE)
    {
        return false;
    }

    game_state.tutorial_fieldstones_collected = min(
        6,
        game_state.tutorial_fieldstones_collected + 1
    );

    if (game_state.tutorial_fieldstones_collected < 6
    || game_state.tools.axe_owned)
    {
        return false;
    }

    // Grant before displaying or saving so reloads can never repeat the gift.
    game_state.tools.axe_owned = true;
    game_state.tutorial_stage = TutorialStage.CHOP_TREE;

    var wife = instance_find(obj_farmers_wife, 0);
    notification_show_dialogue(
        [
            "Six good Fieldstones. The Farmer has gifted you an axe for the next part of the work.",
            "You do not need to equip it. Find a standing tree and use E nearby to begin chopping."
        ],
        wife,
        0,
        NotificationStyle.PROMPT,
        "FARMER'S WIFE"
    );

    notification_show_hint(
        "Axe received - find a standing tree.",
        game_get_speed(gamespeed_fps) * 5,
        false
    );

    save_write();
    return true;
}

function tutorial_can_use_skidsteer()
{
    var stage = game_state_ensure().tutorial_stage;
    return stage != TutorialStage.TALK_TO_FARMER
        && stage != TutorialStage.TALK_TO_FARMERS_WIFE
        && stage != TutorialStage.TRIP_ONE_HAND_FIELDSTONE
        && stage != TutorialStage.CHOP_TREE
        && stage != TutorialStage.INSPECT_FALLEN_TREE;
}

function tutorial_report_tree_felled()
{
    var game_state = game_state_ensure();
    if (game_state.tutorial_stage != TutorialStage.CHOP_TREE) return false;

    game_state.tutorial_stage = TutorialStage.INSPECT_FALLEN_TREE;
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
    if (game_state.tutorial_stage != TutorialStage.INSPECT_FALLEN_TREE)
    {
        return false;
    }

    game_state.tutorial_stage = TutorialStage.TRIP_TWO_VEHICLE_FIELDSTONE;
    var wife = instance_find(obj_farmers_wife, 0);
    notification_show_dialogue(
        [
            "That trunk and stump are too heavy to carry. Leave them here until the winch is available.",
            "Keep your six Fieldstones in the backpack. Use the skidsteer to crush 10 Fieldrocks, then bring both loads to Home Delivery."
        ],
        wife,
        0,
        NotificationStyle.PROMPT,
        "FARMER'S WIFE"
    );
    notification_show_hint(
        "Crush 10 Fieldrocks, then deliver all 16 Fieldstones at Home Delivery.",
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

    if (game_state.tutorial_stage == TutorialStage.TRIP_TWO_VEHICLE_FIELDSTONE
    && home_stones >= 16
    && game_state.winch_attachment_state == AttachmentState.LOCKED)
    {
        game_state.winch_attachment_state = AttachmentState.MAIL_READY;
        game_state.tutorial_stage = TutorialStage.WINCH_PACKAGE_READY;
        _delivery.mail_became_ready = true;
    }

    if (game_state.tutorial_stage == TutorialStage.HAUL_FIRST_LOG
    && home_stones >= 16
    && home_logs >= 1)
    {
        game_state.tutorial_stage = TutorialStage.PULL_STUMP;

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
    if (game_state.tutorial_stage == TutorialStage.PULL_STUMP
    && home_stones >= 16
    && home_logs >= 1
    && home_small_lumber >= 1)
    {
        game_state.tutorial_stage = TutorialStage.COMPLETE;
        _delivery.quest_completed = quest_complete(QuestId.FIRM_FOUNDATION);
        notification_show_hint(
            "Stump delivered as Small Lumber. The cabin materials are home.",
            game_get_speed(gamespeed_fps) * 5,
            false
        );
    }
}

function tutorial_collect_winch_package()
{
    var game_state = game_state_ensure();
    if (game_state.winch_attachment_state != AttachmentState.MAIL_READY) return false;

    game_state.winch_attachment_state = AttachmentState.STORED_AT_HOME;
    game_state.tutorial_stage = TutorialStage.WINCH_INSTALL_REQUIRED;
    save_write();
    return true;
}
