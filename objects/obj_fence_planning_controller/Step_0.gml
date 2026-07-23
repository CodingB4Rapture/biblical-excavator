/// obj_fence_planning_controller - Step Event

if (gameplay_is_paused()
|| dialogue_is_active()
|| instance_exists(obj_quest_menu)
|| instance_exists(obj_inventory_menu)
|| instance_exists(obj_pause_menu)
|| instance_exists(obj_cabin_placement_controller))
{
    exit;
}

var active_camera = view_camera[0];
var view_x = camera_get_view_x(active_camera);
var view_y = camera_get_view_y(active_camera);
var view_w = camera_get_view_width(active_camera);
var view_h = camera_get_view_height(active_camera);
var mouse_view_x = window_mouse_get_x() / max(1, window_get_width());
var mouse_view_y = window_mouse_get_y() / max(1, window_get_height());
var mouse_world_x = view_x + mouse_view_x * view_w;
var mouse_world_y = view_y + mouse_view_y * view_h;

preview_x = fence_snap_to_grid(mouse_world_x);
preview_y = fence_snap_to_grid(mouse_world_y);
preview_in_room = preview_x >= fence_grid_size() * 0.5
    && preview_y >= fence_grid_size() * 0.5
    && preview_x <= room_width - fence_grid_size() * 0.5
    && preview_y <= room_height - fence_grid_size() * 0.5;

preview_records = [];

if (!preview_in_room)
{
    placement_result = {
        valid: false,
        message: "Fence must stay inside the room grid.",
        records: planned_records,
        gate_x: preview_x,
        gate_y: preview_y
    };
}
else if (gate_mode)
{
    if (cabin_tutorial_mode && preview_y != tutorial_bounds.max_y)
    {
        placement_result = {
            valid: false,
            message: "Place the gate on the highlighted front (south) side.",
            records: planned_records,
            gate_x: preview_x,
            gate_y: preview_y
        };
    }
    else
    {
        placement_result = fence_try_place_gate(
            planned_records,
            planning_room_name,
            preview_x,
            preview_y,
            outside_gate_count,
            planning_purpose
        );
    }
}
else if (anchor_set)
{
    preview_records = fence_make_rectangle_records(
        planning_room_name,
        anchor_x,
        anchor_y,
        preview_x,
        preview_y,
        planning_purpose
    );

    if (cabin_tutorial_mode
    && !cabin_fence_point_is_opposite_corner(
        preview_x,
        preview_y,
        anchor_x,
        anchor_y,
        tutorial_bounds
    ))
    {
        placement_result = {
            valid: false,
            message: "Click the highlighted corner opposite your first choice.",
            records: planned_records
        };
    }
    else
    {
        placement_result = fence_try_add_rectangle(
            planned_records,
            planning_room_name,
            anchor_x,
            anchor_y,
            preview_x,
            preview_y,
            outside_gate_count,
            planning_purpose
        );
    }
    placement_result.gate_x = preview_x;
    placement_result.gate_y = preview_y;
}
else
{
    var first_corner_clear = fence_find_record(
        planned_records,
        preview_x,
        preview_y
    ) == -1;
    var first_corner_allowed = !cabin_tutorial_mode
        || cabin_fence_point_is_corner(
            preview_x,
            preview_y,
            tutorial_bounds
        );
    placement_result = {
        valid: first_corner_clear && first_corner_allowed,
        message: !first_corner_allowed
            ? "Choose one of the four highlighted corners."
            : (first_corner_clear
                ? "Click to set the first corner."
                : "Choose an empty grid cell for the first corner."),
        records: planned_records,
        gate_x: preview_x,
        gate_y: preview_y
    };
}

if (input_lock_frames > 0)
{
    input_lock_frames -= 1;
    exit;
}

if (keyboard_check_pressed(ord("G")))
{
    gate_mode = !gate_mode;
    anchor_set = false;
    preview_records = [];
    status_message = gate_mode
        ? (cabin_tutorial_mode
            ? "Step 2: click the highlighted front side to install one gate."
            : "Gate mode ON: click a straight horizontal fence side.")
        : (cabin_tutorial_mode
            ? "Step 1: click a highlighted corner, then its opposite."
            : "Rectangle mode: click the first corner.");
    exit;
}

if (keyboard_check_pressed(vk_escape))
{
    global.fence_toggle_ready_at = current_time + 100;
    fence_restore_room();
    notification_show_hint(
        "Fence plan cancelled; saved fences were restored.",
        game_get_speed(gamespeed_fps) * 3,
        false
    );
    instance_destroy();
    exit;
}

if (keyboard_check_pressed(ord("F")))
{
    anchor_set = false;
    preview_records = [];
    layout_status = cabin_tutorial_mode
        ? cabin_fence_plot_status(
            planned_records,
            planning_room_name,
            tutorial_bounds
        )
        : fence_layout_status(planned_records, outside_gate_count);

    if (!layout_status.valid)
    {
        status_message = layout_status.message;
        notification_show_hint(
            layout_status.message,
            game_get_speed(gamespeed_fps) * 3,
            false
        );
        exit;
    }

    fence_commit_room_records(planning_room_name, planned_records);

    if (cabin_tutorial_mode)
    {
        progression_complete_cabin_fence_state(game_state_ensure());
    }

    save_write();
    global.fence_toggle_ready_at = current_time + 100;
    notification_show_hint(
        cabin_tutorial_mode
            ? "Objective complete — return to the Task Board."
            : "Fence plan saved.",
        game_get_speed(gamespeed_fps) * (cabin_tutorial_mode ? 5 : 3),
        cabin_tutorial_mode
    );
    instance_destroy();
    exit;
}

if (mouse_check_button_pressed(mb_right))
{
    if (anchor_set)
    {
        anchor_set = false;
        preview_records = [];
        status_message = "Corner selection cancelled.";
    }
    else
    {
        var selected_index = fence_find_record(
            planned_records,
            preview_x,
            preview_y
        );

        if (!cabin_tutorial_mode
        && selected_index != -1
        && fence_record_purpose(planned_records[selected_index])
            == FENCE_PURPOSE_CABIN_SITE)
        {
            status_message = "The marked cabin boundary is part of the established site.";
            exit;
        }

        var removal = fence_remove_gate_at(
            planned_records,
            preview_x,
            preview_y
        );

        if (!removal.removed)
        {
            removal = fence_remove_enclosure_at(
                planned_records,
                preview_x,
                preview_y
            );
        }

        status_message = removal.message;

        if (removal.removed)
        {
            planned_records = removal.records;
            layout_status = cabin_tutorial_mode
                ? cabin_fence_plot_status(
                    planned_records,
                    planning_room_name,
                    tutorial_bounds
                )
                : fence_layout_status(
                    planned_records,
                    outside_gate_count
                );
            fence_refresh_room_instances(
                planned_records,
                true,
                layout_status.valid
            );
        }
    }
}

if (mouse_check_button_pressed(mb_left))
{
    if (!placement_result.valid)
    {
        status_message = placement_result.message;
        notification_show_hint(
            placement_result.message,
            game_get_speed(gamespeed_fps) * 2,
            false
        );
        exit;
    }

    if (gate_mode)
    {
        planned_records = placement_result.records;
        layout_status = cabin_tutorial_mode
            ? cabin_fence_plot_status(
                planned_records,
                planning_room_name,
                tutorial_bounds
            )
            : fence_layout_status(
                planned_records,
                outside_gate_count
            );
        status_message = cabin_tutorial_mode
            ? layout_status.message
            : "Gate installed. Press G to return to rectangle mode.";
        fence_refresh_room_instances(
            planned_records,
            true,
            layout_status.valid
        );
    }
    else if (!anchor_set)
    {
        anchor_set = true;
        anchor_x = preview_x;
        anchor_y = preview_y;
        status_message = "First corner set. Click the opposite corner.";
    }
    else
    {
        planned_records = placement_result.records;
        anchor_set = false;
        preview_records = [];
        layout_status = cabin_tutorial_mode
            ? cabin_fence_plot_status(
                planned_records,
                planning_room_name,
                tutorial_bounds
            )
            : fence_layout_status(
                planned_records,
                outside_gate_count
            );
        status_message = cabin_tutorial_mode
            ? layout_status.message
            : "Enclosure placed. Add another or press F to save.";
        fence_refresh_room_instances(
            planned_records,
            true,
            layout_status.valid
        );
    }
}
