/// obj_farmer - Create Event

interaction_enabled = true;
interaction_radius = 32;
// The Wife has a slightly higher priority so their close placement does not
// make her impossible to select after the Farmer sends the player to her.
interaction_priority = 45;

farmer_home_x = x;
farmer_home_y = y;
farmer_route_mode = FARMER_ROUTE_IDLE;
farmer_route_points = [];
farmer_route_index = 0;
farmer_story_return_pending = false;
farmer_schedule_day = game_state_ensure().day_number;
farmer_pond_trip_day = -1;
image_speed = 0;

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
        notification_show_hint(
            "The opening greeting is still in progress.",
            game_get_speed(gamespeed_fps) * 2,
            false
        );
        return;
    }

    if (homestead_stage == HomesteadStage.FIRST_REST_REQUIRED)
    {
        notification_show_dialogue(
            "You did good work today. Rest at your new cabin, and we'll all start fresh in the morning.",
            id,
            0,
            NotificationStyle.PROMPT,
            "FARMER"
        );
        return;
    }

    if (homestead_stage == HomesteadStage.WATER_SUPPLY_REQUIRED)
    {
        var water_step = water_tutorial_next_step(game_state);
        var reminder = "Make an Empty Bucket at the lathe.";
        switch (water_step.kind)
        {
            case "wait":
                reminder = "Let the lathe finish turning your bucket.";
                break;
            case "collect":
                reminder = "Your bucket is waiting in the middle Finished Crafts chest.";
                break;
            case "fill":
                reminder = "Take that Empty Bucket down to the pond and fill it.";
                break;
            case "deposit":
                reminder = "Pour that Water Bucket into the farmyard tank. It should read 11/40.";
                break;
        }
        notification_show_dialogue(
            "One last thing before you rest. " + reminder,
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
            "You've made a fine start on your cabin. There's plenty of homestead work waiting whenever you're ready.",
            id,
            0,
            NotificationStyle.PROMPT,
            "FARMER"
        );
        return;
    }

    notification_show_dialogue("My wife keeps our work list straight. Speak with her whenever you need a little direction.", id, 0, NotificationStyle.PROMPT, "FARMER");
};
