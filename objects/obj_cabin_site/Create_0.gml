/// obj_cabin_site - Create Event

interaction_enabled = true;
interaction_radius = 42;
interaction_priority = 18;

interaction_get_prompt = function(_actor)
{
    if (homestead_stage_get() == HomesteadStage.FIRST_REST_REQUIRED)
    {
        return "Rest and begin tomorrow";
    }

    return calendar_is_nighttime()
        ? "Sleep until morning"
        : "Rest at cabin";
};

interaction_run = function(_actor)
{
    cabin_sleep_until_morning(_actor);
};
