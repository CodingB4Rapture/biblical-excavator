/// obj_wife - Create Event
///
/// The wife presents and manages deliveries. The durable Homebase inventory
/// stays in game_state so it is never tied to this room instance.

game_state_ensure();

interaction_enabled = true;
interaction_radius = 32;
interaction_priority = 50;

interaction_get_prompt = function(_actor)
{
    return "Talk to Wife";
};

interaction_run = function(_actor)
{
    var dropoff = instance_find(obj_homebase_dropoff, 0);
    var delivery = progress_deliver_homebase(dropoff);
    var delivery_line = progress_get_delivery_line(delivery);

    if (delivery.total > 0)
    {
        progress_show_reward_summary(
            "Home Delivery",
            delivery_line
        );
    }

    if (progress_receive_winch_mail())
    {
        notification_show_dialogue(
            "A winch attachment came in the mail. I set it aside for the work vehicle.",
            id,
            game_get_speed(gamespeed_fps) * 6,
            NotificationStyle.PROMPT
        );

        notification_show_hint(
            "Walk to the vehicle and press E to install the winch attachment.",
            game_get_speed(gamespeed_fps) * 6,
            false
        );

        return;
    }

    if (delivery.total > 0)
    {
        notification_show_dialogue(
            "Thank you. I'll put these with our supplies.",
            id,
            game_get_speed(gamespeed_fps) * 3,
            NotificationStyle.PROMPT
        );

        if (!delivery.vehicle_was_in_zone)
        {
            notification_show_hint(
                "Park the vehicle inside the Home Delivery circle to unload its cargo.",
                game_get_speed(gamespeed_fps) * 4,
                false
            );
        }

        return;
    }

    var game_state = game_state_ensure();
    var empty_message = "Nothing to put away yet. Bring home whatever you can use.";

    if (game_state.winch_attachment_state == AttachmentState.INSTALLED)
    {
        empty_message = "The winch is ready. Large logs belong inside the delivery circle.";
    }

    notification_show_dialogue(
        empty_message,
        id,
        game_get_speed(gamespeed_fps) * 4,
        NotificationStyle.PROMPT
    );
};
