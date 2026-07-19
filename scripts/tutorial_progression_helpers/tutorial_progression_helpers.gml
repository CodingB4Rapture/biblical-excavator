/// Tutorial progression: decides when objectives advance.
/// Collection and delivery code reports facts here; this script changes stages.

function tutorial_spawn_hand_fieldstones()
{
    var game_state = game_state_ensure();
    if (game_state.tutorial_stage != TutorialStage.TRIP_ONE_HAND_FIELDSTONE
    || instance_number(obj_small_fieldstone) > 0) return;

    game_state.tutorial_hand_stones_spawned = true;
    var positions = [
        [112, 112], [128, 112], [144, 112], [160, 112], [176, 112], [192, 112]
    ];

    for (var i = 0; i < array_length(positions); i++)
    {
        instance_create_depth(positions[i][0], positions[i][1], 0, obj_small_fieldstone);
    }
}

function tutorial_process_delivery(_delivery)
{
    var game_state = game_state_ensure();
    var home_stones = inventory_get_amount(game_state.home_inventory, ResourceId.FIELDSTONE);
    var home_logs = inventory_get_amount(game_state.home_inventory, ResourceId.TIMBER_LOG);

    if (game_state.tutorial_stage == TutorialStage.TRIP_ONE_HAND_FIELDSTONE
    && home_stones >= 6)
    {
        game_state.tutorial_stage = TutorialStage.TRIP_TWO_VEHICLE_FIELDSTONE;
        notification_show_hint(
            "Trip 1 complete. The skidsteer is ready for the remaining 10 fieldstones.",
            game_get_speed(gamespeed_fps) * 5,
            false
        );
    }

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
        game_state.tutorial_stage = TutorialStage.COMPLETE;
        _delivery.quest_completed = quest_complete(QuestId.FIRM_FOUNDATION);
        notification_show_hint(
            "Cabin materials are home. The foundation is ready for the next build step.",
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
