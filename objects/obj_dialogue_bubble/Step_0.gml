/// obj_dialogue_bubble - Step Event
/// The world waits until the player deliberately advances the conversation.

if (gameplay_is_paused()) exit;

if (input_lock_frames > 0)
{
    input_lock_frames -= 1;
    exit;
}

var active_page = pages[page_index];
var choices = dialogue_page_choices(active_page);
if (array_length(choices) > 0)
{
    choice_index = clamp(
        choice_index,
        0,
        array_length(choices) - 1
    );
    var choice_move =
        keyboard_check_pressed(vk_right)
        + keyboard_check_pressed(vk_down)
        - keyboard_check_pressed(vk_left)
        - keyboard_check_pressed(vk_up);
    if (choice_move != 0)
    {
        choice_index = (
            choice_index
            + sign(choice_move)
            + array_length(choices)
        ) mod array_length(choices);
    }

    var layout = dialogue_get_layout(
        dialogue_page_text(active_page),
        -1,
        -1,
        array_length(choices)
    );
    var mouse_x_gui = device_mouse_x_to_gui(0);
    var mouse_y_gui = device_mouse_y_to_gui(0);
    var clicked_choice = -1;
    for (var choice_check = 0;
        choice_check < array_length(choices);
        choice_check++)
    {
        var choice_rect = dialogue_choice_get_rect(
            layout,
            choice_check,
            array_length(choices)
        );
        if (point_in_rectangle(
            mouse_x_gui,
            mouse_y_gui,
            choice_rect.left,
            choice_rect.top,
            choice_rect.right,
            choice_rect.bottom
        ))
        {
            choice_index = choice_check;
            if (mouse_check_button_pressed(mb_left))
                clicked_choice = choice_check;
        }
    }

    var choice_confirmed = clicked_choice >= 0
        || input_interact_pressed()
        || keyboard_check_pressed(vk_enter)
        || keyboard_check_pressed(vk_space);
    if (choice_confirmed)
    {
        var selected_choice = choices[
            clicked_choice >= 0 ? clicked_choice : choice_index
        ];
        var selected_action =
            variable_struct_exists(selected_choice, "action")
                ? selected_choice.action
                : "";
        input_lock_interaction(2);
        instance_destroy();
        dialogue_run_completion_action(selected_action);
    }
    exit;
}

if (dialogue_advance_pressed())
{
    if (page_index < array_length(pages) - 1)
    {
        page_index += 1;
        choice_index = 0;
    }
    else
    {
        var finished_action = completion_action;
        input_lock_interaction(2);
        instance_destroy();
        dialogue_run_completion_action(finished_action);
    }
}

