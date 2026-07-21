/// obj_inventory_menu - Step Event

if (keyboard_check_pressed(ord("I"))
|| keyboard_check_pressed(vk_tab)
|| keyboard_check_pressed(vk_escape))
{
    inventory_menu_close();
    exit;
}

var category_count = array_length(inventory_categories);
var category_move = keyboard_check_pressed(vk_right)
    - keyboard_check_pressed(vk_left);

if (category_move != 0)
{
    selected_category = (selected_category + category_move + category_count)
        mod category_count;
}

var layout = inventory_menu_get_layout();
var mouse_gui_x = device_mouse_x_to_gui(0);
var mouse_gui_y = device_mouse_y_to_gui(0);

if (mouse_check_button_pressed(mb_left)
&& point_in_rectangle(
    mouse_gui_x,
    mouse_gui_y,
    layout.tabs_left,
    layout.tabs_top,
    layout.tabs_right,
    layout.tabs_bottom
))
{
    var tab_width = (layout.tabs_right - layout.tabs_left) / category_count;
    selected_category = clamp(
        floor((mouse_gui_x - layout.tabs_left) / tab_width),
        0,
        category_count - 1
    );
}
