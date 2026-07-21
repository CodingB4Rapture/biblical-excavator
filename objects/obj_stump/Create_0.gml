/// obj_stump - Create Event

event_inherited();
if (!variable_instance_exists(id, "tree_world_id")) tree_world_id = "";

world_id = tree_world_id + "_stump";
resource_id = ResourceId.SMALL_LUMBER;
tow_pull_speed = 0.95;
tow_vehicle_speed_multiplier = 0.72;
block_radius = 12;

interaction_radius = 28;
interaction_priority = 27;
interaction_run = function(_actor)
{
    if (tutorial_report_felled_tree_inspected()) return;
    winch_interact_with_target(id, _actor);
};

image_speed = 0;
