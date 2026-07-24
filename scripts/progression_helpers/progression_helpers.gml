/// The only runtime write API for tutorial, task, quest, and story unlocks.
///
/// World systems report facts to tutorial_progression_helpers. Board/NPC UI
/// invokes the commands here. Save migration derives legacy state separately.

function progression_announcement_reset()
{
    global.progression_announcement_queue = [];
}

function progression_announcement_ensure()
{
    if (!variable_global_exists("progression_announcement_queue")
    || !is_array(global.progression_announcement_queue))
    {
        progression_announcement_reset();
    }

    return global.progression_announcement_queue;
}

function progression_queue_announcement(
    _heading,
    _title,
    _reward_lines = undefined,
    _followup_hint = ""
)
{
    var reward_lines = is_array(_reward_lines) ? _reward_lines : [];
    var queue = progression_announcement_ensure();
    array_push(
        queue,
        {
            heading: _heading,
            title: _title,
            reward_lines: reward_lines,
            followup_hint: _followup_hint
        }
    );
    global.progression_announcement_queue = queue;
}

function progression_queue_task_started(_task_id, _followup_hint = "")
{
    progression_queue_announcement(
        "TASK STARTED",
        task_get_definition(_task_id).title,
        [],
        _followup_hint
    );
}

function progression_queue_task_completed(_task_id, _followup_hint = "")
{
    var definition = task_get_definition(_task_id);
    progression_queue_announcement(
        "TASK COMPLETE",
        definition.title,
        definition.reward_labels,
        _followup_hint
    );
}

function progression_queue_quest_notice(
    _heading,
    _quest_id,
    _show_rewards = false,
    _followup_hint = ""
)
{
    var definition = quest_get_definition(_quest_id);
    progression_queue_announcement(
        _heading,
        definition.title,
        _show_rewards ? definition.rewards : [],
        _followup_hint
    );
}

function progression_update_announcements()
{
    var queue = progression_announcement_ensure();

    if (array_length(queue) == 0
    || instance_exists(obj_task_board_menu)
    || instance_exists(obj_quest_menu)
    || instance_exists(obj_inventory_menu)
    || instance_exists(obj_finished_crafts_menu)
    || instance_exists(obj_pause_menu)
    || instance_exists(obj_gui_quest_notice)
    || dialogue_is_active())
    {
        return false;
    }

    var announcement = queue[0];
    var remaining = [];
    for (var queue_index = 1;
        queue_index < array_length(queue);
        queue_index++)
    {
        array_push(remaining, queue[queue_index]);
    }
    global.progression_announcement_queue = remaining;

    var notice = instance_create_depth(
        0,
        0,
        -1400,
        obj_gui_quest_notice
    );
    notice.notice_heading = announcement.heading;
    notice.quest_title = announcement.title;
    notice.reward_lines = announcement.reward_lines;
    notice.age = 0;
    notice.life = notice.life_max;

    if (announcement.followup_hint != "")
    {
        notification_show_hint(
            announcement.followup_hint,
            game_get_speed(gamespeed_fps) * 6,
            false
        );
    }

    return true;
}

function progression_set_tutorial_stage(_game_state, _stage)
{
    if (!tutorial_stage_is_valid(_stage)) return false;
    _game_state.tutorial_stage = _stage;
    return true;
}

function progression_set_quest_status(_game_state, _quest_id, _status)
{
    if (_quest_id < 0
    || _quest_id >= QuestId.COUNT
    || !quest_status_is_valid(_status))
    {
        return false;
    }

    _game_state.quest_statuses[_quest_id] = _status;
    return true;
}

function progression_finish_farmer_intro()
{
    var game_state = game_state_ensure();
    if (game_state.tutorial_stage != TutorialStage.TALK_TO_FARMER)
        return false;

    progression_set_tutorial_stage(
        game_state,
        TutorialStage.TALK_TO_FARMERS_WIFE
    );
    game_state.quest_statuses[QuestId.FIRM_FOUNDATION] =
        QuestStatus.ACTIVE;
    quest_show_notice("QUEST STARTED", QuestId.FIRM_FOUNDATION);
    return true;
}

function task_board_begin_first_assignment()
{
    var game_state = game_state_ensure();

    if (game_state.tutorial_stage != TutorialStage.TALK_TO_FARMERS_WIFE
    || game_state.tutorial_board_assignment_pending
    || game_state.task_statuses[TaskId.FIELDSTONE_BY_HAND]
        != TaskStatus.LOCKED)
    {
        return false;
    }

    game_state.tutorial_board_assignment_pending = true;
    game_state.task_board_unlocked = true;
    game_state.task_statuses[TaskId.FIELDSTONE_BY_HAND] =
        TaskStatus.AVAILABLE;
    return true;
}

function task_board_unlock()
{
    game_state_ensure().task_board_unlocked = true;
    return true;
}

function progression_accept_task_state(_task_id, _game_state)
{
    task_state_ensure(_game_state);

    if (!_game_state.task_board_unlocked
    || _task_id < 0
    || _task_id >= TaskId.COUNT
    || _game_state.task_statuses[_task_id] != TaskStatus.AVAILABLE
    || task_get_active_id(_game_state) >= 0)
    {
        return false;
    }

    switch (_task_id)
    {
        case TaskId.FIELDSTONE_BY_HAND:
            if (_game_state.tutorial_stage
                != TutorialStage.TALK_TO_FARMERS_WIFE)
                return false;
            _game_state.tutorial_board_assignment_pending = false;
            progression_set_tutorial_stage(
                _game_state,
                TutorialStage.TRIP_ONE_HAND_FIELDSTONE
            );
            break;

        case TaskId.FALLEN_TREE:
            progression_set_tutorial_stage(
                _game_state,
                TutorialStage.CHOP_TREE
            );
            break;

        case TaskId.STONE_HAUL:
            progression_set_tutorial_stage(
                _game_state,
                TutorialStage.TRIP_TWO_VEHICLE_FIELDSTONE
            );
            break;

        case TaskId.FIT_THE_WINCH:
            progression_set_tutorial_stage(
                _game_state,
                _game_state.winch_attachment_state
                    == AttachmentState.MAIL_READY
                        ? TutorialStage.WINCH_PACKAGE_READY
                        : TutorialStage.WINCH_INSTALL_REQUIRED
            );
            break;

        case TaskId.TIMBER_DELIVERY:
            if (_game_state.winch_attachment_state
                != AttachmentState.INSTALLED)
                return false;
            progression_set_tutorial_stage(
                _game_state,
                TutorialStage.INSPECT_FIRST_LOG
            );
            break;

        case TaskId.PLACE_CABIN:
            if (!_game_state.cabin_placement_unlocked
            || !_game_state.cabin_site_placed
            || !_game_state.cabin_fence_marked
            || _game_state.cabin_built)
                return false;
            break;

        case TaskId.PARK_SKIDSTEER:
            if (_game_state.tutorial_stage != TutorialStage.COMPLETE
            || !_game_state.cabin_placement_unlocked)
                return false;
            _game_state.skidsteer_parked = false;
            break;

        case TaskId.MARK_CABIN_SITE:
            if (!_game_state.cabin_placement_unlocked
            || !_game_state.skidsteer_parked
            || _game_state.cabin_built)
                return false;
            break;
    }

    _game_state.task_statuses[_task_id] = TaskStatus.ACTIVE;
    return true;
}

function progression_present_task_started(_task_id)
{
    var followup_hint = "";

    switch (_task_id)
    {
        case TaskId.FIELDSTONE_BY_HAND:
            tutorial_spawn_hand_fieldstones();
            followup_hint = "Gather 6 loose Fieldstones by hand.";
            break;

        case TaskId.FALLEN_TREE:
            followup_hint = "Find a standing tree and press E to chop it.";
            break;

        case TaskId.STONE_HAUL:
            followup_hint = "Crush 10 Fieldrocks and deliver all 16 Fieldstones.";
            break;

        case TaskId.FIT_THE_WINCH:
            room_reconcile_winch_package();
            followup_hint = "Collect the marked winch package.";
            break;

        case TaskId.TIMBER_DELIVERY:
            followup_hint = "Enter the skidsteer and drive to the marked log.";
            break;

        case TaskId.PLACE_CABIN:
            followup_hint = "Retrieve 4 Timber Planks from the Finished Crafts chest.";
            break;

        case TaskId.PARK_SKIDSTEER:
            followup_hint = "Return the skidsteer to the marked pad beside the Farmer, stop, and hop out.";
            break;

        case TaskId.MARK_CABIN_SITE:
            followup_hint = game_state_ensure().cabin_site_placed
                ? "Go to the cabin stakes and press E to plan the boundary."
                : "Press B to choose the cabin site, then mark its boundary.";
            break;
    }

    progression_queue_task_started(_task_id, followup_hint);
}

function task_start(_task_id)
{
    var game_state = game_state_ensure();
    if (!progression_accept_task_state(_task_id, game_state))
        return false;

    progression_present_task_started(_task_id);
    return true;
}

function progression_complete_task_state(_task_id, _game_state)
{
    if (_task_id < 0
    || _task_id >= TaskId.COUNT
    || _game_state.task_statuses[_task_id] != TaskStatus.ACTIVE)
    {
        return false;
    }

    _game_state.task_statuses[_task_id] = TaskStatus.COMPLETE;
    return true;
}

function task_complete(_task_id)
{
    return progression_complete_task_state(
        _task_id,
        game_state_ensure()
    );
}

function progression_complete_hand_gathering_state(_game_state)
{
    if (!task_is_active(TaskId.FIELDSTONE_BY_HAND, _game_state)
    || _game_state.tutorial_fieldstones_collected < 6
    || _game_state.tools.axe_owned)
    {
        return false;
    }

    _game_state.tools.axe_owned = true;
    return progression_complete_task_state(
        TaskId.FIELDSTONE_BY_HAND,
        _game_state
    );
}

function progression_collect_winch_package_state(_game_state)
{
    if (!task_is_active(TaskId.FIT_THE_WINCH, _game_state)
    || _game_state.winch_attachment_state != AttachmentState.MAIL_READY)
    {
        return false;
    }

    _game_state.winch_attachment_state = AttachmentState.STORED_AT_HOME;
    return progression_set_tutorial_stage(
        _game_state,
        TutorialStage.WINCH_INSTALL_REQUIRED
    );
}

function progression_install_winch_state(_game_state)
{
    if (!task_is_active(TaskId.FIT_THE_WINCH, _game_state)
    || _game_state.winch_attachment_state
        != AttachmentState.STORED_AT_HOME)
    {
        return false;
    }

    _game_state.winch_attachment_state = AttachmentState.INSTALLED;
    return progression_complete_task_state(
        TaskId.FIT_THE_WINCH,
        _game_state
    );
}

function progression_record_cabin_site_state(
    _game_state,
    _room_name,
    _x,
    _y,
    _relocating = false
)
{
    var can_relocate = _relocating
        && _game_state.cabin_site_placed
        && task_is_active(TaskId.MARK_CABIN_SITE, _game_state)
        && !_game_state.cabin_fence_marked;

    if (!_game_state.cabin_placement_unlocked
    || (!can_relocate
        && !task_is_active(TaskId.MARK_CABIN_SITE, _game_state))
    || (_game_state.cabin_site_placed && !can_relocate))
    {
        return false;
    }

    _game_state.cabin_site_placed = true;
    _game_state.cabin_site_room = _room_name;
    _game_state.cabin_site_x = _x;
    _game_state.cabin_site_y = _y;
    _game_state.cabin_fence_marked = false;
    _game_state.cabin_built = false;
    _game_state.homestead_stage = HomesteadStage.TUTORIAL;

    return true;
}

function progression_complete_skidsteer_parking_state(_game_state)
{
    if (!task_is_active(TaskId.PARK_SKIDSTEER, _game_state))
        return false;

    _game_state.skidsteer_parked = true;
    return progression_complete_task_state(
        TaskId.PARK_SKIDSTEER,
        _game_state
    );
}

function progression_complete_cabin_fence_state(_game_state)
{
    if (!task_is_active(TaskId.MARK_CABIN_SITE, _game_state)
    || !_game_state.cabin_site_placed
    || _game_state.cabin_built)
    {
        return false;
    }

    _game_state.cabin_fence_marked = true;
    return progression_complete_task_state(
        TaskId.MARK_CABIN_SITE,
        _game_state
    );
}

function progression_build_cabin_state(_game_state)
{
    if (!task_is_active(TaskId.PLACE_CABIN, _game_state)
    || !_game_state.cabin_site_placed
    || !_game_state.cabin_fence_marked
    || _game_state.cabin_built
    || inventory_get_amount(
        _game_state.player_inventory,
        ResourceId.TIMBER_PLANK
    ) < CABIN_TIMBER_PLANK_COST)
    {
        return false;
    }

    inventory_remove(
        _game_state.player_inventory,
        ResourceId.TIMBER_PLANK,
        CABIN_TIMBER_PLANK_COST
    );
    _game_state.cabin_built = true;
    _game_state.homestead_stage = HomesteadStage.FIRST_REST_REQUIRED;
    return progression_complete_task_state(
        TaskId.PLACE_CABIN,
        _game_state
    );
}

function progression_open_homestead_hub_state(_game_state)
{
    if (_game_state.homestead_stage
        != HomesteadStage.FIRST_REST_REQUIRED
    || !_game_state.cabin_built
    || _game_state.task_statuses[TaskId.PLACE_CABIN]
        != TaskStatus.CLAIMED)
    {
        return false;
    }

    _game_state.homestead_stage = HomesteadStage.HUB_OPEN;
    _game_state.first_hub_hint_pending = true;
    return true;
}

function progression_make_task_available(_task_id, _game_state)
{
    if (_task_id < 0
    || _task_id >= TaskId.COUNT
    || _game_state.task_statuses[_task_id] != TaskStatus.LOCKED)
    {
        return false;
    }

    _game_state.task_statuses[_task_id] = TaskStatus.AVAILABLE;
    return true;
}

function progression_apply_task_claim_effects(_task_id, _game_state)
{
    switch (_task_id)
    {
        case TaskId.FIELDSTONE_BY_HAND:
            progression_make_task_available(
                TaskId.FALLEN_TREE,
                _game_state
            );
            break;

        case TaskId.FALLEN_TREE:
            progression_make_task_available(
                TaskId.STONE_HAUL,
                _game_state
            );
            break;

        case TaskId.STONE_HAUL:
            if (_game_state.winch_attachment_state
                == AttachmentState.LOCKED)
            {
                _game_state.winch_attachment_state =
                    AttachmentState.MAIL_READY;
            }
            progression_make_task_available(
                TaskId.FIT_THE_WINCH,
                _game_state
            );
            break;

        case TaskId.FIT_THE_WINCH:
            progression_make_task_available(
                TaskId.TIMBER_DELIVERY,
                _game_state
            );
            break;

        case TaskId.TIMBER_DELIVERY:
            _game_state.quest_statuses[QuestId.FIRM_FOUNDATION] =
                QuestStatus.COMPLETE;
            _game_state.quest_statuses[QuestId.PLACE_OF_YOUR_OWN] =
                QuestStatus.ACTIVE;
            _game_state.cabin_placement_unlocked = true;
            progression_make_task_available(
                TaskId.PARK_SKIDSTEER,
                _game_state
            );
            break;

        case TaskId.PARK_SKIDSTEER:
            progression_make_task_available(
                TaskId.MARK_CABIN_SITE,
                _game_state
            );
            break;

        case TaskId.MARK_CABIN_SITE:
            progression_make_task_available(
                TaskId.PLACE_CABIN,
                _game_state
            );
            break;

        case TaskId.PLACE_CABIN:
            _game_state.quest_statuses[QuestId.PLACE_OF_YOUR_OWN] =
                QuestStatus.COMPLETE;
            break;
    }
}

function progression_present_task_claimed(_task_id)
{
    // The board may claim one task and accept the next before closing.
    // Keep completion banners free of "accept next" hints that could already
    // be stale by the time the queued presentation reaches the world.
    progression_queue_task_completed(_task_id);

    switch (_task_id)
    {
        case TaskId.TIMBER_DELIVERY:
            progression_queue_quest_notice(
                "QUEST COMPLETED",
                QuestId.FIRM_FOUNDATION,
                true
            );
            progression_queue_quest_notice(
                "QUEST STARTED",
                QuestId.PLACE_OF_YOUR_OWN
            );
            break;

        case TaskId.PLACE_CABIN:
            progression_queue_quest_notice(
                "QUEST COMPLETED",
                QuestId.PLACE_OF_YOUR_OWN,
                true
            );
            break;
    }
}

function progression_claim_task_state(_task_id, _game_state)
{
    if (_task_id < 0
    || _task_id >= TaskId.COUNT
    || _game_state.task_statuses[_task_id] != TaskStatus.COMPLETE)
    {
        return false;
    }

    var rewards = task_get_definition(_task_id).rewards;
    if (!task_apply_rewards_atomically(rewards, _game_state))
        return false;

    _game_state.task_statuses[_task_id] = TaskStatus.CLAIMED;
    progression_apply_task_claim_effects(_task_id, _game_state);
    return true;
}

function task_claim_reward(_task_id)
{
    var game_state = game_state_ensure();
    if (!progression_claim_task_state(_task_id, game_state))
        return false;

    progression_present_task_claimed(_task_id);
    return true;
}

function progression_restore_stowed_winch_state(_game_state)
{
    if (_game_state.tutorial_stage
        == TutorialStage.ATTACH_CABLE_TO_LOG)
    {
        progression_set_tutorial_stage(
            _game_state,
            TutorialStage.TAKE_WINCH_CABLE
        );
        return true;
    }

    return false;
}

/// Compatibility path for a version-one save captured on the final page of
/// the old stump-delivery dialogue.
function progression_unlock_cabin_from_legacy_dialogue()
{
    var game_state = game_state_ensure();
    game_state.cabin_placement_unlocked = true;
    progression_set_quest_status(
        game_state,
        QuestId.FIRM_FOUNDATION,
        QuestStatus.COMPLETE
    );
    progression_set_quest_status(
        game_state,
        QuestId.PLACE_OF_YOUR_OWN,
        QuestStatus.ACTIVE
    );
    progression_make_task_available(TaskId.PARK_SKIDSTEER, game_state);
    notification_show_hint(
        "Cabin work unlocked. Accept Park the Skidsteer at the Task Board.",
        game_get_speed(gamespeed_fps) * 6,
        false
    );
    save_write();
    return true;
}
