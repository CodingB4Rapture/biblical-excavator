/// obj_skidsteer_parking_pad - Step Event

var game_state = game_state_ensure();

if (!task_is_active(TaskId.PARK_SKIDSTEER, game_state))
{
    stable_frames = 0;
    exit_hint_shown = false;
    exit;
}

var vehicle = instance_find(obj_skidsteer, 0);

if (!instance_exists(vehicle))
{
    stable_frames = 0;
    exit;
}

var fully_inside = skidsteer_parking_pad_contains(id, vehicle);
var stopped = skidsteer_is_nearly_stopped(vehicle);
var tow_clear = skidsteer_has_no_tow_target(vehicle);

if (fully_inside && stopped && tow_clear && vehicle.has_driver)
{
    stable_frames = 0;

    if (!exit_hint_shown)
    {
        notification_show_hint(
            "Parked. Press E to hop out and finish the task.",
            game_get_speed(gamespeed_fps) * 5,
            true
        );
        exit_hint_shown = true;
    }
    exit;
}

if (!fully_inside || !stopped || !tow_clear)
{
    stable_frames = 0;
    if (!fully_inside) exit_hint_shown = false;
    exit;
}

if (vehicle.has_driver)
{
    stable_frames = 0;
    exit;
}

stable_frames += 1;

if (stable_frames >= required_stable_frames
&& progression_complete_skidsteer_parking_state(game_state))
{
    notification_show_hint(
        "Objective complete — return to the Task Board.",
        game_get_speed(gamespeed_fps) * 5,
        true
    );
    save_write();
}
