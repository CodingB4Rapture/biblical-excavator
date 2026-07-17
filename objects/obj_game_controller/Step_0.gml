/// obj_game_controller - Step Event

if (gameplay_is_paused()) exit;

if (variable_global_exists("save_restore_pending") && global.save_restore_pending)
{
    save_restore_room_state();
    global.save_restore_pending = false;
}

gameplay_ensure_controllable_actor();
cabin_restore_site();

if (variable_global_exists("save_new_game_pending") && global.save_new_game_pending)
{
    // Wait until all room instances exist, then create the first usable save.
    save_write();
    global.save_new_game_pending = false;
}

if (keyboard_check_pressed(ord("Q")) && !instance_exists(obj_quest_menu))
{
    instance_create_depth(0, 0, -5000, obj_quest_menu);
    exit;
}

if (keyboard_check_pressed(ord("B")) && !instance_exists(obj_cabin_placement_controller))
{
    cabin_begin_placement();

    if (instance_exists(obj_cabin_placement_controller))
    {
        exit;
    }
}

if (keyboard_check_pressed(vk_escape) && !instance_exists(obj_pause_menu))
{
    // Draw after the HUD and dialogue, while staying in a normal UI depth.
    instance_create_depth(0, 0, -5000, obj_pause_menu);
}
