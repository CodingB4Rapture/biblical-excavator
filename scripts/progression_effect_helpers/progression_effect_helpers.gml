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
            return "Retrieve 4 Timber Planks from the Finished Crafts chest.";

        case TaskId.PARK_SKIDSTEER:
            return "Return the skidsteer to the marked pad beside the Farmer, stop, and hop out.";

        case TaskId.MARK_CABIN_SITE:
            return _game_state.cabin_site_placed
                ? "Go to the cabin stakes and press E to plan the boundary."
                : "Press B to choose the cabin site, then mark its boundary.";
    }

    return "";
}
