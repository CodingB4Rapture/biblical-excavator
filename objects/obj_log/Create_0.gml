/// obj_log - Create Event

event_inherited();
game_state_ensure();

if (!variable_instance_exists(id, "tree_world_id")) tree_world_id = "";

resource_id = ResourceId.TIMBER_LOG;
world_id = tree_world_id != ""
    ? tree_world_id + "_downed"
    : "world_log_" + room_get_name(room) + "_"
        + string(round(x)) + "_" + string(round(y));

var removed_by_legacy_id = tree_world_id == ""
    && round(x) == 384
    && round(y) == 64
    && save_world_id_is_removed("tutorial_log_1");

if (save_world_id_is_removed(world_id) || removed_by_legacy_id)
{
    instance_destroy();
    exit;
}

tow_pull_speed = tree_world_id == "" ? 1.1 : 0.65;
tow_vehicle_speed_multiplier = 0.52;
image_xscale = tree_world_id == "" ? 1 : -1;
image_speed = 0;

blocked_message = "You can't just drive over that downed tree.";
blocked_hint = "Hop out and inspect what is blocking the skidsteer.";
inspect_hint = "Walk to the downed tree and press E to inspect it.";

interaction_radius = 34;
interaction_priority = 28;
interaction_run = function(_actor)
{
    if (tree_world_id != "" && tutorial_report_felled_tree_inspected()) return;
    winch_interact_with_target(id, _actor);
};
