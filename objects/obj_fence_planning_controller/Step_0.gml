/// obj_fence_planning_controller - Step Event

if (!fence_planning_controller_input_allowed())
{
    exit;
}

fence_planning_controller_update_preview(
    id,
    window_mouse_get_x(),
    window_mouse_get_y()
);

if (input_lock_frames > 0)
{
    input_lock_frames -= 1;
    exit;
}

if (keyboard_check_pressed(ord("G")))
{
    fence_planning_controller_toggle_mode(id);
    exit;
}

if (keyboard_check_pressed(vk_escape))
{
    fence_planning_controller_cancel(id);
    exit;
}

if (keyboard_check_pressed(ord("F")))
{
    fence_planning_controller_commit(id);
    exit;
}

if (mouse_check_button_pressed(mb_right)
&& fence_planning_controller_remove(id))
{
    exit;
}

if (mouse_check_button_pressed(mb_left)
&& fence_planning_controller_place(id))
{
    exit;
}
