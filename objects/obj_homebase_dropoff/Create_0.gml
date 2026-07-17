/// obj_homebase_dropoff - Create Event

dropoff_radius = 64;

// The delivery circle is the practical unloading point. This keeps the Wife
// free to live elsewhere in the homestead instead of forcing her to stand on
// top of the parking spot.
interaction_enabled = true;
interaction_radius = dropoff_radius;
interaction_priority = 45;

interaction_get_prompt = function(_actor)
{
    return "Unload supplies";
};

interaction_run = function(_actor)
{
    var delivery = progress_deliver_homebase(id);
    var delivery_line = progress_get_delivery_line(delivery);
    var wife = instance_find(obj_farmers_wife, 0);
    var speaker = instance_exists(wife) ? wife : id;

    if (delivery.total > 0)
    {
        progress_show_reward_summary("Home Delivery", delivery_line);

        notification_show_dialogue(
            "Thank you. I'll put these with our supplies.",
            speaker,
            game_get_speed(gamespeed_fps) * 3,
            NotificationStyle.PROMPT
        );

        if (progress_receive_winch_mail())
        {
            notification_show_dialogue(
                "A winch attachment came in the mail. I set it aside for the work vehicle.",
                speaker,
                game_get_speed(gamespeed_fps) * 6,
                NotificationStyle.PROMPT
            );

            notification_show_hint(
                "Walk to the vehicle and press E to install the winch attachment.",
                game_get_speed(gamespeed_fps) * 6,
                false
            );
        }

        return;
    }

    notification_show_hint(
        "Park the vehicle inside this circle, exit it, then unload its cargo here.",
        game_get_speed(gamespeed_fps) * 3,
        false
    );
};

