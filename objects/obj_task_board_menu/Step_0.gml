/// obj_task_board_menu - Step Event

if (input_lock_frames > 0)
{
    input_lock_frames -= 1;
}
else if (keyboard_check_pressed(vk_escape)
|| keyboard_check_pressed(ord("E")))
{
    task_board_menu_close();
    exit;
}

var selection_move = keyboard_check_pressed(vk_down)
    - keyboard_check_pressed(vk_up);

if (selection_move != 0)
{
    selected_row = clamp(
        selected_row + selection_move,
        0,
        array_length(task_order) - 1
    );
    selected_task = task_order[selected_row];
    action_message = "";
}

var layout = task_board_menu_get_layout();
var visible_rows = max(
    1,
    floor(
        (layout.content_bottom - layout.content_top)
            / task_row_height
    )
);
var task_count = array_length(task_order);
var max_scroll = max(0, task_count - visible_rows);
var mouse_gui_x = device_mouse_x_to_gui(0);
var mouse_gui_y = device_mouse_y_to_gui(0);
var mouse_over_list = point_in_rectangle(
    mouse_gui_x,
    mouse_gui_y,
    layout.list_left,
    layout.content_top,
    layout.list_right,
    min(
        layout.content_bottom,
        layout.content_top + task_count * task_row_height
    )
);

if (mouse_over_list)
{
    list_scroll = clamp(
        list_scroll + mouse_wheel_down() - mouse_wheel_up(),
        0,
        max_scroll
    );

    if (mouse_check_button_pressed(mb_left))
    {
        selected_row = clamp(
            list_scroll
                + floor(
                    (mouse_gui_y - layout.content_top)
                        / task_row_height
                ),
            0,
            task_count - 1
        );
        selected_task = task_order[selected_row];
        action_message = "";
    }
}

if (selected_row < list_scroll) list_scroll = selected_row;
if (selected_row >= list_scroll + visible_rows)
    list_scroll = selected_row - visible_rows + 1;
list_scroll = clamp(list_scroll, 0, max_scroll);

var action_pressed = input_lock_frames <= 0
    && (
        keyboard_check_pressed(vk_enter)
        || keyboard_check_pressed(vk_space)
        || (
            mouse_check_button_pressed(mb_left)
            && point_in_rectangle(
                mouse_gui_x,
                mouse_gui_y,
                layout.action_left,
                layout.action_top,
                layout.action_right,
                layout.action_bottom
            )
        )
    );

if (action_pressed)
{
    task_board_menu_perform_action();
}
