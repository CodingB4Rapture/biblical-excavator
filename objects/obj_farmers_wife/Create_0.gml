/// obj_farmers_wife - Create Event

game_state_ensure();

interaction_enabled = true;
interaction_radius = 32;
interaction_priority = 50;

interaction_get_prompt = function(_actor)
{
    return farmers_wife_get_interaction_prompt(id, _actor);
};

interaction_run = function(_actor)
{
    farmers_wife_run_interaction(id, _actor);
};
