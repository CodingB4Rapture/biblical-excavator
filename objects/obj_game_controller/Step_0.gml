/// obj_game_controller - Step Event

if (gameplay_is_paused()) exit;

if (variable_global_exists("save_restore_pending") && global.save_restore_pending)
{
    save_restore_room_state();
    global.save_restore_pending = false;
}

gameplay_ensure_controllable_actor();

if (variable_global_exists("save_new_game_pending") && global.save_new_game_pending)
{
    // Wait until all room instances exist, then create the first usable save.
    save_write();
    global.save_new_game_pending = false;
}

if (keyboard_check_pressed(vk_escape) && !instance_exists(obj_pause_menu))
{
    // Draw after the HUD and dialogue, while staying in a normal UI depth.
    instance_create_depth(0, 0, -5000, obj_pause_menu);
}
