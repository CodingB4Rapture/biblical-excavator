/// Idempotent restoration for durable objects owned by the current room.
/// Guidance and status queries must never create world instances themselves.

function room_reconcile_winch_package()
{
    var game_state = game_state_ensure();
    if (game_state.tutorial_stage != TutorialStage.WINCH_PACKAGE_READY
    || game_state.winch_attachment_state != AttachmentState.MAIL_READY)
    {
        return noone;
    }

    var package_instance = instance_find(obj_winch_package, 0);
    if (instance_exists(package_instance)) return package_instance;

    var dropoff = instance_find(obj_homebase_dropoff, 0);
    if (!instance_exists(dropoff)) return noone;

    return instance_create_depth(
        dropoff.x + 52,
        dropoff.y,
        -20,
        obj_winch_package
    );
}

function room_reconcile_current()
{
    cabin_restore_site();
    fence_restore_room();
    room_reconcile_winch_package();
}
