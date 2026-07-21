/// obj_pullable_parent - Step Event

if (gameplay_is_paused()) exit;

if (notice_cooldown > 0) notice_cooldown -= 1;

if (pullable_state == PullableState.ATTACHED && !instance_exists(tow_vehicle))
{
    pullable_state = PullableState.FREE;
    tow_vehicle = noone;
}
