/// Farmer's Wife response selection, explicit effects, and presentation.

#macro FARMERS_WIFE_EFFECT_NONE ""
#macro FARMERS_WIFE_EFFECT_DELIVER_HOMEBASE "deliver_homebase"

function farmers_wife_response_create(
    _pages = [],
    _duration = 0,
    _completion_action = "",
    _hint = "",
    _hint_duration = 0,
    _hint_sticky = false,
    _effect_id = FARMERS_WIFE_EFFECT_NONE,
    _reward_heading = "",
    _reward_line = ""
)
{
    return {
        pages: _pages,
        speaker: "FARMER'S WIFE",
        style: NotificationStyle.PROMPT,
        duration: _duration,
        completion_action: _completion_action,
        hint: _hint,
        hint_duration: _hint_duration,
        hint_sticky: _hint_sticky,
        effect_id: _effect_id,
        reward_heading: _reward_heading,
        reward_line: _reward_line
    };
}

function farmers_wife_get_interaction_prompt(
    _wife,
    _actor,
    _game_state = undefined
)
{
    var game_state = is_undefined(_game_state)
        ? game_state_read()
        : _game_state;

    if (game_state.tutorial_stage == TutorialStage.TALK_TO_FARMER)
    {
        return "Farmer asked you to speak with him";
    }

    return "Talk to Farmer's Wife";
}

/// Pure response selection. It reads the supplied durable state and returns
/// plain data; effects and presentation are handled by separate functions.
function farmers_wife_get_response(_wife, _actor, _game_state)
{
    if (_game_state.tutorial_stage == TutorialStage.TALK_TO_FARMER)
    {
        return farmers_wife_response_create(
            [],
            0,
            "",
            "Speak with the Farmer first.",
            game_get_speed(gamespeed_fps) * 2
        );
    }

    if (_game_state.tutorial_stage == TutorialStage.TALK_TO_FARMERS_WIFE)
    {
        if (_game_state.tutorial_board_assignment_pending)
        {
            return farmers_wife_response_create([
                "Your first assignment is waiting on the Task Board beside us.",
                "Walk up to the board, press E, select Fieldstone by Hand, and accept the task. Your work marker will lead you from there."
            ]);
        }

        return farmers_wife_response_create(
            [
                "We're glad to have another pair of hands. For your cabin foundation, we'll need 16 Fieldstones and one good log. Begin with 6 loose Fieldstones gathered by hand.",
                "I've posted your first assignment on the Task Board beside us. Walk over, press E, and accept Fieldstone by Hand before you begin.",
                "Once you accept it, your work marker will point you toward the loose stones. Return to the board whenever you need the details."
            ],
            0,
            DIALOGUE_ACTION_POST_FIRST_TASK
        );
    }

    if (_game_state.cabin_placement_unlocked
    && task_get_status(TaskId.PARK_SKIDSTEER, _game_state)
        == TaskStatus.AVAILABLE)
    {
        return farmers_wife_response_create([
            "Before we mark the cabin ground, return the skidsteer to the small parking pad beside the Farmer.",
            "I posted Park the Skidsteer on the Task Board. Accept it there, then follow the work marker."
        ]);
    }

    if (task_is_active(TaskId.PARK_SKIDSTEER, _game_state))
    {
        return farmers_wife_response_create(
            "Park the skidsteer fully inside the pad, bring it to a stop with nothing attached, then hop out."
        );
    }

    if (task_get_status(TaskId.MARK_CABIN_SITE, _game_state)
        == TaskStatus.AVAILABLE)
    {
        return farmers_wife_response_create([
            "The skidsteer is settled. Your next assignment is waiting on the Task Board.",
            "Accept Mark the Cabin Site there. You will choose the ground, then fence the exact cabin and yard boundary with one front gate."
        ]);
    }

    if (task_is_active(TaskId.MARK_CABIN_SITE, _game_state))
    {
        return farmers_wife_response_create(
            _game_state.cabin_site_placed
                ? "Go to the cabin stakes and press E. Fence the highlighted boundary, then add one gate on the front side."
                : "Press B to choose a clear cabin-and-yard area. The boundary size is fixed, so choose the whole space carefully."
        );
    }

    if (task_get_status(TaskId.PLACE_CABIN, _game_state)
        == TaskStatus.AVAILABLE)
    {
        return farmers_wife_response_create(
            "The site is marked. Claim that work and accept Build the Cabin at the Task Board."
        );
    }

    if (task_is_active(TaskId.PLACE_CABIN, _game_state))
    {
        return farmers_wife_response_create(
            "The boundary is ready. Go to the marked site and press E to build the cabin inside it."
        );
    }

    if (_game_state.homestead_stage == HomesteadStage.FIRST_REST_REQUIRED)
    {
        if (task_get_status(TaskId.PLACE_CABIN, _game_state)
            == TaskStatus.COMPLETE)
        {
            return farmers_wife_response_create(
                "The cabin is built. Claim the completed work at the Task Board, then come back here to rest."
            );
        }

        return farmers_wife_response_create([
            "Your cabin is ready inside the boundary you marked.",
            "Rest there when you are ready. We'll begin the next chapter together in the morning."
        ]);
    }

    return farmers_wife_response_create(
        [],
        0,
        "",
        "",
        0,
        false,
        FARMERS_WIFE_EFFECT_DELIVER_HOMEBASE
    );
}

function farmers_wife_delivery_response(_delivery, _game_state)
{
    var reward_heading = "";
    var reward_line = "";

    if (_delivery.total > 0)
    {
        reward_heading = "Home Delivery";
        reward_line = progress_get_delivery_line(_delivery);
    }

    if (_delivery.quest_completed)
    {
        return farmers_wife_response_create(
            [
                "You've done wonderful work--there are enough supplies now to build your own cabin!",
                "Choose a clear place for the cabin site, and we'll work through the construction together."
            ],
            0,
            DIALOGUE_ACTION_UNLOCK_CABIN,
            "",
            0,
            false,
            FARMERS_WIFE_EFFECT_NONE,
            reward_heading,
            reward_line
        );
    }

    if (_delivery.mail_became_ready)
    {
        return farmers_wife_response_create(
            "Good news--a winch attachment came in the mail. I left the package beside Home Delivery for you.",
            0,
            "",
            "Find the marked package and press E to collect it.",
            game_get_speed(gamespeed_fps) * 5,
            false,
            FARMERS_WIFE_EFFECT_NONE,
            reward_heading,
            reward_line
        );
    }

    if (_delivery.total > 0)
    {
        return farmers_wife_response_create(
            "Thank you. I'll keep these safe with your cabin supplies.",
            game_get_speed(gamespeed_fps) * 3,
            "",
            _delivery.vehicle_was_in_zone
                ? ""
                : "Park the vehicle inside the Home Delivery circle to unload its cargo.",
            game_get_speed(gamespeed_fps) * 4,
            false,
            FARMERS_WIFE_EFFECT_NONE,
            reward_heading,
            reward_line
        );
    }

    var empty_message =
        "Nothing to put away just yet. Bring home whatever looks useful, and I'll keep it safe.";

    if (_game_state.homestead_stage == HomesteadStage.HUB_OPEN)
    {
        empty_message =
            "Your cabin site is established. Bring home what you can use, and we'll keep building from there together.";
    }

    if (_game_state.winch_attachment_state == AttachmentState.INSTALLED)
    {
        empty_message =
            "The winch is ready. Downed trees and stumps belong inside the delivery circle.";
    }

    if (_game_state.tutorial_stage == TutorialStage.PULL_STUMP)
    {
        empty_message =
            "The Timber Log is stored. Pull the stump into Home Delivery so we can recover Small Lumber.";
    }

    return farmers_wife_response_create(
        empty_message,
        game_get_speed(gamespeed_fps) * 4
    );
}

/// Executes the requested feature-specific command and returns presentation
/// data describing its result.
function farmers_wife_apply_effect(_effect_id, _game_state)
{
    if (_effect_id == FARMERS_WIFE_EFFECT_DELIVER_HOMEBASE)
    {
        var dropoff = instance_find(obj_homebase_dropoff, 0);
        var delivery = progress_deliver_homebase(dropoff);
        return farmers_wife_delivery_response(delivery, _game_state);
    }

    return farmers_wife_response_create();
}

function farmers_wife_present_response(_wife, _response)
{
    if (_response.reward_heading != "")
    {
        progress_show_reward_summary(
            _response.reward_heading,
            _response.reward_line
        );
    }

    var has_pages = is_array(_response.pages)
        ? array_length(_response.pages) > 0
        : _response.pages != "";

    if (has_pages)
    {
        notification_show_dialogue(
            _response.pages,
            _wife,
            _response.duration,
            _response.style,
            _response.speaker,
            _response.completion_action
        );
    }

    if (_response.hint != "")
    {
        notification_show_hint(
            _response.hint,
            _response.hint_duration,
            _response.hint_sticky
        );
    }
}

function farmers_wife_run_interaction(_wife, _actor)
{
    var game_state = game_state_ensure();
    var response = farmers_wife_get_response(
        _wife,
        _actor,
        game_state
    );

    if (response.effect_id != FARMERS_WIFE_EFFECT_NONE)
    {
        response = farmers_wife_apply_effect(
            response.effect_id,
            game_state
        );
    }

    farmers_wife_present_response(_wife, response);
}
