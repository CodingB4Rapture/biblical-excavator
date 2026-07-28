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
        && rail.skills_right - rail.skills_left
            == sprite_get_width(spr_skills_button)
        && rail.map_right - rail.map_left
            == sprite_get_width(spr_map_button)
        && rail.build_right - rail.build_left
            == sprite_get_width(spr_build_button)
        && rail.inventory_top > rail.quest_bottom
        && rail.skills_top > rail.inventory_bottom
        && rail.map_top > rail.skills_bottom
        && rail.build_top > rail.map_bottom,
        "the rail gives all five authored sprites separate padded hitboxes"
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

    var viewport_sizes = [
        {width: 1280, height: 720},
        {width: 1100, height: 984},
        {width: 1920, height: 1080}
    ];
    var safe_layouts = true;
    for (var viewport_index = 0;
        viewport_index < array_length(viewport_sizes);
        viewport_index++)
    {
        var viewport = viewport_sizes[viewport_index];
        var viewport_rail = player_menu_get_rail_layout(
            viewport.width,
            viewport.height
        );
        var viewport_calendar = calendar_get_status_layout(
            viewport.width,
            viewport.height
        );
        safe_layouts = safe_layouts
            && viewport_calendar.right == viewport.width - 14
            && viewport_calendar.top == 14
            && viewport_calendar.left > viewport_rail.rail_right;
    }
    passed = player_menu_test_expect(
        safe_layouts,
        "the calendar safe area holds at 1280x720, 1100x984, and 1920x1080"
    ) && passed;

    var dialogue_sample =
        "A wrapped notification remains readable while this dialogue page is visible.";
    var dialogue_wide = dialogue_get_layout(
        dialogue_sample,
        1280,
        720
    );
    var dialogue_tall = dialogue_get_layout(
        dialogue_sample,
        1100,
        984
    );
    var dialogue_hd = dialogue_get_layout(
        dialogue_sample,
        1920,
        1080
    );
    passed = player_menu_test_expect(
        dialogue_wide.panel_left >= 22
        && dialogue_wide.panel_right <= 1258
        && dialogue_tall.panel_left >= 22
        && dialogue_tall.panel_right <= 1078
        && dialogue_hd.panel_left >= 22
        && dialogue_hd.panel_right <= 1898
        && dialogue_wide.body_line_sep
            == font_get_size(dialogue_font) + 10
        && dialogue_tall.body_scale >= 0.7
        && dialogue_hd.body_scale >= 0.7,
        "dialogue wrapping and line spacing stay inside all target viewports"
    ) && passed;

    var closed_model = player_menu_build_read_model(false, false, false);
    var quest_model = player_menu_build_read_model(true, false, false);
    var inventory_model = player_menu_build_read_model(false, true, false);
    var map_model = player_menu_build_read_model(false, false, true);
    var build_model = player_menu_build_read_model(
        false,
        false,
        false,
        true
    );
    var skills_model = player_menu_build_read_model(
        false,
        false,
        false,
        false,
        true
    );
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
        && map_model.map_frame == 1
        && build_model.build_frame == 1
        && build_model.quest_frame == 0,
        "button frames derive from the active menu without durable state"
    ) && passed;

    passed = player_menu_test_expect(
        skills_model.skills_frame == 1
        && skills_model.quest_frame == 0
        && skills_model.inventory_frame == 0
        && skills_model.map_frame == 0
        && skills_model.build_frame == 0,
        "the authored Skills button derives its selected frame from the live menu"
    ) && passed;

    passed = player_menu_test_expect(
        input_move_down_from_state(true, false, false)
        && !input_move_down_from_state(true, false, true)
        && input_move_down_from_state(false, true, true)
        && !player_menu_skills_shortcut_from_state(false, true)
        && player_menu_skills_shortcut_from_state(true, true),
        "Shift+S opens Skills without stealing downward movement"
    ) && passed;

    var skills_state = game_state_create_default();
    skill_award_xp_state(
        skills_state,
        SkillId.WOODWORK,
        100
    );
    var skills_read_model = skill_get_read_model(
        SkillId.WOODWORK,
        skills_state
    );
    passed = player_menu_test_expect(
        skills_read_model.name == "Woodwork"
        && skills_read_model.max_level == 50
        && skills_read_model.level == 2
        && skills_read_model.xp == 100
        && skills_read_model.progress == 0,
        "the Skills menu reads level and XP without owning durable state"
    ) && passed;

    var equipment_read_model = skill_get_read_model(
        SkillId.HEAVY_EQUIPMENT,
        game_state_create_default()
    );
    passed = player_menu_test_expect(
        !is_undefined(equipment_read_model.next_unlock)
        && equipment_read_model.next_unlock.level == 2
        && equipment_read_model.next_unlock.title
            == "Utility Vehicle Winches",
        "the Skills menu previews the next authored skill unlock"
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

    var edge_camera = camera_centered_view_origin(0, 0, 480, 240);
    passed = player_menu_test_expect(
        edge_camera.x == -240
        && edge_camera.y == -120,
        "gameplay camera centers its subject beyond the authored room edge"
    ) && passed;

    var vehicle_boundary = skidsteer_room_boundary_status(
        -20,
        740,
        12,
        11,
        10,
        9,
        1280,
        720
    );
    passed = player_menu_test_expect(
        vehicle_boundary.x == 12
        && vehicle_boundary.y == 710
        && vehicle_boundary.clipped_x
        && vehicle_boundary.clipped_y,
        "the skidsteer collision mask remains fully inside the room"
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

    var click_state = game_state_create_default();
    click_state.cabin_site_placed = true;
    click_state.task_statuses[TaskId.BUILD_CABIN_FENCE] =
        TaskStatus.ACTIVE;
    inventory_add(
        click_state.home_inventory,
        ResourceId.TIMBER_LOG,
        1
    );
    var click_menu = {
        recipe_ids: [
            ProductionRecipeId.SAW_TIMBER_PLANKS,
            ProductionRecipeId.CUT_STRAIGHT_FENCE
        ],
        selected_row: -1,
        selected_batches: 1,
        message: ""
    };
    var first_click = production_menu_toggle_row(
        click_menu,
        0,
        click_state
    );
    var locked_selection = click_menu.selected_row == 0;
    var second_click = production_menu_toggle_row(
        click_menu,
        0,
        click_state
    );
    passed = player_menu_test_expect(
        first_click
        && locked_selection
        && second_click
        && click_menu.selected_row == -1,
        "workshop recipes select and deselect only through an explicit toggle"
    ) && passed;

    show_debug_message(
        passed ? "MENU TEST RESULT: PASS" : "MENU TEST RESULT: FAIL"
    );
    return passed;
}
