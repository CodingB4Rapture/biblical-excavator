/// obj_farmers_wife - Create Event

game_state_ensure();

interaction_enabled = true;
interaction_radius = 32;
interaction_priority = 50;

interaction_get_prompt = function(_actor)
{
    var game_state = game_state_ensure();

    if (game_state.tutorial_stage == TutorialStage.TALK_TO_FARMER)
    {
        return "Farmer asked you to speak with him";
    }

    return "Talk to Farmer's Wife";
};

interaction_run = function(_actor)
{
    var game_state = game_state_ensure();

    if (game_state.tutorial_stage == TutorialStage.TALK_TO_FARMER)
    {
        notification_show_hint("Speak with the Farmer first.", game_get_speed(gamespeed_fps) * 2, false);
        return;
    }

    if (game_state.tutorial_stage == TutorialStage.TALK_TO_FARMERS_WIFE)
    {
        game_state.tutorial_stage = TutorialStage.TRIP_ONE_HAND_FIELDSTONE;
        tutorial_spawn_hand_fieldstones();

        notification_show_dialogue(
            [
                "For the cabin foundation, we need 16 fieldstones and one good log. First, bring me 6 small loose stones by hand.",
                "After that, the work vehicle can handle the remaining 10. Take your time—something is coming that will help us handle the log afterward."
            ],
            id,
            0,
            NotificationStyle.PROMPT,
            "FARMER'S WIFE"
        );
        return;
    }

    var dropoff = instance_find(obj_homebase_dropoff, 0);
    var delivery = progress_deliver_homebase(dropoff);
    var delivery_line = progress_get_delivery_line(delivery);

    if (delivery.total > 0)
    {
        progress_show_reward_summary(
            "Home Delivery",
            delivery_line
        );

        if (delivery.quest_completed)
        {
            notification_show_dialogue(
                [
                    "Now you've got the supplies to build your own cabin!",
                    "Choose a clear place for the cabin site. We can work out the construction stages next."
                ],
                id,
                0,
                NotificationStyle.PROMPT,
                "FARMER'S WIFE",
                "unlock_cabin_placement"
            );
            return;
        }
    }

    if (progress_receive_winch_mail())
    {
        notification_show_dialogue(
            "A winch attachment came in the mail. I set it aside for the work vehicle.",
            id,
            game_get_speed(gamespeed_fps) * 6,
            NotificationStyle.PROMPT
        );

        notification_show_hint(
            "Walk to the vehicle and press E to install the winch attachment.",
            game_get_speed(gamespeed_fps) * 6,
            false
        );

        return;
    }

    if (delivery.total > 0)
    {
        notification_show_dialogue(
            "Thank you. I'll put these with our cabin supplies.",
            id,
            game_get_speed(gamespeed_fps) * 3,
            NotificationStyle.PROMPT
        );

        if (!delivery.vehicle_was_in_zone)
        {
            notification_show_hint(
                "Park the vehicle inside the Home Delivery circle to unload its cargo.",
                game_get_speed(gamespeed_fps) * 4,
                false
            );
        }

        return;
    }

    var game_state = game_state_ensure();
    var empty_message = "Nothing to put away yet. Bring home whatever you can use.";

    if (game_state.winch_attachment_state == AttachmentState.INSTALLED)
    {
        empty_message = "The winch is ready. Large logs belong inside the delivery circle.";
    }

    notification_show_dialogue(
        empty_message,
        id,
        game_get_speed(gamespeed_fps) * 4,
        NotificationStyle.PROMPT
    );
};
