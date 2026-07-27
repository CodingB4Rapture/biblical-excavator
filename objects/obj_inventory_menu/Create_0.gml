/// obj_inventory_menu - Create Event

inventory_categories = [
    "BACKPACK",
    "VEHICLE",
    "HOMEBASE",
    "TOOLS"
];
inventory_resource_rows = [
    ResourceId.FIELDSTONE,
    ResourceId.TIMBER_LOG,
    ResourceId.SMALL_LUMBER,
    ResourceId.TIMBER_PLANK
];
selected_category = 0;

gameplay_set_paused(true);
