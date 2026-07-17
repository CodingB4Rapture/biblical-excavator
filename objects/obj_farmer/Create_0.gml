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

    if (game_state.tutorial_stage == TutorialStage.TALK_TO_FARMER)
    {
        game_state.tutorial_stage = TutorialStage.TALK_TO_FARMERS_WIFE;

        notification_show_dialogue(
            [
                "Well, it might not look like much yet, but my wife and I bought this old homestead some years back. The folks before us had left the place to ruin, and it had been sitting that way for a long while.",
                "We always believed our lives were meant for restoration. So when we first walked onto this property, we knew there was good work waiting here. Work that didn't have to be done in vain.",
                "A good book says, 'The righteous shall inherit the land, and dwell in it forever.'",
                "My wife makes sure I stay busy enough to dwell on it forever, that's for certain.",
                "Still, I'm not as young as I used to be. That's why we put out the notice, and why you're standing here now. I'm glad you came.",
                "Let's hope you prove to be as good as your application. Talk to my wife for your first task."
            ],
            id,
            0,
            NotificationStyle.PROMPT,
            "FARMER"
        );
        return;
    }

    notification_show_dialogue("My wife keeps the work list straight. Speak with her when you need direction.", id, 0, NotificationStyle.PROMPT, "FARMER");
};
