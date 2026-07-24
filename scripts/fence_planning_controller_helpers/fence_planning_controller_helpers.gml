/// Orchestration helpers for the live fence-planning controller.
/// Keyboard and mouse polling remain in the object's Step event.

function fence_planning_controller_input_allowed()
{
    return !gameplay_is_paused()
        && !dialogue_is_active()
        && !instance_exists(obj_quest_menu)
        && !instance_exists(obj_inventory_menu)
        && !instance_exists(obj_pause_menu)
        && !instance_exists(obj_cabin_placement_controller);
}

function fence_planning_controller_refresh_layout(_controller)
{
    _controller.layout_status = _controller.cabin_tutorial_mode
        ? cabin_fence_plot_status(
            _controller.planned_records,
            _controller.planning_room_name,
            _controller.tutorial_bounds
        )
        : fence_layout_status(
            _controller.planned_records,
            _controller.outside_gate_count
        );
    return _controller.layout_status;
}

function fence_planning_controller_update_preview(
    _controller,
    _mouse_window_x,
    _mouse_window_y
)
{
    var active_camera = view_camera[0];
    var view_x = camera_get_view_x(active_camera);
    var view_y = camera_get_view_y(active_camera);
    var view_w = camera_get_view_width(active_camera);
    var view_h = camera_get_view_height(active_camera);
    var mouse_view_x = _mouse_window_x / max(1, window_get_width());
    var mouse_view_y = _mouse_window_y / max(1, window_get_height());
    var mouse_world_x = view_x + mouse_view_x * view_w;
    var mouse_world_y = view_y + mouse_view_y * view_h;

    _controller.preview_x = fence_snap_to_grid(mouse_world_x);
    _controller.preview_y = fence_snap_to_grid(mouse_world_y);
    _controller.preview_in_room =
        _controller.preview_x >= fence_grid_size() * 0.5
        && _controller.preview_y >= fence_grid_size() * 0.5
        && _controller.preview_x
            <= room_width - fence_grid_size() * 0.5
        && _controller.preview_y
            <= room_height - fence_grid_size() * 0.5;
    _controller.preview_records = [];

    if (!_controller.preview_in_room)
    {
        _controller.placement_result = {
            valid: false,
            message: "Fence must stay inside the room grid.",
            records: _controller.planned_records,
            gate_x: _controller.preview_x,
            gate_y: _controller.preview_y
        };
        return;
    }

    if (_controller.gate_mode)
    {
        if (_controller.cabin_tutorial_mode
        && _controller.preview_y != _controller.tutorial_bounds.max_y)
        {
            _controller.placement_result = {
                valid: false,
                message:
                    "Place the gate on the highlighted front (south) side.",
                records: _controller.planned_records,
                gate_x: _controller.preview_x,
                gate_y: _controller.preview_y
            };
            return;
        }

        _controller.placement_result = fence_try_place_gate(
            _controller.planned_records,
            _controller.planning_room_name,
            _controller.preview_x,
            _controller.preview_y,
            _controller.outside_gate_count,
            _controller.planning_purpose
        );
        return;
    }

    if (_controller.anchor_set)
    {
        _controller.preview_records = fence_make_rectangle_records(
            _controller.planning_room_name,
            _controller.anchor_x,
            _controller.anchor_y,
            _controller.preview_x,
            _controller.preview_y,
            _controller.planning_purpose
        );

        if (_controller.cabin_tutorial_mode
        && !cabin_fence_point_is_opposite_corner(
            _controller.preview_x,
            _controller.preview_y,
            _controller.anchor_x,
            _controller.anchor_y,
            _controller.tutorial_bounds
        ))
        {
            _controller.placement_result = {
                valid: false,
                message:
                    "Click the highlighted corner opposite your first choice.",
                records: _controller.planned_records
            };
        }
        else
        {
            _controller.placement_result = fence_try_add_rectangle(
                _controller.planned_records,
                _controller.planning_room_name,
                _controller.anchor_x,
                _controller.anchor_y,
                _controller.preview_x,
                _controller.preview_y,
                _controller.outside_gate_count,
                _controller.planning_purpose
            );
        }

        _controller.placement_result.gate_x = _controller.preview_x;
        _controller.placement_result.gate_y = _controller.preview_y;
        return;
    }

    var first_corner_clear = fence_find_record(
        _controller.planned_records,
        _controller.preview_x,
        _controller.preview_y
    ) == -1;
    var first_corner_allowed = !_controller.cabin_tutorial_mode
        || cabin_fence_point_is_corner(
            _controller.preview_x,
            _controller.preview_y,
            _controller.tutorial_bounds
        );
    _controller.placement_result = {
        valid: first_corner_clear && first_corner_allowed,
        message: !first_corner_allowed
            ? "Choose one of the four highlighted corners."
            : (first_corner_clear
                ? "Click to set the first corner."
                : "Choose an empty grid cell for the first corner."),
        records: _controller.planned_records,
        gate_x: _controller.preview_x,
        gate_y: _controller.preview_y
    };
}

function fence_planning_controller_toggle_mode(_controller)
{
    _controller.gate_mode = !_controller.gate_mode;
    _controller.anchor_set = false;
    _controller.preview_records = [];
    _controller.status_message = _controller.gate_mode
        ? (_controller.cabin_tutorial_mode
            ? "Step 2: click the highlighted front side to install one gate."
            : "Gate mode ON: click a straight horizontal fence side.")
        : (_controller.cabin_tutorial_mode
            ? "Step 1: click a highlighted corner, then its opposite."
            : "Rectangle mode: click the first corner.");
}

function fence_planning_controller_cancel(_controller)
{
    global.fence_toggle_ready_at = current_time + 100;
    fence_restore_room();
    notification_show_hint(
        "Fence plan cancelled; saved fences were restored.",
        game_get_speed(gamespeed_fps) * 3,
        false
    );
    with (_controller) instance_destroy();
}

function fence_planning_controller_commit(_controller)
{
    _controller.anchor_set = false;
    _controller.preview_records = [];
    var layout_status =
        fence_planning_controller_refresh_layout(_controller);

    if (!layout_status.valid)
    {
        _controller.status_message = layout_status.message;
        notification_show_hint(
            layout_status.message,
            game_get_speed(gamespeed_fps) * 3,
            false
        );
        return false;
    }

    fence_commit_room_records(
        _controller.planning_room_name,
        _controller.planned_records
    );
    fence_refresh_room_instances(
        _controller.planned_records,
        false,
        true
    );

    if (_controller.cabin_tutorial_mode)
    {
        progression_complete_cabin_fence_state(game_state_ensure());
    }

    save_write();
    global.fence_toggle_ready_at = current_time + 100;
    notification_show_hint(
        _controller.cabin_tutorial_mode
            ? "Objective complete â€” return to the Task Board."
            : "Fence plan saved.",
        game_get_speed(gamespeed_fps)
            * (_controller.cabin_tutorial_mode ? 5 : 3),
        _controller.cabin_tutorial_mode
    );
    with (_controller) instance_destroy();
    return true;
}

/// Returns true when the Step event should stop processing this frame.
function fence_planning_controller_remove(_controller)
{
    if (_controller.anchor_set)
    {
        _controller.anchor_set = false;
        _controller.preview_records = [];
        _controller.status_message = "Corner selection cancelled.";
        return false;
    }

    var selected_index = fence_find_record(
        _controller.planned_records,
        _controller.preview_x,
        _controller.preview_y
    );

    if (!_controller.cabin_tutorial_mode
    && selected_index != -1
    && fence_record_purpose(
        _controller.planned_records[selected_index]
    ) == FENCE_PURPOSE_CABIN_SITE)
    {
        _controller.status_message =
            "The marked cabin boundary is part of the established site.";
        return true;
    }

    var removal = fence_remove_gate_at(
        _controller.planned_records,
        _controller.preview_x,
        _controller.preview_y
    );

    if (!removal.removed)
    {
        removal = fence_remove_enclosure_at(
            _controller.planned_records,
            _controller.preview_x,
            _controller.preview_y
        );
    }

    _controller.status_message = removal.message;

    if (removal.removed)
    {
        _controller.planned_records = removal.records;
        var layout_status =
            fence_planning_controller_refresh_layout(_controller);
        fence_refresh_room_instances(
            _controller.planned_records,
            true,
            layout_status.valid
        );
    }

    return false;
}

/// Returns true when the Step event should stop processing this frame.
function fence_planning_controller_place(_controller)
{
    if (!_controller.placement_result.valid)
    {
        _controller.status_message =
            _controller.placement_result.message;
        notification_show_hint(
            _controller.placement_result.message,
            game_get_speed(gamespeed_fps) * 2,
            false
        );
        return true;
    }

    if (_controller.gate_mode)
    {
        _controller.planned_records =
            _controller.placement_result.records;
        var gate_layout =
            fence_planning_controller_refresh_layout(_controller);
        _controller.status_message = _controller.cabin_tutorial_mode
            ? gate_layout.message
            : "Gate installed. Press G to return to rectangle mode.";
        fence_refresh_room_instances(
            _controller.planned_records,
            true,
            gate_layout.valid
        );
        return false;
    }

    if (!_controller.anchor_set)
    {
        _controller.anchor_set = true;
        _controller.anchor_x = _controller.preview_x;
        _controller.anchor_y = _controller.preview_y;
        _controller.status_message =
            "First corner set. Click the opposite corner.";
        return false;
    }

    _controller.planned_records = _controller.placement_result.records;
    _controller.anchor_set = false;
    _controller.preview_records = [];
    var rectangle_layout =
        fence_planning_controller_refresh_layout(_controller);
    _controller.status_message = _controller.cabin_tutorial_mode
        ? rectangle_layout.message
        : "Enclosure placed. Add another or press F to save.";
    fence_refresh_room_instances(
        _controller.planned_records,
        true,
        rectangle_layout.valid
    );
    return false;
}
