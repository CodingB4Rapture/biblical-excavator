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
    var homestead_stage = homestead_stage_get();

    if (game_state.tutorial_stage == TutorialStage.TALK_TO_FARMER)
    {
        notification_show_hint("Speak with the Farmer first.", game_get_speed(gamespeed_fps) * 2, false);
        return;
    }

    if (game_state.tutorial_stage == TutorialStage.TALK_TO_FARMERS_WIFE)
    {
        notification_show_dialogue(
            [
                "For the cabin foundation, we need 16 fieldstones and one good log. First, bring me 6 small loose stones by hand.",
                "After that, the work vehicle can handle the remaining 10. Take your time—something is coming that will help us handle the log afterward."
            ],
            id,
            0,
            NotificationStyle.PROMPT,
            "FARMER'S WIFE",
            "start_hand_gathering"
        );
        return;
    }

    if (game_state.cabin_placement_unlocked && !game_state.cabin_site_placed)
    {
        notification_show_dialogue(
            [
                "Walk the land and choose a clear place for the cabin site.",
                "I can help you mark it now, and you can still move around before you left-click the final spot."
            ],
            id,
            0,
            NotificationStyle.PROMPT,
            "FARMER'S WIFE",
            "begin_cabin_placement"
        );
        return;
    }

    if (homestead_stage == HomesteadStage.FIRST_REST_REQUIRED)
    {
        notification_show_dialogue(
            [
                "The cabin site is placed. If that spot doesn't feel right yet, we can move the stakes before you rest.",
                "After the site feels right, rest there and we'll begin the next chapter in the morning."
            ],
            id,
            0,
            NotificationStyle.PROMPT,
            "FARMER'S WIFE",
            "move_cabin_site"
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


        if (delivery.mail_became_ready)
        {
            notification_show_dialogue(
                "A winch attachment came in the mail. The package is beside Home Delivery.",
                id,
                0,
                NotificationStyle.PROMPT,
                "FARMER'S WIFE"
            );
            notification_show_hint(
                "Find the marked package and press E to collect it.",
                game_get_speed(gamespeed_fps) * 5,
                false
            );
            return;
        }
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

    var empty_message = "Nothing to put away yet. Bring home whatever you can use.";

    if (homestead_stage == HomesteadStage.HUB_OPEN)
    {
        empty_message = "The cabin site is established. Bring home what you can use, and we'll keep building from there.";
    }

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
