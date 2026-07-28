/// obj_water_tank - Create Event

depth = 100;
image_speed = 0;
interaction_enabled = true;
interaction_radius = 30;
interaction_priority = 30;
interaction_x = x + 16;
interaction_y = y + 56;

collision_blocker = instance_create_depth(
    x,
    y,
    10000,
    obj_world_collision_blocker
);
collision_blocker.mask_index = sprite_index;
collision_blocker.collision_owner = "room1.water_tank";

interaction_get_prompt = function(_actor)
{
    var game_state = game_state_read();
    var amount_text = string(game_state.water_tank_amount)
        + "/"
        + string(WATER_TANK_CAPACITY);
    return inventory_get_amount(
        game_state.player_inventory,
        ResourceId.WATER_BUCKET
    ) > 0
        ? "Pour Water into Tank (" + amount_text + ")"
        : "Water Tank (" + amount_text + ")";
};

interaction_run = function(_actor)
{
    var game_state = game_state_ensure();

    if (game_state.water_tank_amount >= WATER_TANK_CAPACITY)
    {
        notification_show_hint(
            "The water tank is full: "
                + string(WATER_TANK_CAPACITY)
                + "/"
                + string(WATER_TANK_CAPACITY)
                + ".",
            game_get_speed(gamespeed_fps) * 3,
            false
        );
        return;
    }

    if (inventory_get_amount(
        game_state.player_inventory,
        ResourceId.WATER_BUCKET
    ) <= 0)
    {
        notification_show_hint(
            "Bring a filled Water Bucket from the pond.",
            game_get_speed(gamespeed_fps) * 3,
            false
        );
        return;
    }

    var was_tutorial_active = water_tutorial_is_active(game_state);
    if (!water_deposit_bucket_state(game_state))
    {
        notification_show_hint(
            "Make room to take the Empty Bucket back.",
            game_get_speed(gamespeed_fps) * 3,
            false
        );
        return;
    }

    var amount_text = string(game_state.water_tank_amount)
        + "/"
        + string(WATER_TANK_CAPACITY);
    if (was_tutorial_active
    && game_state.water_tutorial_stage == WaterTutorialStage.COMPLETE)
    {
        notification_show_hint(
            task_get_status(TaskId.PLACE_CABIN, game_state)
                == TaskStatus.CLAIMED
                ? "Water stored: "
                    + amount_text
                    + ". You drink your fill. Rest at the cabin when ready."
                : "Water stored: "
                    + amount_text
                    + ". You drink your fill. Claim the cabin task, then rest.",
            game_get_speed(gamespeed_fps) * 6,
            true
        );
    }
    else
    {
        notification_show_hint(
            "Water stored: " + amount_text + ".",
            game_get_speed(gamespeed_fps) * 3,
            true
        );
    }
    save_write();
};
