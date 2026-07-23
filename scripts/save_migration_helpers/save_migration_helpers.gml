/// Pure save-data migrations. These functions only transform plain structs.

#macro SAVE_FORMAT_CURRENT 3
#macro SAVE_V2_TASK_COUNT 6

function save_migrate_v1_to_v2(_data)
{
    if (!is_struct(_data)
    || !variable_struct_exists(_data, "game_state")
    || !is_struct(_data.game_state))
    {
        return undefined;
    }

    var saved_state = _data.game_state;

    if (!variable_struct_exists(saved_state, "tutorial_stage")
    || !tutorial_stage_is_valid(saved_state.tutorial_stage))
    {
        saved_state.tutorial_stage = TutorialStage.TALK_TO_FARMER;
    }

    if (!variable_struct_exists(
        saved_state,
        "tutorial_fieldstones_collected"
    ))
    {
        saved_state.tutorial_fieldstones_collected = 0;
    }

    if (!variable_struct_exists(saved_state, "trip_rocks_gathered"))
        saved_state.trip_rocks_gathered = 0;

    if (!variable_struct_exists(
        saved_state,
        "tutorial_fieldrocks_crushed"
    ))
    {
        var rank = tutorial_stage_rank(saved_state.tutorial_stage);
        saved_state.tutorial_fieldrocks_crushed = rank > 5
            ? 10
            : (
                rank == 5
                    ? clamp(
                        saved_state.trip_rocks_gathered
                            - saved_state.tutorial_fieldstones_collected,
                        0,
                        10
                    )
                    : 0
            );
    }

    if (!variable_struct_exists(
        saved_state,
        "tutorial_board_assignment_pending"
    ))
    {
        saved_state.tutorial_board_assignment_pending = false;
    }

    if (!variable_struct_exists(
        saved_state,
        "cabin_placement_unlocked"
    ))
    {
        saved_state.cabin_placement_unlocked =
            tutorial_stage_rank(saved_state.tutorial_stage) >= 13;
    }

    if (variable_struct_exists(saved_state, "winch_attachment_state")
    && saved_state.tutorial_stage == TutorialStage.WINCH_PACKAGE_READY
    && saved_state.winch_attachment_state == AttachmentState.STORED_AT_HOME)
    {
        saved_state.tutorial_stage =
            TutorialStage.WINCH_INSTALL_REQUIRED;
    }

    var migrated_cabin_placed = variable_struct_exists(
        saved_state,
        "cabin_site_placed"
    ) && saved_state.cabin_site_placed;
    var migrated_cabin_unlocked =
        saved_state.cabin_placement_unlocked;

    if (!variable_struct_exists(saved_state, "quest_statuses")
    || !is_array(saved_state.quest_statuses))
    {
        saved_state.quest_statuses =
            array_create(QuestId.COUNT, QuestStatus.LOCKED);
        saved_state.quest_statuses[QuestId.FIRM_FOUNDATION] =
            saved_state.tutorial_stage == TutorialStage.TALK_TO_FARMER
                ? QuestStatus.LOCKED
                : (
                    saved_state.tutorial_stage == TutorialStage.COMPLETE
                        ? QuestStatus.COMPLETE
                        : QuestStatus.ACTIVE
                );
        saved_state.quest_statuses[QuestId.PLACE_OF_YOUR_OWN] =
            migrated_cabin_placed
                ? QuestStatus.COMPLETE
                : (
                    migrated_cabin_unlocked
                        ? QuestStatus.ACTIVE
                        : QuestStatus.LOCKED
                );
    }

    while (array_length(saved_state.quest_statuses) < QuestId.COUNT)
    {
        array_push(
            saved_state.quest_statuses,
            migrated_cabin_placed
                ? QuestStatus.COMPLETE
                : (
                    migrated_cabin_unlocked
                    || saved_state.tutorial_stage
                        == TutorialStage.COMPLETE
                        ? QuestStatus.ACTIVE
                        : QuestStatus.LOCKED
                )
        );
    }

    // Version one allowed tutorial milestones to mirror several task states
    // at once. Normalize once into the v2 single-active-task invariant. Earlier
    // work is archived without granting newly balanced retroactive rewards.
    var legacy_rank = tutorial_stage_rank(saved_state.tutorial_stage);
    var current_task = -1;
    if (saved_state.tutorial_board_assignment_pending)
        current_task = TaskId.FIELDSTONE_BY_HAND;
    else if (legacy_rank == 2)
        current_task = TaskId.FIELDSTONE_BY_HAND;
    else if (legacy_rank >= 3 && legacy_rank <= 4)
        current_task = TaskId.FALLEN_TREE;
    else if (legacy_rank == 5)
        current_task = TaskId.STONE_HAUL;
    else if (legacy_rank >= 6 && legacy_rank <= 7)
        current_task = TaskId.FIT_THE_WINCH;
    else if (legacy_rank >= 8 && legacy_rank <= 12)
        current_task = TaskId.TIMBER_DELIVERY;
    else if (legacy_rank >= 13)
    {
        var has_cabin = variable_struct_exists(
            saved_state,
            "cabin_site_placed"
        ) && saved_state.cabin_site_placed;
        if (!has_cabin) current_task = TaskId.PLACE_CABIN;
    }

    saved_state.task_statuses =
        array_create(SAVE_V2_TASK_COUNT, TaskStatus.LOCKED);
    saved_state.task_board_unlocked = current_task >= 0
        || legacy_rank >= 2;
    if (current_task >= 0)
    {
        for (var prior_task = 0;
            prior_task < current_task;
            prior_task++)
        {
            saved_state.task_statuses[prior_task] = TaskStatus.CLAIMED;
        }
        saved_state.task_statuses[current_task] =
            saved_state.tutorial_board_assignment_pending
                ? TaskStatus.AVAILABLE
                : TaskStatus.ACTIVE;
    }
    else if (legacy_rank >= 13)
    {
        for (var archived_task = 0;
            archived_task < SAVE_V2_TASK_COUNT;
            archived_task++)
        {
            saved_state.task_statuses[archived_task] =
                TaskStatus.CLAIMED;
        }
    }

    if (!variable_struct_exists(_data, "scene")
    || !is_struct(_data.scene))
    {
        _data.scene = {};
    }

    var scene = _data.scene;
    if (!variable_struct_exists(scene, "dialogue_active"))
        scene.dialogue_active = false;
    if (!variable_struct_exists(scene, "dialogue_pages"))
        scene.dialogue_pages = [];
    if (!variable_struct_exists(scene, "dialogue_page_index"))
        scene.dialogue_page_index = 0;
    if (!variable_struct_exists(scene, "dialogue_speaker"))
        scene.dialogue_speaker = "";
    if (!variable_struct_exists(scene, "dialogue_style"))
        scene.dialogue_style = NotificationStyle.PROMPT;
    if (!variable_struct_exists(scene, "dialogue_completion_action"))
        scene.dialogue_completion_action = "";
    scene.dialogue_completion_action = dialogue_action_normalize(
        scene.dialogue_completion_action
    );

    if (!variable_struct_exists(_data, "settings")
    || !is_struct(_data.settings))
    {
        _data.settings = {
            master_volume: 1,
            fullscreen: false
        };
    }

    _data.format_version = 2;
    return _data;
}

function save_migrate_v2_to_v3(_data)
{
    if (!is_struct(_data)
    || !variable_struct_exists(_data, "game_state")
    || !is_struct(_data.game_state))
    {
        return undefined;
    }

    var saved_state = _data.game_state;
    var old_statuses = variable_struct_exists(saved_state, "task_statuses")
        && is_array(saved_state.task_statuses)
            ? saved_state.task_statuses
            : [];
    var new_statuses = array_create(TaskId.COUNT, TaskStatus.LOCKED);

    for (var old_task_id = 0;
        old_task_id < min(SAVE_V2_TASK_COUNT, array_length(old_statuses));
        old_task_id++)
    {
        var old_status = old_statuses[old_task_id];
        new_statuses[old_task_id] = task_status_is_valid(old_status)
            ? old_status
            : TaskStatus.LOCKED;
    }

    var cabin_placed = variable_struct_exists(
        saved_state,
        "cabin_site_placed"
    ) && saved_state.cabin_site_placed;
    var old_cabin_status = new_statuses[TaskId.PLACE_CABIN];

    if (cabin_placed)
    {
        // In v2, placing the site used the completed cabin art and was the end
        // of the arc. Preserve that finished state without making an existing
        // player repeat newly inserted tutorial tasks.
        saved_state.skidsteer_parked = true;
        saved_state.cabin_fence_marked = true;
        saved_state.cabin_built = true;
        new_statuses[TaskId.PARK_SKIDSTEER] = TaskStatus.CLAIMED;
        new_statuses[TaskId.MARK_CABIN_SITE] = TaskStatus.CLAIMED;
    }
    else
    {
        saved_state.skidsteer_parked = false;
        saved_state.cabin_fence_marked = false;
        saved_state.cabin_built = false;
        new_statuses[TaskId.PLACE_CABIN] = TaskStatus.LOCKED;

        var timber_claimed = new_statuses[TaskId.TIMBER_DELIVERY]
            == TaskStatus.CLAIMED;
        if (old_cabin_status == TaskStatus.ACTIVE)
        {
            new_statuses[TaskId.PARK_SKIDSTEER] = TaskStatus.ACTIVE;
        }
        else if (old_cabin_status >= TaskStatus.AVAILABLE
        || timber_claimed)
        {
            new_statuses[TaskId.PARK_SKIDSTEER] = TaskStatus.AVAILABLE;
        }
    }

    saved_state.task_statuses = new_statuses;
    _data.format_version = 3;
    return _data;
}

function save_migrate_to_current(_data)
{
    if (!is_struct(_data)
    || !variable_struct_exists(_data, "format_version")
    || !is_real(_data.format_version))
    {
        return undefined;
    }

    var safety = 0;
    while (_data.format_version < SAVE_FORMAT_CURRENT && safety < 8)
    {
        switch (_data.format_version)
        {
            case 1:
                _data = save_migrate_v1_to_v2(_data);
                break;

            case 2:
                _data = save_migrate_v2_to_v3(_data);
                break;

            default:
                return undefined;
        }

        if (is_undefined(_data)) return undefined;
        safety += 1;
    }

    if (_data.format_version != SAVE_FORMAT_CURRENT)
        return undefined;

    if (!variable_struct_exists(_data, "game_state")
    || !is_struct(_data.game_state))
    {
        return undefined;
    }
    if (!variable_struct_exists(_data, "scene")
    || !is_struct(_data.scene))
    {
        _data.scene = {};
    }
    if (!variable_struct_exists(_data, "settings")
    || !is_struct(_data.settings))
    {
        _data.settings = {};
    }

    var scene = _data.scene;
    if (!variable_struct_exists(scene, "dialogue_active"))
        scene.dialogue_active = false;
    if (!variable_struct_exists(scene, "dialogue_pages"))
        scene.dialogue_pages = [];
    if (!variable_struct_exists(scene, "dialogue_page_index"))
        scene.dialogue_page_index = 0;
    if (!variable_struct_exists(scene, "dialogue_speaker"))
        scene.dialogue_speaker = "";
    if (!variable_struct_exists(scene, "dialogue_completion_action"))
        scene.dialogue_completion_action = "";
    if (!variable_struct_exists(scene, "dialogue_style"))
        scene.dialogue_style = NotificationStyle.PROMPT;
    scene.dialogue_completion_action = dialogue_action_normalize(
        scene.dialogue_completion_action
    );

    return _data;
}
