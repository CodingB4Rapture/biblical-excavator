/// obj_fence_planning_controller - Create Event

planning_room_name = room_get_name(room);
var game_state = game_state_ensure();
planned_records = fence_records_for_room(
    game_state.fence_records,
    planning_room_name
);
outside_gate_count = fence_count_gates_outside_room(
    game_state.fence_records,
    planning_room_name
);
gate_mode = false;
anchor_set = false;
anchor_x = 0;
anchor_y = 0;
preview_x = fence_grid_size() * 0.5;
preview_y = fence_grid_size() * 0.5;
preview_in_room = true;
preview_records = [];
input_lock_frames = 2;
layout_status = fence_layout_status(planned_records, outside_gate_count);
status_message = "Click the first corner of a rectangular enclosure.";
placement_result = {
    valid: true,
    message: "",
    records: planned_records,
    gate_x: preview_x,
    gate_y: preview_y
};

fence_refresh_room_instances(
    planned_records,
    true,
    layout_status.valid
);
