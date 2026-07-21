/// obj_tree_controller - Step Event

if (gameplay_is_paused()) exit;

if (!records_pruned)
{
    tree_records_prune_stale_current_room();
    records_pruned = true;
}

if (tree_regeneration_update() > 0)
{
    save_write();
}
