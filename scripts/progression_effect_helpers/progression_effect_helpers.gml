/// Explicit world effects and follow-up read models for progression commands.

function progression_apply_task_start_effects(_task_id)
{
    switch (_task_id)
    {
        case TaskId.FIELDSTONE_BY_HAND:
            tutorial_spawn_hand_fieldstones();
            return true;

        case TaskId.FIT_THE_WINCH:
            room_reconcile_winch_package();
            return true;

        case TaskId.MARK_CABIN_SITE:
            // The fixed-site flow begins at the authored flags. Create them
            // when the task is accepted so the objective is immediately
            // actionable; B remains a recovery shortcut if they are missing.
            cabin_restore_predefined_flags();
            return true;
    }

    return false;
}

function progression_task_start_followup(_task_id, _game_state)
{
    switch (_task_id)
    {
        case TaskId.FIELDSTONE_BY_HAND:
            return "Gather 6 loose Fieldstones by hand.";

        case TaskId.FALLEN_TREE:
            return "Find a standing tree and press E to chop it.";

        case TaskId.STONE_HAUL:
            return "Crush 10 Fieldrocks and deliver all 16 Fieldstones.";

        case TaskId.FIT_THE_WINCH:
            return "Collect the marked winch package.";

        case TaskId.TIMBER_DELIVERY:
            return "Enter the skidsteer and drive to the marked log.";

        case TaskId.PLACE_CABIN:
            return "Go to the selected site and raise the cabin inside its completed boundary.";

        case TaskId.PARK_SKIDSTEER:
            return "Return the skidsteer to the marked pad beside the Farmer, stop, and hop out.";

        case TaskId.MARK_CABIN_SITE:
            return "Choose Site I or Site II. Taking one flag commits that site.";

        case TaskId.BUILD_CABIN_FENCE:
            return "Use the sawmill, retrieve each finished fence piece, then press B to fill the site silhouette.";
    }

    return "";
}
