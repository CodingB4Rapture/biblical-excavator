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

function fence_restore_room()
{
    var game_state = game_state_ensure();
    var room_name = room_get_name(room);
    var records = fence_records_for_room(
        game_state.fence_records,
        room_name
    );
    fence_refresh_room_instances(records, false, true);
    return array_length(records);
}

/// Asset-layer fence art has no collision instance of its own. Rebuild these
/// mask-backed blockers with the room so the visual yard boundary is physical.
function room_reconcile_farmyard_perimeter()
{
    with (obj_world_collision_blocker)
    {
        if (variable_instance_exists(id, "collision_owner")
        && collision_owner == "farmyard")
        {
            instance_destroy();
        }
    }

    with (obj_gate_overpass)
    {
        if (variable_instance_exists(id, "overpass_owner")
        && overpass_owner == "farmyard")
        {
            instance_destroy();
        }
    }

    if (room != Room1) return;

    var add_blocker = function(_x, _y, _mask)
    {
        var blocker = instance_create_depth(
            _x,
            _y,
            10000,
            obj_world_collision_blocker
        );
        blocker.mask_index = _mask;
        blocker.collision_owner = "farmyard";
    };

    add_blocker(336, 16, spr_top_left_fence_corner);
    add_blocker(816, 16, spr_top_right_fence_corner);
    add_blocker(336, 144, spr_left_fence_corner);
    add_blocker(816, 144, spr_right_fence_corner);

    for (var back_x = 368; back_x <= 784; back_x += 32)
    {
        add_blocker(back_x, 16, spr_back_fence);
    }

    for (var side_y = 48; side_y <= 112; side_y += 32)
    {
        add_blocker(336, side_y, spr_leftside_fence);
        add_blocker(816, side_y, spr_rightside_fence);
    }

    for (var front_x = 368; front_x <= 528; front_x += 32)
    {
        add_blocker(front_x, 144, spr_front_fence);
    }

    for (var front_x = 624; front_x <= 752; front_x += 32)
    {
        add_blocker(front_x, 144, spr_front_fence);
    }

    var gate_overpass = instance_create_depth(576, 144, -25, obj_gate_overpass);
    gate_overpass.overpass_owner = "farmyard";
}

function room_reconcile_current()
{
    cabin_restore_site();
    fence_restore_room();
    room_reconcile_farmyard_perimeter();
    room_reconcile_winch_package();
}
