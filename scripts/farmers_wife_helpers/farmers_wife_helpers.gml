/// Farmer's Wife dialogue selection and interaction transactions.
/// The room object owns only interaction configuration and delegates here.

function farmers_wife_get_interaction_prompt(_wife, _actor)
{
    var game_state = game_state_ensure();

    if (game_state.tutorial_stage == TutorialStage.TALK_TO_FARMER)
    {
        return "Farmer asked you to speak with him";
    }

    return "Talk to Farmer's Wife";
}

function farmers_wife_run_interaction(_wife, _actor)
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
        if (game_state.tutorial_board_assignment_pending)
        {
            notification_show_dialogue(
                [
                    "Your first assignment is waiting on the Task Board beside us.",
                    "Walk up to the board, press E, select Fieldstone by Hand, and accept the task. Your work marker will lead you from there."
                ],
                _wife,
                0,
                NotificationStyle.PROMPT,
                "FARMER'S WIFE"
            );
            return;
        }

        notification_show_dialogue(
            [
                "We're glad to have another pair of hands. For your cabin foundation, we'll need 16 Fieldstones and one good log. Begin with 6 loose Fieldstones gathered by hand.",
                "I've posted your first assignment on the Task Board beside us. Walk over, press E, and accept Fieldstone by Hand before you begin.",
                "Once you accept it, your work marker will point you toward the loose stones. Return to the board whenever you need the details."
            ],
            _wife,
            0,
            NotificationStyle.PROMPT,
            "FARMER'S WIFE",
            DIALOGUE_ACTION_POST_FIRST_TASK
        );
        return;
    }

    if (game_state.cabin_placement_unlocked
    && task_get_status(TaskId.PARK_SKIDSTEER)
        == TaskStatus.AVAILABLE)
    {
        notification_show_dialogue(
            [
                "Before we mark the cabin ground, return the skidsteer to the small parking pad beside the Farmer.",
                "I posted Park the Skidsteer on the Task Board. Accept it there, then follow the work marker."
            ],
            _wife,
            0,
            NotificationStyle.PROMPT,
            "FARMER'S WIFE"
        );
        return;
    }

    if (task_is_active(TaskId.PARK_SKIDSTEER, game_state))
    {
        notification_show_dialogue(
            "Park the skidsteer fully inside the pad, bring it to a stop with nothing attached, then hop out.",
            _wife,
            0,
            NotificationStyle.PROMPT,
            "FARMER'S WIFE"
        );
        return;
    }

    if (task_get_status(TaskId.MARK_CABIN_SITE)
        == TaskStatus.AVAILABLE)
    {
        notification_show_dialogue(
            [
                "The skidsteer is settled. Your next assignment is waiting on the Task Board.",
                "Accept Mark the Cabin Site there. You will choose the ground, then fence the exact cabin and yard boundary with one front gate."
            ],
            _wife,
            0,
            NotificationStyle.PROMPT,
            "FARMER'S WIFE"
        );
        return;
    }

    if (task_is_active(TaskId.MARK_CABIN_SITE, game_state))
    {
        notification_show_dialogue(
            game_state.cabin_site_placed
                ? "Go to the cabin stakes and press E. Fence the highlighted boundary, then add one gate on the front side."
                : "Press B to choose a clear cabin-and-yard area. The boundary size is fixed, so choose the whole space carefully.",
            _wife,
            0,
            NotificationStyle.PROMPT,
            "FARMER'S WIFE"
        );
        return;
    }

    if (task_get_status(TaskId.PLACE_CABIN)
        == TaskStatus.AVAILABLE)
    {
        notification_show_dialogue(
            "The site is marked. Claim that work and accept Build the Cabin at the Task Board.",
            _wife,
            0,
            NotificationStyle.PROMPT,
            "FARMER'S WIFE"
        );
        return;
    }

    if (task_is_active(TaskId.PLACE_CABIN, game_state))
    {
        notification_show_dialogue(
            "The boundary is ready. Go to the marked site and press E to build the cabin inside it.",
            _wife,
            0,
            NotificationStyle.PROMPT,
            "FARMER'S WIFE"
        );
        return;
    }

    if (homestead_stage == HomesteadStage.FIRST_REST_REQUIRED)
    {
        if (task_get_status(TaskId.PLACE_CABIN)
            == TaskStatus.COMPLETE)
        {
            notification_show_dialogue(
                "The cabin is built. Claim the completed work at the Task Board, then come back here to rest.",
                _wife,
                0,
                NotificationStyle.PROMPT,
                "FARMER'S WIFE"
            );
            return;
        }

        notification_show_dialogue(
            [
                "Your cabin is ready inside the boundary you marked.",
                "Rest there when you are ready. We'll begin the next chapter together in the morning."
            ],
            _wife,
            0,
            NotificationStyle.PROMPT,
            "FARMER'S WIFE",
            ""
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
                _wife,
                0,
                NotificationStyle.PROMPT,
                "FARMER'S WIFE",
                DIALOGUE_ACTION_UNLOCK_CABIN
            );
            return;
        }


        if (delivery.mail_became_ready)
        {
            notification_show_dialogue(
                "Good news--a winch attachment came in the mail. I left the package beside Home Delivery for you.",
                _wife,
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
            _wife,
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
        _wife,
        game_get_speed(gamespeed_fps) * 4,
        NotificationStyle.PROMPT
    );
}
