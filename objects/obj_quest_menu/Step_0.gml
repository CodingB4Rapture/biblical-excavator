/// obj_quest_menu - Step Event

if (keyboard_check_pressed(ord("Q")) || keyboard_check_pressed(vk_escape))
{
    gameplay_set_paused(false);
    instance_destroy();
}
