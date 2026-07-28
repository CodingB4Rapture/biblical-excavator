/// Explicit, idempotent story commands invoked by authored cutscene steps.

function cutscene_execute_command_state(
    _game_state,
    _command_id
)
{
    switch (_command_id)
    {
        case CUTSCENE_COMMAND_FINISH_INTRO:
            _game_state.tutorial_intro_seen = true;
            if (_game_state.tutorial_stage
                == TutorialStage.TALK_TO_FARMER)
            {
                return progression_finish_farmer_intro_state(_game_state);
            }
            return true;

        case CUTSCENE_COMMAND_GIVE_FARMERS_AXE:
            if (_game_state.task_statuses[TaskId.FIELDSTONE_BY_HAND]
                < TaskStatus.COMPLETE)
            {
                return false;
            }
            _game_state.tools.axe_owned = true;
            return true;

        case CUTSCENE_COMMAND_BEGIN_WATER_TUTORIAL:
            if (!_game_state.cabin_built) return false;
            if (_game_state.water_tutorial_stage
                == WaterTutorialStage.COMPLETE)
            {
                return true;
            }
            _game_state.water_tutorial_stage =
                WaterTutorialStage.ACTIVE;
            _game_state.homestead_stage =
                HomesteadStage.WATER_SUPPLY_REQUIRED;
            return true;
    }
    return false;
}

function cutscene_execute_command(_command_id)
{
    var game_state = game_state_ensure();
    if (!cutscene_execute_command_state(game_state, _command_id))
        return false;

    switch (_command_id)
    {
        case CUTSCENE_COMMAND_FINISH_INTRO:
            progression_queue_quest_notice(
                "QUEST STARTED",
                QuestId.FIRM_FOUNDATION
            );
            break;

        case CUTSCENE_COMMAND_GIVE_FARMERS_AXE:
            progress_show_reward_summary(
                "Received the Farmer's Axe",
                "Axe work builds Toolmanship"
            );
            notification_show_hint(
                "Return to the Task Board to record the completed work.",
                game_get_speed(gamespeed_fps) * 6,
                false
            );
            break;

        case CUTSCENE_COMMAND_BEGIN_WATER_TUTORIAL:
            notification_show_hint(
                "Start at the lathe: make 1 Empty Bucket.",
                game_get_speed(gamespeed_fps) * 6,
                true
            );
            break;
    }

    save_write();
    return true;
}

function cutscene_request(_cutscene_id)
{
    var definition = cutscene_definition(_cutscene_id);
    if (is_undefined(definition)) return false;

    var game_state = game_state_ensure();
    var record = cutscene_state_get_record(game_state, _cutscene_id);
    if (is_undefined(record)
    || record.status == CutsceneStatus.COMPLETE)
    {
        return false;
    }

    if (instance_exists(obj_cutscene_controller))
    {
        var controller = instance_find(obj_cutscene_controller, 0);
        return controller.cutscene_id == _cutscene_id;
    }

    cutscene_state_activate(game_state, _cutscene_id);
    var controller = instance_create_depth(
        0,
        0,
        -20000,
        obj_cutscene_controller
    );
    cutscene_controller_configure(
        controller,
        _cutscene_id,
        record.checkpoint
    );
    cutscene_controller_prime_hidden_setup(controller);

    // A new game or loaded room already writes after every placed instance
    // finishes its Create Event. Saving here would snapshot partial instances.
    if (!save_room_startup_pending())
        save_write();
    return true;
}

function cutscene_begin_room_story()
{
    var game_state = game_state_ensure();
    var records = game_state.cutscene_records;
    for (var index = 0; index < array_length(records); index++)
    {
        if (records[index].status == CutsceneStatus.ACTIVE)
            return cutscene_request(records[index].id);
    }

    var intro = cutscene_state_get_record(
        game_state,
        CUTSCENE_INTRO_RESCUE
    );
    if (intro.status == CutsceneStatus.NOT_STARTED)
        return cutscene_request(CUTSCENE_INTRO_RESCUE);
    return false;
}

function cutscene_is_active()
{
    return instance_exists(obj_cutscene_controller);
}
