/// obj_cabin_site - Create Event

interaction_enabled = true;
interaction_radius = 42;
interaction_priority = 18;

interaction_get_prompt = function(_actor)
{
    return "Inspect cabin construction site";
};

interaction_run = function(_actor)
{
    notification_show_hint(
        "Cabin site placed. Construction recipes are the next system.",
        game_get_speed(gamespeed_fps) * 4,
        false
    );
};
