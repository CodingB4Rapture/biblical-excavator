/// obj_skills_menu - Step Event

var move = keyboard_check_pressed(vk_down)
    - keyboard_check_pressed(vk_up);
if (move != 0)
{
    selected_skill = (
        selected_skill + move + SkillId.COUNT
    ) mod SkillId.COUNT;
}

var layout = player_menu_get_skills_layout();
var mouse_x_gui = device_mouse_x_to_gui(0);
var mouse_y_gui = device_mouse_y_to_gui(0);
var row_height = min(
    72,
    (layout.content_bottom - layout.content_top)
        / max(1, SkillId.COUNT)
);
if (mouse_check_button_pressed(mb_left)
&& point_in_rectangle(
    mouse_x_gui,
    mouse_y_gui,
    layout.list_left,
    layout.content_top,
    layout.list_right,
    layout.content_top + row_height * SkillId.COUNT
))
{
    selected_skill = clamp(
        floor((mouse_y_gui - layout.content_top) / row_height),
        0,
        SkillId.COUNT - 1
    );
}
