/// obj_task_board_menu - Create Event

game_state_ensure();
task_order = task_get_story_order();
selected_task = task_get_preferred_selection();
selected_row = max(0, task_order_index_of(selected_task, task_order));
task_row_height = 44;
list_scroll = 0;
input_lock_frames = 2;
action_message = "";

task_board_menu_get_layout = function()
{
    var gui_w = display_get_gui_width();
    var gui_h = display_get_gui_height();
    var margin = 18;
    var panel_left = margin;
    var panel_top = margin;
    var panel_right = gui_w - margin;
    var panel_bottom = gui_h - margin;
    var list_width = clamp(
        (panel_right - panel_left) * 0.31,
        220,
        310
    );

    return {
        gui_w: gui_w,
        gui_h: gui_h,
        panel_left: panel_left,
        panel_top: panel_top,
        panel_right: panel_right,
        panel_bottom: panel_bottom,
        list_left: panel_left + 10,
        list_right: panel_left + list_width,
        content_top: panel_top + 54,
        content_bottom: panel_bottom - 46,
        detail_left: panel_left + list_width + 18,
        action_left: panel_right - 244,
        action_top: panel_bottom - 78,
        action_right: panel_right - 18,
        action_bottom: panel_bottom - 44
    };
};

task_board_menu_close = function()
{
    input_lock_interaction(3);
    gameplay_set_paused(false);
    instance_destroy();
};

task_board_menu_perform_action = function()
{
    var status = task_get_status(selected_task);
    var changed = false;

    switch (status)
    {
        case TaskStatus.AVAILABLE:
        {
            changed = task_start(selected_task);
            action_message = changed
                ? "Task accepted. Press E to close."
                : "That task cannot be accepted yet.";
            break;
        }

        case TaskStatus.COMPLETE:
        {
            changed = task_claim_reward(selected_task);
            action_message = changed
                ? "Task reward recorded."
                : "That reward has already been claimed.";
            break;
        }

        case TaskStatus.ACTIVE:
            action_message = "This task is already active.";
            break;

        case TaskStatus.CLAIMED:
            action_message = "This task is complete.";
            break;

        default:
            action_message = "Finish the earlier work to unlock this task.";
            break;
    }

    if (changed)
    {
        save_write();
        selected_task = task_get_preferred_selection();
        selected_row = max(
            0,
            task_order_index_of(selected_task, task_order)
        );
    }
};

gameplay_set_paused(true);
