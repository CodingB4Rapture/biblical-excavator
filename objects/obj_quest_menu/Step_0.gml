/// obj_quest_menu - Step Event

if (keyboard_check_pressed(ord("Q")) || keyboard_check_pressed(vk_escape))
{
    gameplay_set_paused(false);
    instance_destroy();
    exit;
}

var layout = quest_menu_get_layout();
var visible_rows = max(1, floor((layout.content_bottom - layout.content_top) / quest_row_height));
var max_scroll = max(0, QuestId.COUNT - visible_rows);
var mouse_gui_x = device_mouse_x_to_gui(0);
var mouse_gui_y = device_mouse_y_to_gui(0);
var mouse_over_list = mouse_gui_x >= layout.list_left
    && mouse_gui_x <= layout.list_right
    && mouse_gui_y >= layout.content_top
    && mouse_gui_y <= layout.content_bottom;

if (mouse_over_list)
{
    list_scroll = clamp(
        list_scroll + mouse_wheel_down() - mouse_wheel_up(),
        0,
        max_scroll
    );

    if (mouse_check_button_pressed(mb_left))
    {
        var clicked_row = floor((mouse_gui_y - layout.content_top) / quest_row_height);
        var clicked_quest = list_scroll + clicked_row;
        if (clicked_quest >= 0 && clicked_quest < QuestId.COUNT)
        {
            selected_quest = clicked_quest;
        }
    }
}

var selection_move = keyboard_check_pressed(vk_down) - keyboard_check_pressed(vk_up);
if (selection_move != 0)
{
    selected_quest = clamp(selected_quest + selection_move, 0, QuestId.COUNT - 1);
}

// Keep keyboard-selected quests inside the visible part of a future long list.
if (selected_quest < list_scroll) list_scroll = selected_quest;
if (selected_quest >= list_scroll + visible_rows)
{
    list_scroll = selected_quest - visible_rows + 1;
}
list_scroll = clamp(list_scroll, 0, max_scroll);
