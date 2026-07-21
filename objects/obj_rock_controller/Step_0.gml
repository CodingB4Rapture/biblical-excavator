/// obj_rock_controller - Step Event

if (gameplay_is_paused()) exit;

if (!records_pruned)
{
    fieldrock_records_prune_stale_current_room();
    records_pruned = true;
}

if (fieldrock_regeneration_update() > 0)
{
    save_write();
}

