/// obj_pond - Create Event

// Match the original room asset layer while making the pond a world blocker.
depth = 100;
image_speed = 1;

// The pond sits against the south room edge, so its north bank is the
// consistent reachable interaction point.
interaction_enabled = true;
interaction_radius = 30;
interaction_priority = 24;
interaction_x = x;
interaction_y = y - 54;

interaction_get_prompt = function(_actor)
{
    return inventory_get_amount(
        game_state_read().player_inventory,
        ResourceId.EMPTY_BUCKET
    ) > 0
        ? "Fill Bucket at Pond"
        : "Pond";
};

interaction_run = function(_actor)
{
    var game_state = game_state_ensure();
    if (inventory_get_amount(
        game_state.player_inventory,
        ResourceId.EMPTY_BUCKET
    ) <= 0)
    {
        notification_show_hint(
            water_tutorial_is_active(game_state)
                ? "Make an Empty Bucket at the lathe, then collect it from the middle chest."
                : "Bring an Empty Bucket to draw water.",
            game_get_speed(gamespeed_fps) * 4,
            false
        );
        return;
    }

    if (!water_fill_bucket_state(game_state))
    {
        notification_show_hint(
            "You cannot carry another filled bucket.",
            game_get_speed(gamespeed_fps) * 3,
            false
        );
        return;
    }

    notification_show_hint(
        "Bucket filled. Take it to the water tank.",
        game_get_speed(gamespeed_fps) * 4,
        true
    );
    save_write();
};
