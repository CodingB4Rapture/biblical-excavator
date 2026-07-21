/// obj_stump - Step Event

event_inherited();
if (gameplay_is_paused()) exit;
tree_record_update_stump(tree_world_id, x, y, true);
