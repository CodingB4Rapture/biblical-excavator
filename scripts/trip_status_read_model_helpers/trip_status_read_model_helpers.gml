/// Read-only Current Trip/Objective descriptors.
/// Progression remains owned by commands; the HUD only asks what to present.

function trip_status_make_read_model(
    _label,
    _objective,
    _numbered_trip = false
)
{
    return {
        heading: _numbered_trip
            ? "Current Trip - " + _label
            : _label,
        objective: _objective
    };
}

function trip_status_get_tutorial_read_model(_game_state)
{
    var model = trip_status_make_read_model(
        "Before Trip 1",
        "Talk to the Farmer"
    );

    switch (_game_state.tutorial_stage)
    {
        case TutorialStage.TALK_TO_FARMERS_WIFE:
            model.objective = "Talk to Farmer's Wife";
            break;

        case TutorialStage.TRIP_ONE_HAND_FIELDSTONE:
            model = trip_status_make_read_model(
                "Trip 1 of 3",
                "Collect 6 Fieldstones by hand ("
                    + string(_game_state.tutorial_fieldstones_collected)
                    + "/6)",
                true
            );
            break;

        case TutorialStage.CHOP_TREE:
            model = trip_status_make_read_model(
                "Axe Work",
                "Use the gifted axe on a standing tree"
            );
            break;

        case TutorialStage.INSPECT_FALLEN_TREE:
            model = trip_status_make_read_model(
                "Axe Work",
                "Inspect the fallen tree and stump"
            );
            break;

        case TutorialStage.TRIP_TWO_VEHICLE_FIELDSTONE:
            model = trip_status_make_read_model(
                "Trip 2 of 3",
                "Crush 10 Fieldrocks, then deliver all 16 Fieldstones",
                true
            );
            break;

        case TutorialStage.WINCH_PACKAGE_READY:
            model = trip_status_make_read_model(
                "Winch Setup",
                "Collect the winch package"
            );
            break;

        case TutorialStage.WINCH_INSTALL_REQUIRED:
            model = trip_status_make_read_model(
                "Winch Setup",
                "Install the winch on the skidsteer"
            );
            break;

        case TutorialStage.INSPECT_FIRST_LOG:
            model = trip_status_make_read_model(
                "Log Recovery",
                "Inspect the large log"
            );
            break;

        case TutorialStage.TAKE_WINCH_CABLE:
            model = trip_status_make_read_model(
                "Log Recovery",
                "Take the cable from the rear hitch"
            );
            break;

        case TutorialStage.ATTACH_CABLE_TO_LOG:
            model = trip_status_make_read_model(
                "Log Recovery",
                "Attach the cable to the log"
            );
            break;

        case TutorialStage.HAUL_FIRST_LOG:
            model = trip_status_make_read_model(
                "Trip 3 of 3",
                "Winch the log to Home Delivery",
                true
            );
            break;

        case TutorialStage.PULL_STUMP:
            model = trip_status_make_read_model(
                "Stump Recovery",
                "Winch the stump to Home Delivery for Small Lumber"
            );
            break;

        case TutorialStage.COMPLETE:
            model = trip_status_make_read_model(
                "Tutorial Complete",
                "Cabin materials delivered"
            );
            break;
    }

    return model;
}

function trip_status_get_read_model(_game_state, _vehicle, _pocket_planks)
{
    var model = trip_status_get_tutorial_read_model(_game_state);

    if (task_is_active(TaskId.PARK_SKIDSTEER, _game_state))
    {
        model = trip_status_make_read_model(
            "Cabin Work",
            instance_exists(_vehicle) && _vehicle.has_driver
                ? "Park fully inside the marked pad, stop, detach any tow, and exit"
                : "Get in the skidsteer and drive it to the marked parking pad"
        );
    }
    else if (task_is_active(TaskId.MARK_CABIN_SITE, _game_state))
    {
        model = trip_status_make_read_model(
            "Cabin Site",
            _game_state.cabin_site_placed
                ? (cabin_site_flag_count_taken(_game_state) > 0
                    ? "Return to the cleared flag and press E to Place Fence"
                    : "Take one of the selected site's corner flags")
                : "Press B to choose one marked site; taking a flag commits the location"
        );
    }
    else if (task_is_active(TaskId.PLACE_CABIN, _game_state))
    {
        model = trip_status_make_read_model(
            "Cabin Build",
            _pocket_planks < CABIN_TIMBER_PLANK_COST
                ? "Retrieve 4 Timber Planks from the Finished Crafts chest ("
                    + string(_pocket_planks) + "/"
                    + string(CABIN_TIMBER_PLANK_COST) + ")"
                : "Take the 4 Timber Planks to the marked cabin site and press E"
        );
    }
    else if (_game_state.homestead_stage
        == HomesteadStage.FIRST_REST_REQUIRED)
    {
        model = trip_status_make_read_model(
            "Cabin Site",
            "Rest at the cabin site to begin morning"
        );
    }
    else if (_game_state.homestead_stage == HomesteadStage.HUB_OPEN
    && _game_state.tutorial_stage == TutorialStage.COMPLETE)
    {
        model = trip_status_make_read_model(
            "Homestead Day " + string(_game_state.day_number),
            "Homestead work can begin"
        );
    }

    return model;
}
