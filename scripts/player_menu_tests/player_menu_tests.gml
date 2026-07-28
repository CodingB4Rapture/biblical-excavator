/// Deterministic menu-rail, shared-layout, and trip-status regression coverage.

function player_menu_test_expect(_condition, _message)
{
    if (_condition)
    {
        show_debug_message("MENU TEST PASS: " + _message);
        return true;
    }

    show_debug_message("MENU TEST FAIL: " + _message);
    return false;
}

function player_menu_run_tests()
{
    var passed = true;
    var rail = player_menu_get_rail_layout(1280, 720);
    var quest_layout = player_menu_get_quest_layout(1280, 720);
    var inventory_layout = player_menu_get_inventory_layout(1280, 720);

    passed = player_menu_test_expect(
        rail.quest_right - rail.quest_left
            == sprite_get_width(spr_quest_button)
        && rail.inventory_right - rail.inventory_left
            == sprite_get_width(spr_inventory_button)
        && rail.map_right - rail.map_left
            == sprite_get_width(spr_map_button)
        && rail.inventory_top > rail.quest_bottom
        && rail.map_top > rail.inventory_bottom,
        "the rail gives all three authored sprites separate padded hitboxes"
    ) && passed;

    passed = player_menu_test_expect(
        quest_layout.panel_left > rail.quest_right
        && quest_layout.panel_left == inventory_layout.panel_left
        && quest_layout.panel_right == inventory_layout.panel_right,
        "Quest and Inventory reserve the same left rail inset"
    ) && passed;

    var calendar_layout = calendar_get_status_layout(1280, 720);
    passed = player_menu_test_expect(
        calendar_layout.right == 1266
        && calendar_layout.top == 14
        && calendar_layout.left > rail.rail_right,
        "the calendar card stays top-right and clear of the menu rail"
    ) && passed;

    var closed_model = player_menu_build_read_model(false, false, false);
    var quest_model = player_menu_build_read_model(true, false, false);
    var inventory_model = player_menu_build_read_model(false, true, false);
    var map_model = player_menu_build_read_model(false, false, true);
    passed = player_menu_test_expect(
        closed_model.quest_frame == 0
        && closed_model.inventory_frame == 0
        && closed_model.map_frame == 0
        && quest_model.quest_frame == 1
        && quest_model.inventory_frame == 0
        && inventory_model.quest_frame == 0
        && inventory_model.inventory_frame == 1
        && map_model.quest_frame == 0
        && map_model.inventory_frame == 0
        && map_model.map_frame == 1,
        "button frames derive from the active menu without durable state"
    ) && passed;

    var map_layout = map_get_layout(1280, 720, 1280, 720);
    var map_top_left = map_world_to_gui(0, 0, map_layout);
    var map_bottom_right = map_world_to_gui(
        1280,
        720,
        map_layout
    );
    passed = player_menu_test_expect(
        abs(map_layout.map_width / map_layout.map_height - 16 / 9)
            < 0.001
        && map_top_left.x == map_layout.map_left
        && map_top_left.y == map_layout.map_top
        && map_bottom_right.x == map_layout.map_right
        && map_bottom_right.y == map_layout.map_bottom,
        "the overview preserves room aspect and projects both world corners"
    ) && passed;

    var stage_state = {tutorial_stage: TutorialStage.WINCH_PACKAGE_READY};
    var winch_model = trip_status_get_tutorial_read_model(stage_state);
    stage_state.tutorial_stage = TutorialStage.INSPECT_FIRST_LOG;
    var log_model = trip_status_get_tutorial_read_model(stage_state);
    stage_state.tutorial_stage = TutorialStage.HAUL_FIRST_LOG;
    var third_trip_model = trip_status_get_tutorial_read_model(stage_state);
    stage_state.tutorial_stage = TutorialStage.PULL_STUMP;
    var stump_model = trip_status_get_tutorial_read_model(stage_state);

    passed = player_menu_test_expect(
        winch_model.heading == "Winch Setup"
        && log_model.heading == "Log Recovery"
        && third_trip_model.heading == "Current Trip - Trip 3 of 3"
        && stump_model.heading == "Stump Recovery",
        "Trip 3 appears only during the actual log-haul trip"
    ) && passed;

    show_debug_message(
        passed ? "MENU TEST RESULT: PASS" : "MENU TEST RESULT: FAIL"
    );
    return passed;
}
