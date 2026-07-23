/// obj_game_controller - Step Event

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

if (gameplay_is_paused()) exit;

if (variable_global_exists("save_restore_pending") && global.save_restore_pending)
{
    save_restore_room_state();
    global.save_restore_pending = false;
    fence_room_restored = false;
}

if (!instance_exists(obj_fieldstone_controller))
{
    instance_create_depth(0, 0, 1000, obj_fieldstone_controller);
}

if (!instance_exists(obj_tree_controller))
{
    instance_create_depth(0, 0, 1000, obj_tree_controller);
}

gameplay_ensure_controllable_actor();
tutorial_ensure_winch_package();
cabin_restore_site();

if (!fence_room_restored)
{
    fence_restore_room();
    fence_room_restored = true;
}

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

if (instance_exists(obj_fence_planning_controller))
{
    exit;
}

var fence_toggle_ready = !variable_global_exists("fence_toggle_ready_at")
    || current_time >= global.fence_toggle_ready_at;

if (keyboard_check_pressed(ord("F"))
&& fence_toggle_ready
&& !dialogue_is_active()
&& !instance_exists(obj_quest_menu)
&& !instance_exists(obj_inventory_menu)
&& !instance_exists(obj_pause_menu)
&& !instance_exists(obj_cabin_placement_controller))
{
    instance_create_depth(0, 0, -800, obj_fence_planning_controller);
    notification_show_hint(
        "Fence planning: click two opposite corners, then press F to save.",
        game_get_speed(gamespeed_fps) * 4,
        false
    );
    exit;
}

if (keyboard_check_pressed(ord("Q"))
&& !instance_exists(obj_quest_menu)
&& !instance_exists(obj_inventory_menu)
&& !instance_exists(obj_cabin_placement_controller))
{
    instance_create_depth(0, 0, -5000, obj_quest_menu);
    exit;
}

if ((keyboard_check_pressed(ord("I")) || keyboard_check_pressed(vk_tab))
&& !instance_exists(obj_inventory_menu)
&& !instance_exists(obj_quest_menu)
&& !instance_exists(obj_cabin_placement_controller))
{
    instance_create_depth(0, 0, -5000, obj_inventory_menu);
    exit;
}

if (keyboard_check_pressed(ord("B")) && !instance_exists(obj_cabin_placement_controller))
{
    var game_state = game_state_ensure();
    var allow_relocate = game_state.cabin_site_placed
        && game_state.homestead_stage == HomesteadStage.FIRST_REST_REQUIRED;

    cabin_begin_placement(allow_relocate);

    if (instance_exists(obj_cabin_placement_controller))
    {
        exit;
    }
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
