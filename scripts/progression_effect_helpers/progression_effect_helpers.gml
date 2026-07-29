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
            return "Loose Fieldstones can be gathered without machinery. Search the nearby ground.";

        case TaskId.FALLEN_TREE:
            return "Explore for a suitable standing tree. Its trunk and stump will matter later.";

        case TaskId.STONE_HAUL:
            return "The remaining foundation stone is too heavy by hand. Use the skidsteer in the rocky field.";

        case TaskId.FIT_THE_WINCH:
            return "The mailed attachment is waiting beside Home Delivery.";

        case TaskId.TIMBER_DELIVERY:
            return "The winch can recover the trunk and stump you inspected earlier.";

        case TaskId.PLACE_CABIN:
            return "The finished boundary is ready to become a home.";

        case TaskId.PARK_SKIDSTEER:
            return "Settle the heavy equipment before choosing where to build.";

        case TaskId.MARK_CABIN_SITE:
            return "Explore both surveyed sites. Taking one flag commits your choice.";

        case TaskId.BUILD_CABIN_FENCE:
            return "Turn the recovered timber into a safe boundary for the site you chose.";
    }

    return "";
}
