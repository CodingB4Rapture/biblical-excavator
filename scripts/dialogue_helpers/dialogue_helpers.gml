/// Shared conversation helpers.

function dialogue_is_active()
{
    return instance_exists(obj_dialogue_bubble);
}

function dialogue_advance_pressed()
{
    // Mouse and keyboard are equal ways to advance a conversation.
    return mouse_check_button_pressed(mb_left)
        || keyboard_check_pressed(ord("E"))
        || keyboard_check_pressed(vk_enter)
        || keyboard_check_pressed(vk_space);
}

function dialogue_get_speaker_name(_speaker)
{
    if (instance_exists(_speaker))
    {
        if (_speaker.object_index == obj_farmers_wife) return "FARMER'S WIFE";
        if (_speaker.object_index == obj_farmer) return "FARMER";
        if (_speaker.object_index == obj_player) return "YOU";
    }

    return "HOMESTEAD";
}

function dialogue_run_completion_action(_action)
{
    switch (_action)
    {
        case "finish_farmer_intro":
        {
            var game_state = game_state_ensure();

            if (game_state.tutorial_stage == TutorialStage.TALK_TO_FARMER)
            {
                game_state.tutorial_stage = TutorialStage.TALK_TO_FARMERS_WIFE;
            }

            quest_start(QuestId.FIRM_FOUNDATION);
            break;
        }

        case "start_hand_gathering":
        {
            var game_state = game_state_ensure();

            if (game_state.tutorial_stage == TutorialStage.TALK_TO_FARMERS_WIFE)
            {
                game_state.tutorial_stage = TutorialStage.TRIP_ONE_HAND_FIELDSTONE;
                tutorial_spawn_hand_fieldstones();
                save_write();
            }

            break;
        }

        case "unlock_cabin_placement":
        {
            cabin_unlock_placement();
            break;
        }

        case "begin_cabin_placement":
        {
            cabin_begin_placement(false);
            break;
        }

        case "move_cabin_site":
        {
            cabin_begin_placement(true);
            break;
        }
    }
}
