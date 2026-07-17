/// obj_log - Create Event

game_state_ensure();

resource_id = ResourceId.TIMBER_LOG;
pullable_state = PullableState.FREE;
tow_vehicle = noone;
tow_pull_speed = 1.1;

block_radius = 34;
notice_time = game_get_speed(gamespeed_fps) * 3;
notice_cooldown = 0;

blocked_message = "You remember someone saying:\ \ 'You can't just drive over that log, kid.' ";
blocked_hint = "Press 'E' to Hop out and check what's blocking you.";
inspect_hint = "Walk over to the log and press 'E' to inspect it.";

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
