/// obj_log - Step Event

event_inherited();
if (gameplay_is_paused()) exit;
if (tree_world_id != "") tree_record_update_downed(tree_world_id, x, y, true);

