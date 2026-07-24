/// obj_finished_crafts_menu - Step Event

if (input_lock_frames > 0)
{
    input_lock_frames -= 1;
    exit;
}

if (keyboard_check_pressed(vk_escape))
{
    if (quantity_mode)
    {
        quantity_mode = false;
        selected_quantity = 1;
        action_message = "";
    }
    else
    {
        finished_crafts_menu_close();
    }
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

    if (keyboard_check_pressed(ord("E"))
    || keyboard_check_pressed(vk_space)
    || keyboard_check_pressed(vk_enter))
    {
        var maximum = finished_crafts_menu_get_max_quantity();
        if (maximum <= 0)
        {
            var resource_id = finished_crafts_menu_get_selected_resource();
            var game_state = game_state_ensure();
            var chest_amount = resource_id < 0
                ? 0
                : inventory_get_amount(
                    game_state.finished_crafts_inventory,
                    resource_id
                );
            action_message = chest_amount <= 0
                ? "This finished craft is out of stock."
                : "Your backpack is at its limit for this item.";
        }
        else
        {
            quantity_mode = true;
            selected_quantity = 1;
            action_message = "";
        }
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

    var quantity_move = keyboard_check_pressed(vk_right)
        - keyboard_check_pressed(vk_left);
    if (quantity_move != 0)
    {
        selected_quantity = clamp(
            selected_quantity + quantity_move,
            1,
            maximum
        );
    }

    if (keyboard_check_pressed(ord("E"))
    || keyboard_check_pressed(vk_space)
    || keyboard_check_pressed(vk_enter))
    {
        finished_crafts_menu_take_selected();
    }
}
