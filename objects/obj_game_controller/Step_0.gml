/// obj_game_controller - Step Event

player_menu_rail_ensure();

if (day_transition_active)
{
    day_transition_timer += 1;
    var transition_length = day_transition_fade_frames * 2 + day_transition_hold_frames;

    if (day_transition_timer >= transition_length)
    {
        day_transition_active = false;
        gameplay_set_paused(false);
        calendar_show_pending_hub_intro();
        save_write();
    }

    exit;
}

// Q/I/M/build/machine menus pause player movement, not workshop time. The
// actual pause overlay is the one state that freezes production.
if (!instance_exists(obj_pause_menu))
{
    production_update();
}

if (gameplay_is_paused()) exit;

if (variable_global_exists("save_restore_pending") && global.save_restore_pending)
{
    save_restore_room_state();
    global.save_restore_pending = false;
    room_reconcile_pending = true;
}

if (!instance_exists(obj_fieldstone_controller))
{
    instance_create_depth(0, 0, 1000, obj_fieldstone_controller);
}

if (!instance_exists(obj_tree_controller))
{
    instance_create_depth(0, 0, 1000, obj_tree_controller);
}

if (!instance_exists(obj_fieldrock_controller))
{
    instance_create_depth(0, 0, 1000, obj_fieldrock_controller);
}

if (!instance_exists(obj_tutorial_guidance))
{
    instance_create_depth(0, 0, -1300, obj_tutorial_guidance);
}

gameplay_ensure_controllable_actor();
var current_room_name = room_get_name(room);
if (reconciled_room_name != current_room_name)
{
    resource_regeneration_sync_room();
    reconciled_room_name = current_room_name;
    room_reconcile_pending = true;
}

if (room_reconcile_pending)
{
    room_reconcile_current();
    room_reconcile_pending = false;
}

progression_update_announcements();
calendar_update();

if (calendar_show_pending_hub_intro())
{
    save_write();
}

if (variable_global_exists("save_new_game_pending") && global.save_new_game_pending)
{
    // Wait until all room instances exist, then create the first usable save.
    save_write();
    global.save_new_game_pending = false;
}

if (instance_exists(obj_fence_planning_controller)
|| instance_exists(obj_build_placement_controller))
{
    exit;
}

if (keyboard_check_pressed(vk_escape)
&& !instance_exists(obj_pause_menu)
&& !instance_exists(obj_inventory_menu)
&& !instance_exists(obj_quest_menu)
&& !instance_exists(obj_cabin_placement_controller))
{
    // Draw after the HUD and dialogue, while staying in a normal UI depth.
    instance_create_depth(0, 0, -5000, obj_pause_menu);
}
