/// obj_farmer - Create Event

interaction_enabled = true;
interaction_radius = 32;
// The Wife has a slightly higher priority so their close placement does not
// make her impossible to select after the Farmer sends the player to her.
interaction_priority = 45;

interaction_get_prompt = function(_actor)
{
    return "Talk to Farmer";
};

interaction_run = function(_actor)
{
    var game_state = game_state_ensure();
    var homestead_stage = homestead_stage_get();

    if (game_state.tutorial_stage == TutorialStage.TALK_TO_FARMER)
    {
        notification_show_dialogue(
            [
                "Well, it might not look like much yet, but my wife and I bought this old homestead some years back.",
                "The folks before us had left the place to ruin, and it had been sitting that way for a long while.",
                "We always believed our lives were meant for restoration. When we first walked onto this property, we knew there was good work waiting here.",
                "Work that didn't have to be done in vain.",
                "A good book says, 'The righteous shall inherit the land, and dwell in it forever.'",
                "My wife makes sure I stay busy enough to dwell on it forever, that's for certain.",
                "Still, I'm not as young as I used to be. That's why we put out the notice, and why you're standing here now. I'm truly glad you came.",
                "We're grateful for the help. Go introduce yourself to my wife; she'll get you settled with your first task."
            ],
            id,
            0,
            NotificationStyle.PROMPT,
            "FARMER",
            "finish_farmer_intro"
        );
        return;
    }

    if (homestead_stage == HomesteadStage.FIRST_REST_REQUIRED)
    {
        notification_show_dialogue(
            "You did good work today. Rest at the cabin site, and we'll all start fresh in the morning.",
            id,
            0,
            NotificationStyle.PROMPT,
            "FARMER"
        );
        return;
    }

    if (homestead_stage == HomesteadStage.HUB_OPEN)
    {
        notification_show_dialogue(
            "You've made a fine start on your cabin site. There's plenty of homestead work waiting whenever you're ready.",
            id,
            0,
            NotificationStyle.PROMPT,
            "FARMER"
        );
        return;
    }

    notification_show_dialogue("My wife keeps our work list straight. Speak with her whenever you need a little direction.", id, 0, NotificationStyle.PROMPT, "FARMER");
};
