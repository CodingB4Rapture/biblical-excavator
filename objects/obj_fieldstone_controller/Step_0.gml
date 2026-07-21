/// obj_fieldstone_controller - Step Event

if (gameplay_is_paused()) exit;

if (!records_pruned)
{
    fieldstone_records_prune_stale_current_room();
    records_pruned = true;
}

if (fieldstone_regeneration_update() > 0)
{
    save_write();
}
