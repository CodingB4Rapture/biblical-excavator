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
                "We're glad to have another pair of hands. For your cabin foundation, we'll need 16 Fieldstones and one good log. Begin with 6 loose Fieldstones gathered by hand.",
                "After that, the work vehicle can handle the remaining 10. Take your time--we have something coming that will help with the log afterward."
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
                "You've earned a place of your own here. Walk the land and choose a clear spot for your cabin site.",
                "I'll help you mark it. Take all the time you need before you left-click the final spot."
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
                "The cabin site is placed. If the spot doesn't feel like home yet, we can move the stakes before you rest.",
                "Once it feels right, rest there. We'll begin the next chapter together in the morning."
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
                    "You've done wonderful work--there are enough supplies now to build your own cabin!",
                    "Choose a clear place for the cabin site, and we'll work through the construction together."
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
                "Good news--a winch attachment came in the mail. I left the package beside Home Delivery for you.",
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
            "Thank you. I'll keep these safe with your cabin supplies.",
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

    var empty_message = "Nothing to put away just yet. Bring home whatever looks useful, and I'll keep it safe.";

    if (homestead_stage == HomesteadStage.HUB_OPEN)
    {
        empty_message = "Your cabin site is established. Bring home what you can use, and we'll keep building from there together.";
    }

    if (game_state.winch_attachment_state == AttachmentState.INSTALLED)
    {
        empty_message = "The winch is ready. Downed trees and stumps belong inside the delivery circle.";
    }

    if (game_state.tutorial_stage == TutorialStage.PULL_STUMP)
    {
        empty_message = "The Timber Log is stored. Pull the stump into Home Delivery so we can recover Small Lumber.";
    }

    notification_show_dialogue(
        empty_message,
        id,
        game_get_speed(gamespeed_fps) * 4,
        NotificationStyle.PROMPT
    );
};
