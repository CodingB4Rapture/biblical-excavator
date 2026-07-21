/// obj_pullable_parent - Create Event

pullable_state = PullableState.FREE;
tow_vehicle = noone;
tow_pull_speed = 1;
tow_vehicle_speed_multiplier = 0.65;
block_radius = 24;
notice_time = game_get_speed(gamespeed_fps) * 3;
notice_cooldown = 0;

interaction_enabled = true;
interaction_radius = 30;
interaction_priority = 20;
interaction_get_prompt = function(_actor)
{
    return winch_get_target_prompt(id, _actor);
};
interaction_run = function(_actor)
{
    winch_interact_with_target(id, _actor);
};
