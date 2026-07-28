/// Thin world-object configuration and presentation for production machines.

function production_input_source_label(_definition)
{
    return _definition.input_source == ProductionInputSource.CARRIED
        ? "Carried"
        : "Homebase";
}

function production_machine_configure(
    _machine,
    _machine_id
)
{
    var definition = production_machine_definition(_machine_id);
    if (is_undefined(definition)) return false;

    _machine.machine_id = _machine_id;
    _machine.machine_type = definition.machine_type;
    _machine.image_speed = 0;
    _machine.image_index = 0;
    _machine.interaction_enabled = true;
    _machine.interaction_radius = 58;
    _machine.interaction_priority = 44;
    _machine.collision_blocker = instance_create_depth(
        _machine.x,
        _machine.y,
        10000,
        obj_world_collision_blocker
    );
    _machine.collision_blocker.mask_index = _machine.sprite_index;
    _machine.collision_blocker.collision_owner = _machine_id;
    _machine.interaction_get_prompt = function(_actor)
    {
        return production_machine_read_model(
            machine_id,
            machine_type
        ).prompt;
    };
    _machine.interaction_run = function(_actor)
    {
        var model = production_machine_read_model(
            machine_id,
            machine_type
        );
        if (!model.unlocked)
        {
            notification_show_hint(
                machine_type == ProductionMachineType.LATHE
                    ? "The first lathe recipe unlocks after the cabin is raised."
                    : "The sawmill unlocks during the cabin boundary task.",
                game_get_speed(gamespeed_fps) * 4,
                false
            );
            return;
        }
        production_machine_open_menu(machine_id, machine_type);
    };
    return true;
}

function production_machine_destroy(_machine)
{
    if (variable_instance_exists(_machine, "collision_blocker")
    && instance_exists(_machine.collision_blocker))
    {
        with (_machine.collision_blocker) instance_destroy();
    }
}

function production_machine_step(_machine)
{
    var model = production_machine_read_model(
        _machine.machine_id,
        _machine.machine_type
    );
    _machine.image_speed = model.running ? 0.16 : 0;
    if (!model.running) _machine.image_index = 0;
}

function production_machine_draw(_machine)
{
    draw_self();
    var model = production_machine_read_model(
        _machine.machine_id,
        _machine.machine_type
    );
    if (model.running)
    {
        world_draw_progress_bar(
            _machine.x,
            _machine.y - sprite_get_height(_machine.sprite_index) * 0.5 - 8,
            48,
            model.progress,
            model.recipe_name
                + " "
                + string(model.batch_number)
                + "/"
                + string(model.batch_total)
        );
    }
}

function production_machine_open_menu(_machine_id, _machine_type)
{
    if (instance_exists(obj_production_menu)
    || dialogue_is_active()
    || instance_exists(obj_pause_menu))
    {
        return false;
    }

    player_menu_close();
    var menu = instance_create_depth(0, 0, -5000, obj_production_menu);
    menu.machine_id = _machine_id;
    menu.machine_type = _machine_type;
    var definition = production_machine_definition(_machine_id);
    menu.recipe_ids = is_undefined(definition)
        ? production_machine_available_recipes(_machine_type)
        : production_machine_available_recipes(definition.machine_type);
    menu.selected_row = -1;
    menu.hovered_row = -1;
    menu.selected_batches = 1;
    menu.message = "Click a recipe to select it. Click it again to deselect.";
    gameplay_set_paused(true);
    return true;
}

function production_menu_close()
{
    with (obj_production_menu) instance_destroy();
    gameplay_set_paused(false);
    input_lock_interaction(2);
    return true;
}

function production_menu_layout()
{
    var panel = player_menu_get_panel_bounds();
    return {
        gui_w: panel.gui_w,
        gui_h: panel.gui_h,
        left: panel.panel_left,
        top: panel.panel_top,
        right: panel.panel_right,
        bottom: panel.panel_bottom,
        list_left: panel.panel_left + 24,
        list_top: panel.panel_top + 86,
        list_right: panel.panel_right - 24,
        row_height: 64,
        minus_left: panel.panel_left + 24,
        minus_right: panel.panel_left + 70,
        plus_left: panel.panel_left + 82,
        plus_right: panel.panel_left + 128,
        action_left: panel.panel_right - 178,
        action_right: panel.panel_right - 24,
        controls_top: panel.panel_bottom - 76,
        controls_bottom: panel.panel_bottom - 30
    };
}

function production_menu_configure(_menu)
{
    _menu.machine_id = "";
    _menu.machine_type = ProductionMachineType.SAWMILL;
    _menu.recipe_ids = [];
    _menu.selected_row = -1;
    _menu.hovered_row = -1;
    _menu.selected_batches = 1;
    _menu.message = "Click a recipe to select it. Click it again to deselect.";
}

function production_menu_selected_recipe(_menu)
{
    if (_menu.selected_row < 0
    || _menu.selected_row >= array_length(_menu.recipe_ids))
        return -1;
    return _menu.recipe_ids[_menu.selected_row];
}

function production_menu_start_selected(_menu)
{
    var recipe_id = production_menu_selected_recipe(_menu);
    if (recipe_id < 0)
    {
        _menu.message = "Select a recipe first.";
        return false;
    }
    if (!production_start_job(
        _menu.machine_id,
        recipe_id,
        _menu.selected_batches
    ))
    {
        var definition = production_recipe_definition(recipe_id);
        var input_inventory = production_input_inventory(
            game_state_read(),
            definition
        );
        var available = inventory_get_amount(
            input_inventory,
            definition.input_id
        );
        _menu.message = available < definition.input_amount
            ? (
                definition.input_source
                    == ProductionInputSource.CARRIED
                    ? "Pick up "
                        + resource_get_name(definition.input_id)
                        + " from the middle chest first."
                    : "Homebase needs "
                        + resource_get_name(definition.input_id)
                        + " before this can start."
            )
            : "The tutorial only permits the exact amount still needed.";
        return false;
    }
    _menu.message = "Job started. It will continue while you work.";
    return true;
}

function production_menu_recommended_batches(_recipe_id, _game_state)
{
    var target = production_tutorial_recipe_target(_game_state);
    if (!is_undefined(target)
    && target.recipe_id == _recipe_id)
    {
        return max(1, target.batches);
    }
    return 1;
}

function production_menu_toggle_row(_menu, _row, _game_state)
{
    if (_row < 0 || _row >= array_length(_menu.recipe_ids))
        return false;

    if (_menu.selected_row == _row)
    {
        _menu.selected_row = -1;
        _menu.selected_batches = 1;
        _menu.message = "Recipe deselected.";
        return true;
    }

    _menu.selected_row = _row;
    var recipe_id = _menu.recipe_ids[_row];
    var maximum = production_recipe_max_batches(
        recipe_id,
        _game_state
    );
    var recommended = production_menu_recommended_batches(
        recipe_id,
        _game_state
    );
    _menu.selected_batches = maximum > 0
        ? clamp(recommended, 1, maximum)
        : 1;
    _menu.message = "Selected. Choose quantity, then start.";
    return true;
}

function production_menu_step(_menu)
{
    var layout = production_menu_layout();
    var mouse_x_gui = device_mouse_x_to_gui(0);
    var mouse_y_gui = device_mouse_y_to_gui(0);
    var mouse_pressed = mouse_check_button_pressed(mb_left);
    var model = production_machine_read_model(
        _menu.machine_id,
        _menu.machine_type
    );
    var game_state = game_state_read();

    if (keyboard_check_pressed(vk_escape))
    {
        production_menu_close();
        return;
    }

    if (model.running)
    {
        if ((mouse_pressed
            && point_in_rectangle(
                mouse_x_gui, mouse_y_gui,
                layout.action_left, layout.controls_top,
                layout.action_right, layout.controls_bottom
            ))
        || keyboard_check_pressed(ord("C")))
        {
            production_cancel_job(_menu.machine_id);
            _menu.message = "Unprocessed inputs returned to Homebase.";
        }
        return;
    }

    var recipe_count = array_length(_menu.recipe_ids);
    var move = keyboard_check_pressed(vk_down)
        - keyboard_check_pressed(vk_up);
    if (recipe_count > 0 && move != 0)
    {
        var keyboard_row = _menu.selected_row;
        if (keyboard_row < 0)
            keyboard_row = move > 0 ? 0 : recipe_count - 1;
        else
            keyboard_row = (
                keyboard_row + move + recipe_count
            ) mod recipe_count;
        production_menu_toggle_row(
            _menu,
            keyboard_row,
            game_state
        );
    }

    _menu.hovered_row = -1;
    if (recipe_count > 0
    && point_in_rectangle(
        mouse_x_gui, mouse_y_gui,
        layout.list_left, layout.list_top,
        layout.list_right,
        layout.list_top + recipe_count * layout.row_height
    ))
    {
        var row = clamp(
            floor(
                (mouse_y_gui - layout.list_top)
                    / layout.row_height
            ),
            0,
            recipe_count - 1
        );
        _menu.hovered_row = row;
        if (mouse_pressed)
        {
            production_menu_toggle_row(_menu, row, game_state);
        }
    }

    var recipe_id = production_menu_selected_recipe(_menu);
    var maximum = recipe_id < 0
        ? 0
        : production_recipe_max_batches(recipe_id);
    var quantity_move = keyboard_check_pressed(vk_right)
        - keyboard_check_pressed(vk_left);
    if (mouse_pressed
    && point_in_rectangle(
        mouse_x_gui, mouse_y_gui,
        layout.minus_left, layout.controls_top,
        layout.minus_right, layout.controls_bottom
    )) quantity_move -= 1;
    if (mouse_pressed
    && point_in_rectangle(
        mouse_x_gui, mouse_y_gui,
        layout.plus_left, layout.controls_top,
        layout.plus_right, layout.controls_bottom
    )) quantity_move += 1;
    if (quantity_move != 0)
    {
        _menu.selected_batches = clamp(
            _menu.selected_batches + quantity_move,
            1,
            max(1, maximum)
        );
    }

    if ((mouse_pressed
        && point_in_rectangle(
            mouse_x_gui, mouse_y_gui,
            layout.action_left, layout.controls_top,
            layout.action_right, layout.controls_bottom
        ))
    || keyboard_check_pressed(vk_enter)
    || keyboard_check_pressed(ord("E")))
    {
        production_menu_start_selected(_menu);
    }
}

function production_menu_draw(_menu)
{
    var layout = production_menu_layout();
    var game_state = game_state_read();
    var model = production_machine_read_model(
        _menu.machine_id,
        _menu.machine_type,
        game_state
    );
    draw_set_alpha(0.76);
    draw_set_color(make_color_rgb(14, 11, 9));
    draw_rectangle(0, 0, layout.gui_w, layout.gui_h, false);
    draw_set_alpha(1);
    draw_set_color(make_color_rgb(79, 50, 25));
    draw_roundrect(layout.left, layout.top, layout.right, layout.bottom, false);
    draw_set_color(make_color_rgb(39, 30, 23));
    draw_roundrect(layout.left + 5, layout.top + 5, layout.right - 5, layout.bottom - 5, false);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    draw_set_color(make_color_rgb(255, 216, 112));
    draw_text(
        layout.left + 24,
        layout.top + 18,
        string_upper(model.machine_name)
    );
    draw_set_color(make_color_rgb(191, 171, 139));
    draw_text(
        layout.left + 24,
        layout.top + 44,
        "Raw stock uses Homebase. Finished inputs must be carried from the middle chest."
    );

    if (model.running)
    {
        draw_set_color(make_color_rgb(247, 229, 198));
        draw_text(
            layout.list_left,
            layout.list_top,
            model.recipe_name
                + "    Batch "
                + string(model.batch_number)
                + " / "
                + string(model.batch_total)
        );
        draw_set_color(make_color_rgb(31, 27, 23));
        draw_rectangle(
            layout.list_left,
            layout.list_top + 40,
            layout.list_right,
            layout.list_top + 56,
            false
        );
        draw_set_color(make_color_rgb(222, 167, 65));
        draw_rectangle(
            layout.list_left,
            layout.list_top + 40,
            lerp(layout.list_left, layout.list_right, model.progress),
            layout.list_top + 56,
            false
        );
    }
    else
    {
        var tutorial_target =
            production_tutorial_recipe_target(game_state);
        var tutorial_flash =
            0.5 + 0.5 * sin(current_time * 0.008);
        for (var row = 0;
            row < array_length(_menu.recipe_ids);
            row++)
        {
            var row_recipe_id = _menu.recipe_ids[row];
            var definition = production_recipe_definition(
                row_recipe_id
            );
            var top = layout.list_top + row * layout.row_height;
            var is_selected = row == _menu.selected_row;
            var is_hovered = row == _menu.hovered_row;
            var is_tutorial_target =
                !is_undefined(tutorial_target)
                && tutorial_target.recipe_id == row_recipe_id;
            draw_set_color(
                is_selected
                    ? make_color_rgb(78, 59, 38)
                    : (
                        is_hovered
                            ? make_color_rgb(63, 51, 39)
                            : make_color_rgb(50, 42, 34)
                    )
            );
            draw_roundrect(
                layout.list_left, top,
                layout.list_right, top + layout.row_height - 6,
                false
            );
            if (is_tutorial_target)
            {
                draw_set_alpha(0.45 + 0.45 * tutorial_flash);
                draw_set_color(make_color_rgb(255, 203, 60));
                draw_roundrect(
                    layout.list_left - 2,
                    top - 2,
                    layout.list_right + 2,
                    top + layout.row_height - 4,
                    true
                );
                draw_set_alpha(1);
            }
            draw_set_color(is_selected
                ? make_color_rgb(255, 220, 92)
                : make_color_rgb(247, 229, 198));
            draw_text(layout.list_left + 16, top + 10, definition.name);
            draw_set_color(make_color_rgb(191, 171, 139));
            draw_text(
                layout.list_left + 16,
                top + 34,
                string(definition.input_amount)
                    + " "
                    + resource_get_name(definition.input_id)
                    + "  ->  "
                    + string(definition.output_amount)
                    + " "
                    + resource_get_name(definition.output_id)
            );
            draw_set_halign(fa_right);
            if (is_tutorial_target)
            {
                draw_set_color(make_color_rgb(255, 220, 92));
                draw_text(
                    layout.list_right - 16,
                    top + 8,
                    "NEXT: "
                        + string(tutorial_target.batches)
                        + " BATCH"
                        + (
                            tutorial_target.batches == 1
                                ? ""
                                : "ES"
                        )
                );
            }
            draw_set_color(make_color_rgb(191, 171, 139));
            draw_text(
                layout.list_right - 16,
                top + (is_tutorial_target ? 34 : 22),
                production_input_source_label(definition)
                    + " "
                    + string(inventory_get_amount(
                        production_input_inventory(
                            game_state,
                            definition
                        ),
                        definition.input_id
                    ))
            );
            draw_set_halign(fa_left);
        }
    }

    draw_set_color(make_color_rgb(78, 59, 38));
    draw_roundrect(
        layout.minus_left, layout.controls_top,
        layout.minus_right, layout.controls_bottom,
        false
    );
    draw_roundrect(
        layout.plus_left, layout.controls_top,
        layout.plus_right, layout.controls_bottom,
        false
    );
    draw_roundrect(
        layout.action_left, layout.controls_top,
        layout.action_right, layout.controls_bottom,
        false
    );
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_set_color(make_color_rgb(255, 220, 92));
    draw_text(
        (layout.minus_left + layout.minus_right) * 0.5,
        (layout.controls_top + layout.controls_bottom) * 0.5,
        "-"
    );
    draw_text(
        (layout.plus_left + layout.plus_right) * 0.5,
        (layout.controls_top + layout.controls_bottom) * 0.5,
        "+"
    );
    draw_text(
        (layout.action_left + layout.action_right) * 0.5,
        (layout.controls_top + layout.controls_bottom) * 0.5,
        model.running
            ? "CANCEL JOB"
            : (
                production_menu_selected_recipe(_menu) < 0
                    ? "SELECT RECIPE"
                    : "START x" + string(_menu.selected_batches)
            )
    );
    draw_set_valign(fa_top);
    draw_set_color(make_color_rgb(191, 171, 139));
    draw_text(
        layout.gui_w * 0.5,
        layout.bottom - 20,
        _menu.message == "" ? "Escape closes" : _menu.message
    );
    draw_set_halign(fa_left);
    draw_set_color(c_white);
}
