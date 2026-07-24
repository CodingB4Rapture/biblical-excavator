/// Deterministic fence regression coverage, invoked only with --fence-tests.

function fence_test_rectangle(
    _room_name,
    _min_x,
    _min_y,
    _width_steps,
    _height_steps
)
{
    return fence_make_rectangle_records(
        _room_name,
        _min_x,
        _min_y,
        _min_x + _width_steps * fence_grid_size(),
        _min_y + _height_steps * fence_grid_size()
    );
}

function fence_test_expect(_condition, _message)
{
    if (_condition)
    {
        show_debug_message("FENCE TEST PASS: " + _message);
        return true;
    }

    show_debug_message("FENCE TEST FAIL: " + _message);
    return false;
}

function fence_planning_run_tests()
{
    var failures = 0;
    var room_name = room_get_name(room);
    var grid = fence_grid_size();
    var min_x = 16;
    var min_y = 16;
    var max_x = min_x + grid * 4;
    var max_y = min_y + grid * 3;
    var target_rectangle = fence_test_rectangle(
        room_name,
        min_x,
        min_y,
        4,
        3
    );
    var rectangle_result = fence_try_add_rectangle(
        [],
        room_name,
        min_x,
        min_y,
        max_x,
        max_y
    );
    var rectangle = rectangle_result.records;

    if (!fence_test_expect(
        rectangle_result.valid
        && array_length(rectangle) == array_length(target_rectangle),
        "two-corner placement builds the complete rectangle"
    )) failures += 1;

    var overlap_result = fence_try_add_rectangle(
        rectangle,
        room_name,
        min_x + grid,
        min_y + grid,
        max_x + grid,
        max_y + grid
    );

    if (!fence_test_expect(
        !overlap_result.valid,
        "an overlapping rectangle is rejected"
    )) failures += 1;

    var rectangle_status = fence_layout_status(rectangle);

    if (!fence_test_expect(
        rectangle_status.valid,
        "closed rectangle validates"
    )) failures += 1;

    var top_left_index = fence_find_record(rectangle, min_x, min_y);
    var top_right_index = fence_find_record(rectangle, max_x, min_y);
    var bottom_left_index = fence_find_record(rectangle, min_x, max_y);
    var bottom_right_index = fence_find_record(rectangle, max_x, max_y);
    var top_straight_index = fence_find_record(rectangle, min_x + grid, min_y);
    var bottom_straight_index = fence_find_record(
        rectangle,
        min_x + grid,
        max_y
    );
    var left_straight_index = fence_find_record(rectangle, min_x, min_y + grid);
    var right_straight_index = fence_find_record(rectangle, max_x, min_y + grid);

    if (!fence_test_expect(
        fence_sprite_for_record(rectangle, top_left_index)
            == spr_top_left_fence_corner
        && fence_sprite_for_record(rectangle, top_right_index)
            == spr_top_right_fence_corner
        && fence_sprite_for_record(rectangle, bottom_left_index)
            == spr_left_fence_corner
        && fence_sprite_for_record(rectangle, bottom_right_index)
            == spr_right_fence_corner,
        "all four corners choose the correct sprites"
    )) failures += 1;

    if (!fence_test_expect(
        fence_sprite_for_record(rectangle, top_straight_index)
            == spr_back_fence
        && fence_sprite_for_record(rectangle, bottom_straight_index)
            == spr_front_fence
        && fence_sprite_for_record(rectangle, left_straight_index)
            == spr_leftside_fence
        && fence_sprite_for_record(rectangle, right_straight_index)
            == spr_rightside_fence,
        "straight sides choose north/east/south/west art"
    )) failures += 1;

    var l_shape = [
        fence_record_create(room_name, min_x, min_y),
        fence_record_create(room_name, min_x + grid, min_y),
        fence_record_create(room_name, min_x, min_y + grid)
    ];
    var l_corner_index = fence_find_record(l_shape, min_x, min_y);
    var corner_before_removal = fence_sprite_for_record(
        l_shape,
        l_corner_index
    );
    var l_removal = fence_remove_at(l_shape, min_x + grid, min_y);
    l_corner_index = fence_find_record(l_removal.records, min_x, min_y);
    var corner_after_removal = fence_sprite_for_record(
        l_removal.records,
        l_corner_index
    );

    if (!fence_test_expect(
        corner_before_removal == spr_top_left_fence_corner
        && corner_after_removal == spr_leftside_fence,
        "neighbor changes automatically update a corner"
    )) failures += 1;

    var removal = fence_remove_at(
        rectangle,
        min_x + grid * 2,
        min_y
    );

    if (!fence_test_expect(
        removal.removed
        && !fence_layout_status(removal.records).valid,
        "removal works and exposes a rejected loose end"
    )) failures += 1;

    var gate_result = fence_try_place_gate(
        rectangle,
        room_name,
        min_x + grid,
        max_y,
        0
    );
    var gate_status = fence_layout_status(gate_result.records);
    var gate_left_index = fence_find_record(
        gate_result.records,
        min_x + grid,
        max_y
    );
    var gate_right_index = fence_find_record(
        gate_result.records,
        min_x + grid * 2,
        max_y
    );

    if (!fence_test_expect(
        gate_result.valid
        && gate_status.valid
        && fence_record_gate_part(gate_result.records[gate_left_index])
            == FenceGatePart.LEFT
        && fence_record_gate_part(gate_result.records[gate_right_index])
            == FenceGatePart.RIGHT
        && fence_sprite_for_record(gate_result.records, gate_left_index)
            == spr_fence_gate
        && fence_sprite_for_record(gate_result.records, gate_right_index) == -1,
        "one two-cell horizontal gate validates and renders once"
    )) failures += 1;

    var second_gate = fence_try_place_gate(
        gate_result.records,
        room_name,
        min_x + grid * 3,
        max_y,
        0
    );

    if (!fence_test_expect(
        !second_gate.valid,
        "a second gate is rejected"
    )) failures += 1;

    var gate_removal = fence_remove_gate_at(
        gate_result.records,
        min_x + grid * 2,
        max_y
    );

    if (!fence_test_expect(
        gate_removal.removed
        && fence_count_gates(gate_removal.records) == 0
        && fence_layout_status(gate_removal.records).valid,
        "right-click gate removal restores the closed fence side"
    )) failures += 1;

    var enclosure_removal = fence_remove_enclosure_at(
        gate_result.records,
        min_x,
        min_y
    );

    if (!fence_test_expect(
        enclosure_removal.removed
        && array_length(enclosure_removal.records) == 0
        && fence_layout_status(enclosure_removal.records).valid,
        "right-click enclosure removal leaves no loose fragments"
    )) failures += 1;

    var t_junction = fence_try_place(
        rectangle,
        room_name,
        min_x + grid,
        min_y + grid,
        false
    );

    if (!fence_test_expect(
        !t_junction.valid,
        "a T-junction is rejected during placement"
    )) failures += 1;

    var crossing = [
        fence_record_create(room_name, 400, 400),
        fence_record_create(room_name, 400, 400 - grid),
        fence_record_create(room_name, 400 + grid, 400),
        fence_record_create(room_name, 400, 400 + grid),
        fence_record_create(room_name, 400 - grid, 400)
    ];

    if (!fence_test_expect(
        !fence_layout_status(crossing).valid,
        "a crossing is rejected"
    )) failures += 1;

    var loose_end = [fence_record_create(room_name, 400, 400)];

    if (!fence_test_expect(
        !fence_layout_status(loose_end).valid,
        "a loose end cannot be committed"
    )) failures += 1;

    var cabin_bounds = cabin_fence_plot_bounds_at(240, 240);
    var cabin_rectangle = fence_make_rectangle_records(
        room_name,
        cabin_bounds.min_x,
        cabin_bounds.min_y,
        cabin_bounds.max_x,
        cabin_bounds.max_y,
        FENCE_PURPOSE_CABIN_SITE
    );
    var cabin_gate = fence_try_place_gate(
        cabin_rectangle,
        room_name,
        cabin_bounds.min_x + grid,
        cabin_bounds.max_y,
        0,
        FENCE_PURPOSE_CABIN_SITE
    );
    var cabin_status = cabin_fence_plot_status(
        cabin_gate.records,
        room_name,
        cabin_bounds
    );
    var restored_cabin_records = fence_copy_records(
        json_parse(
            json_stringify({records: cabin_gate.records})
        ).records
    );

    if (!fence_test_expect(
        cabin_gate.valid
        && cabin_status.valid
        && cabin_fence_plot_status(
            restored_cabin_records,
            room_name,
            cabin_bounds
        ).valid
        && fence_record_purpose(restored_cabin_records[0])
            == FENCE_PURPOSE_CABIN_SITE,
        "the exact cabin boundary, front gate, and purpose survive save data"
    )) failures += 1;

    var back_gate = fence_try_place_gate(
        cabin_rectangle,
        room_name,
        cabin_bounds.min_x + grid,
        cabin_bounds.min_y,
        0,
        FENCE_PURPOSE_CABIN_SITE
    );

    if (!fence_test_expect(
        back_gate.valid
        && !cabin_fence_plot_status(
            back_gate.records,
            room_name,
            cabin_bounds
        ).valid,
        "the bounded cabin plot rejects a gate away from the front side"
    )) failures += 1;

    var encoded = json_stringify({fence_records: gate_result.records});
    var decoded = json_parse(encoded);
    var restored = fence_copy_records(decoded.fence_records);

    if (!fence_test_expect(
        array_length(restored) == array_length(gate_result.records)
        && fence_layout_status(restored).valid
        && fence_count_gates(restored) == 1,
        "fence records survive a save/load JSON round trip"
    )) failures += 1;

    var legacy_default = game_state_create_default();

    if (!fence_test_expect(
        array_length(legacy_default.fence_records) == 0
        && array_length(fence_copy_records(undefined)) == 0,
        "a legacy save with no fence field safely defaults to an empty plan"
    )) failures += 1;

    var game_state = game_state_ensure();
    var original_records = fence_copy_records(game_state.fence_records);
    game_state.fence_records = restored;
    var restored_piece_count = fence_restore_room();
    var expected_drawn_pieces = array_length(restored) - 1;

    if (!fence_test_expect(
        restored_piece_count == array_length(restored)
        && instance_number(obj_fence_piece) == expected_drawn_pieces,
        "room restoration rebuilds saved pieces and draws the gate once"
    )) failures += 1;

    game_state.fence_records = original_records;
    with (obj_fence_piece) instance_destroy();

    if (failures == 0)
    {
        show_debug_message("FENCE TEST RESULT: PASS");
        return true;
    }

    show_debug_message(
        "FENCE TEST RESULT: FAIL (" + string(failures) + " failures)"
    );
    return false;
}
