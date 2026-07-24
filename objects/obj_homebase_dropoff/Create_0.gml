/// obj_homebase_dropoff - Create Event

dropoff_radius = 64;
chest_open = false;
chest_open_actor = noone;
chest_scale_x = 2;
chest_scale_y = 1;
chest_center_x = x;
chest_center_y = y - dropoff_radius;
chest_width = sprite_get_width(spr_chest) * chest_scale_x;
chest_height = sprite_get_height(spr_chest) * chest_scale_y;
chest_draw_x = chest_center_x - chest_width * 0.5;
chest_draw_y = chest_center_y - chest_height * 0.5;

// The object remains at the delivery-circle center for vehicle/resource
// checks, while on-foot interaction follows the chest at the circle's top.
interaction_x = chest_center_x;
interaction_y = chest_center_y;

chest_blocker = instance_create_depth(
    chest_draw_x,
    chest_draw_y,
    10000,
    obj_world_collision_blocker
);
chest_blocker.sprite_index = spr_chest;
chest_blocker.mask_index = spr_chest;
chest_blocker.image_speed = 0;
chest_blocker.image_index = 0;
chest_blocker.image_xscale = chest_scale_x;
chest_blocker.image_yscale = chest_scale_y;
chest_blocker.collision_owner = "home_delivery";

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
    chest_open = true;
    chest_open_actor = _actor;

    var delivery = progress_deliver_homebase(id);
    var delivery_line = progress_get_delivery_line(delivery);
    var wife = instance_find(obj_farmers_wife, 0);
    var speaker = instance_exists(wife) ? wife : id;

    if (delivery.total > 0)
    {
        progress_show_reward_summary("Home Delivery", delivery_line);

        if (delivery.quest_completed)
        {
            notification_show_dialogue(
                [
                    "You've done wonderful work--there are enough supplies now to build your own cabin!",
                    "Choose a clear place for the cabin site, and we'll work through the construction together."
                ],
                speaker,
                0,
                NotificationStyle.PROMPT,
                "FARMER'S WIFE",
                DIALOGUE_ACTION_UNLOCK_CABIN
            );
            return;
        }

        notification_show_dialogue(
            "Thank you. I'll keep these safe with our supplies.",
            speaker,
            game_get_speed(gamespeed_fps) * 3,
            NotificationStyle.PROMPT
        );

        if (delivery.mail_became_ready)
        {
            notification_show_dialogue(
                "Good news--a winch attachment came in the mail. I left the package beside Home Delivery for you.",
                speaker,
                game_get_speed(gamespeed_fps) * 6,
                NotificationStyle.PROMPT
            );

            notification_show_hint(
                "Find the marked package and press E to collect it.",
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

