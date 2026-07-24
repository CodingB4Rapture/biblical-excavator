/// obj_finished_crafts_menu - Step Event

if (input_lock_frames > 0)
{
    input_lock_frames -= 1;
    exit;
}

var layout = finished_crafts_menu_get_layout();
var mouse_gui_x = device_mouse_x_to_gui(0);
var mouse_gui_y = device_mouse_y_to_gui(0);
var mouse_pressed = mouse_check_button_pressed(mb_left);

if (mouse_pressed
&& point_in_rectangle(
    mouse_gui_x,
    mouse_gui_y,
    layout.close_left,
    layout.close_top,
    layout.close_right,
    layout.close_bottom
))
{
    finished_crafts_menu_close();
    exit;
}

if (mouse_check_button_pressed(mb_right))
{
    if (quantity_mode)
        finished_crafts_menu_leave_quantity();
    else
        finished_crafts_menu_close();
    exit;
}

if (keyboard_check_pressed(vk_escape))
{
    if (quantity_mode)
        finished_crafts_menu_leave_quantity();
    else
        finished_crafts_menu_close();
    exit;
}

var resource_count = array_length(finished_craft_rows);

if (!quantity_mode)
{
    var selection_move = keyboard_check_pressed(vk_down)
        - keyboard_check_pressed(vk_up);
    if (selection_move != 0 && resource_count > 0)
    {
        selected_row = (selected_row + selection_move + resource_count)
            mod resource_count;
        action_message = "";
    }

    var list_bottom = min(
        layout.content_bottom,
        layout.content_top + resource_count * layout.row_height
    );
    var mouse_over_list = resource_count > 0
        && point_in_rectangle(
            mouse_gui_x,
            mouse_gui_y,
            layout.list_left,
            layout.content_top,
            layout.list_right,
            list_bottom
        );

    if (mouse_over_list)
    {
        var wheel_move = mouse_wheel_down() - mouse_wheel_up();
        if (wheel_move != 0)
        {
            selected_row = clamp(
                selected_row + wheel_move,
                0,
                resource_count - 1
            );
            action_message = "";
        }

        if (mouse_pressed)
        {
            selected_row = clamp(
                floor(
                    (mouse_gui_y - layout.content_top)
                        / layout.row_height
                ),
                0,
                resource_count - 1
            );
            action_message = "";
            finished_crafts_menu_begin_quantity();
        }
    }

    if (keyboard_check_pressed(ord("E"))
    || keyboard_check_pressed(vk_space)
    || keyboard_check_pressed(vk_enter))
    {
        finished_crafts_menu_begin_quantity();
    }
}
else
{
    var maximum = finished_crafts_menu_get_max_quantity();
    if (maximum <= 0)
    {
        quantity_mode = false;
        selected_quantity = 1;
        action_message = "Nothing can be moved to your backpack.";
        exit;
    }

    if (mouse_pressed
    && point_in_rectangle(
        mouse_gui_x,
        mouse_gui_y,
        layout.quantity_back_left,
        layout.quantity_back_top,
        layout.quantity_back_right,
        layout.quantity_back_bottom
    ))
    {
        finished_crafts_menu_leave_quantity();
        exit;
    }

    var quantity_move = keyboard_check_pressed(vk_right)
        - keyboard_check_pressed(vk_left);
    if (mouse_pressed
    && point_in_rectangle(
        mouse_gui_x,
        mouse_gui_y,
        layout.quantity_left - 12,
        layout.quantity_track_y - 14,
        layout.quantity_left + 14,
        layout.quantity_track_y + 14
    ))
    {
        quantity_move -= 1;
    }
    if (mouse_pressed
    && point_in_rectangle(
        mouse_gui_x,
        mouse_gui_y,
        layout.quantity_right - 14,
        layout.quantity_track_y - 14,
        layout.quantity_right + 12,
        layout.quantity_track_y + 14
    ))
    {
        quantity_move += 1;
    }

    if (quantity_move != 0)
    {
        selected_quantity = clamp(
            selected_quantity + quantity_move,
            1,
            maximum
        );
    }

    var mouse_over_track = point_in_rectangle(
        mouse_gui_x,
        mouse_gui_y,
        layout.quantity_track_left - 10,
        layout.quantity_track_y - 12,
        layout.quantity_track_right + 10,
        layout.quantity_track_y + 12
    );
    if (mouse_over_track && mouse_check_button(mb_left))
    {
        finished_crafts_menu_set_quantity_from_x(
            mouse_gui_x,
            layout
        );
    }

    var take_pressed = keyboard_check_pressed(ord("E"))
    || keyboard_check_pressed(vk_space)
    || keyboard_check_pressed(vk_enter)
    || (
        mouse_pressed
        && point_in_rectangle(
            mouse_gui_x,
            mouse_gui_y,
            layout.quantity_take_left,
            layout.quantity_take_top,
            layout.quantity_take_right,
            layout.quantity_take_bottom
        )
    );

    if (take_pressed)
    {
        finished_crafts_menu_take_selected();
    }
}
