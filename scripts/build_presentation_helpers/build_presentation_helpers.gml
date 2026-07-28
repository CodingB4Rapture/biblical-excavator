/// Build menu and world-placement presentation. Durable changes route through
/// build_command_helpers; both objects remain presentation-only.

function build_menu_open()
{
    if (!player_menu_navigation_is_available()
    || !build_is_unlocked()
    || instance_exists(obj_build_menu))
    {
        return false;
    }

    player_menu_close();
    instance_create_depth(0, 0, -5000, obj_build_menu);
    gameplay_set_paused(true);
    return true;
}

function build_menu_close()
{
    with (obj_build_menu) instance_destroy();
    gameplay_set_paused(false);
    return true;
}

function build_menu_layout()
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
        list_top: panel.panel_top + 76,
        list_right: panel.panel_right - 24,
        row_height: 56,
        close_left: panel.panel_right - 58,
        close_top: panel.panel_top + 16,
        close_right: panel.panel_right - 20,
        close_bottom: panel.panel_top + 48
    };
}

function build_menu_configure(_menu)
{
    _menu.rows = build_get_inventory_rows();
    _menu.selected_row = 0;
    _menu.message = "";
    return true;
}

function build_menu_activate(_menu, _row)
{
    if (_row < array_length(_menu.rows))
    {
        var resource_id = _menu.rows[_row].resource_id;
        if (_menu.rows[_row].amount <= 0)
        {
            _menu.message = "Retrieve or craft that fence piece first.";
            return false;
        }
        build_menu_close();
        return instance_exists(build_begin_placement(resource_id, false));
    }

    build_menu_close();
    return instance_exists(build_begin_placement(-1, true));
}

function build_menu_step(_menu)
{
    var layout = build_menu_layout();
    var mouse_x_gui = device_mouse_x_to_gui(0);
    var mouse_y_gui = device_mouse_y_to_gui(0);
    var row_count = array_length(_menu.rows) + 1;

    if (keyboard_check_pressed(vk_escape)
    || keyboard_check_pressed(ord("B"))
    || (mouse_check_button_pressed(mb_left)
        && point_in_rectangle(
            mouse_x_gui, mouse_y_gui,
            layout.close_left, layout.close_top,
            layout.close_right, layout.close_bottom
        )))
    {
        build_menu_close();
        return;
    }

    var move = keyboard_check_pressed(vk_down)
        - keyboard_check_pressed(vk_up);
    if (move != 0)
        _menu.selected_row = (
            _menu.selected_row + move + row_count
        ) mod row_count;

    var rows_bottom = layout.list_top + row_count * layout.row_height;
    if (point_in_rectangle(
        mouse_x_gui, mouse_y_gui,
        layout.list_left, layout.list_top,
        layout.list_right, rows_bottom
    ))
    {
        _menu.selected_row = clamp(
            floor(
                (mouse_y_gui - layout.list_top)
                    / layout.row_height
            ),
            0,
            row_count - 1
        );
        if (mouse_check_button_pressed(mb_left))
            build_menu_activate(_menu, _menu.selected_row);
    }

    if (keyboard_check_pressed(vk_enter)
    || keyboard_check_pressed(vk_space)
    || keyboard_check_pressed(ord("E")))
    {
        build_menu_activate(_menu, _menu.selected_row);
    }
}

function build_menu_draw(_menu)
{
    var layout = build_menu_layout();
    var game_state = game_state_read();
    var recommended_resource =
        task_is_active(TaskId.BUILD_CABIN_FENCE, game_state)
            ? cabin_blueprint_recommended_resource(game_state)
            : -1;
    var tutorial_flash =
        0.5 + 0.5 * sin(current_time * 0.008);
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
    draw_text(layout.left + 24, layout.top + 18, "BUILD");
    draw_set_color(make_color_rgb(191, 171, 139));
    draw_text(layout.left + 24, layout.top + 42, "Choose a carried piece, then place it one cell at a time.");

    var row_count = array_length(_menu.rows) + 1;
    for (var row = 0; row < row_count; row++)
    {
        var top = layout.list_top + row * layout.row_height;
        var selected = row == _menu.selected_row;
        draw_set_color(selected
            ? make_color_rgb(78, 59, 38)
            : make_color_rgb(50, 42, 34));
        draw_roundrect(
            layout.list_left, top,
            layout.list_right, top + layout.row_height - 6,
            false
        );
        draw_set_color(selected
            ? make_color_rgb(255, 220, 92)
            : make_color_rgb(247, 229, 198));
        if (row < array_length(_menu.rows))
        {
            var item = _menu.rows[row];
            var recommended =
                item.resource_id == recommended_resource;
            if (recommended)
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
                draw_set_color(make_color_rgb(255, 220, 92));
            }
            draw_text(
                layout.list_left + 18,
                top + 14,
                resource_get_name(item.resource_id)
            );
            draw_set_halign(fa_right);
            draw_text(
                layout.list_right - 18,
                top + 14,
                (recommended ? "NEXT   " : "")
                    + "Carried  x "
                    + string(item.amount)
            );
            draw_set_halign(fa_left);
        }
        else
        {
            draw_text(layout.list_left + 18, top + 14, "Remove Fence Piece");
        }
    }

    draw_set_halign(fa_center);
    draw_set_color(make_color_rgb(191, 171, 139));
    draw_text(
        (layout.left + layout.right) * 0.5,
        layout.bottom - 30,
        _menu.message == ""
            ? "Mouse or Up/Down    E/Enter selects    Escape closes"
            : _menu.message
    );
    draw_set_halign(fa_left);
    draw_set_color(c_white);
}

function build_placement_configure(_controller)
{
    _controller.resource_id = -1;
    _controller.orientation = FenceRotation.FRONT;
    _controller.remove_mode = false;
    _controller.preview_x = 0;
    _controller.preview_y = 0;
    _controller.status_message = "";
    _controller.status_valid = false;
}

function build_placement_cancel(_controller)
{
    with (_controller) instance_destroy();
    input_lock_interaction(2);
}

function build_placement_step(_controller)
{
    _controller.preview_x = fence_snap_to_grid(mouse_x);
    _controller.preview_y = fence_snap_to_grid(mouse_y);

    if (keyboard_check_pressed(vk_escape)
    || keyboard_check_pressed(ord("B"))
    || mouse_check_button_pressed(mb_right))
    {
        build_placement_cancel(_controller);
        return;
    }

    if (!_controller.remove_mode
    && keyboard_check_pressed(ord("R")))
    {
        _controller.orientation = (_controller.orientation + 1) mod 4;
    }

    if (_controller.remove_mode)
    {
        _controller.status_valid = true;
        _controller.status_message = "Remove fence piece";
        if (mouse_check_button_pressed(mb_left)
        || keyboard_check_pressed(ord("E")))
        {
            var remove_result = build_remove_piece_at(
                _controller.preview_x,
                _controller.preview_y
            );
            _controller.status_message = remove_result.message;
        }
        return;
    }

    var placement_game_state = game_state_read();
    if (task_is_active(
        TaskId.BUILD_CABIN_FENCE,
        placement_game_state
    ))
    {
        var magnetic_socket = cabin_blueprint_nearest_open_socket(
            mouse_x,
            mouse_y,
            build_resource_piece_type(_controller.resource_id),
            52,
            placement_game_state
        );
        if (!is_undefined(magnetic_socket))
        {
            _controller.preview_x = magnetic_socket.x;
            _controller.preview_y = magnetic_socket.y;
        }
    }

    var status = build_placement_status(
        _controller.resource_id,
        _controller.orientation,
        _controller.preview_x,
        _controller.preview_y
    );
    _controller.preview_x = status.x;
    _controller.preview_y = status.y;
    _controller.status_valid = status.valid;
    _controller.status_message = status.message;

    if ((mouse_check_button_pressed(mb_left)
        || keyboard_check_pressed(ord("E")))
    && status.valid)
    {
        var result = build_place_piece(
            _controller.resource_id,
            _controller.orientation,
            status.x,
            status.y
        );
        _controller.status_message = result.message;
        var updated_game_state = game_state_read();
        var no_piece_remains = inventory_get_amount(
            updated_game_state.player_inventory,
            _controller.resource_id
        ) <= 0;
        if (no_piece_remains)
        {
            var next_step =
                production_tutorial_next_step(updated_game_state);
            switch (next_step.kind)
            {
                case "collect":
                    notification_show_hint(
                        "That was your last carried piece. Pick up the remaining pieces from the middle Finished Crafts chest.",
                        game_get_speed(gamespeed_fps) * 6,
                        true
                    );
                    break;

                case "craft":
                    notification_show_hint(
                        "That was your last piece. Return to the sawmill; the flashing recipe shows the exact batch still needed.",
                        game_get_speed(gamespeed_fps) * 6,
                        true
                    );
                    break;

                case "recover_log":
                    notification_show_hint(
                        "You are out of timber. Chop another tree--or use a downed log--then get the skidsteer and tow it to Home Delivery.",
                        game_get_speed(gamespeed_fps) * 8,
                        true
                    );
                    break;
            }
        }
        if (no_piece_remains
        || !task_is_active(
            TaskId.BUILD_CABIN_FENCE,
            updated_game_state
        ) && !updated_game_state.free_build_unlocked)
        {
            build_placement_cancel(_controller);
        }
    }
}

function build_placement_draw(_controller)
{
    if (_controller.remove_mode)
    {
        draw_set_alpha(0.5);
        draw_set_color(make_color_rgb(255, 92, 72));
        draw_rectangle(
            _controller.preview_x - 15,
            _controller.preview_y - 15,
            _controller.preview_x + 15,
            _controller.preview_y + 15,
            true
        );
        draw_set_alpha(1);
        draw_set_color(c_white);
        return;
    }

    var piece_type = build_resource_piece_type(_controller.resource_id);
    var sprite = build_piece_sprite(
        piece_type,
        _controller.orientation
    );
    var draw_x = _controller.preview_x
        + (piece_type == FencePieceType.GATE
            ? fence_grid_size() * 0.5
            : 0);
    draw_sprite_ext(
        sprite, 0, draw_x, _controller.preview_y,
        1, 1, 0,
        _controller.status_valid
            ? make_color_rgb(185, 255, 174)
            : make_color_rgb(255, 120, 104),
        0.72
    );
}

function build_placement_draw_gui(_controller)
{
    var gui_w = display_get_gui_width();
    var gui_h = display_get_gui_height();
    draw_set_halign(fa_center);
    draw_set_valign(fa_bottom);
    draw_set_color(_controller.status_valid
        ? make_color_rgb(205, 242, 181)
        : make_color_rgb(255, 174, 150));
    draw_text(
        gui_w * 0.5,
        gui_h - 22,
        _controller.status_message
            + "    Left click/E place    R rotate    Right click/Escape cancel"
    );
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    draw_set_color(c_white);
}

function cabin_blueprint_draw(_site)
{
    var game_state = game_state_read();
    if (!task_is_active(TaskId.BUILD_CABIN_FENCE, game_state))
        return;
    var sockets = cabin_blueprint_sockets(game_state);
    var placement_active = instance_exists(obj_build_placement_controller);
    var placement = placement_active
        ? instance_find(obj_build_placement_controller, 0)
        : noone;
    var selected_piece_type = placement_active
        && !placement.remove_mode
            ? build_resource_piece_type(placement.resource_id)
            : FencePieceType.LEGACY;
    var selected_orientation = placement_active
        ? placement.orientation
        : FenceRotation.FRONT;
    var flash = 0.5 + 0.5 * sin(current_time * 0.008);
    for (var index = 0; index < array_length(sockets); index++)
    {
        var socket = sockets[index];
        if (cabin_blueprint_socket_is_filled(socket, game_state))
            continue;
        var sprite = build_piece_sprite(
            socket.piece_type,
            socket.orientation
        );
        var draw_x = socket.x
            + (socket.piece_type == FencePieceType.GATE
                ? fence_grid_size() * 0.5
                : 0);
        var matching_piece =
            socket.piece_type == selected_piece_type;
        var exact_match = matching_piece
            && socket.orientation == selected_orientation;
        draw_sprite_ext(
            sprite, 0, draw_x, socket.y,
            1, 1, 0,
            exact_match
                ? make_color_rgb(202, 255, 146)
                : (
                    matching_piece
                        ? make_color_rgb(255, 220, 92)
                        : make_color_rgb(222, 204, 150)
                ),
            exact_match
                ? 0.58 + 0.3 * flash
                : (
                    matching_piece
                        ? 0.34 + 0.22 * flash
                        : (placement_active ? 0.22 : 0.16)
                )
        );
    }
}
