/// obj_gui_trip_status - Draw GUI Event

var game_state = game_state_ensure();
var vehicle = progress_get_vehicle();

var pocket_rocks = inventory_get_amount(
    game_state.player_inventory,
    ResourceId.FIELDSTONE
);

var vehicle_rocks = 0;
var vehicle_capacity = 0;

if (instance_exists(vehicle))
{
    vehicle_rocks = inventory_get_amount(
        vehicle.cargo_inventory,
        ResourceId.FIELDSTONE
    );

    vehicle_capacity = vehicle.cargo_inventory.capacity;
}

var home_rocks = inventory_get_amount(
    game_state.home_inventory,
    ResourceId.FIELDSTONE
);

var home_logs = inventory_get_amount(
    game_state.home_inventory,
    ResourceId.TIMBER_LOG
);

var tutorial_text = "Talk to the Farmer";
var trip_label = "Before Trip 1";

switch (game_state.tutorial_stage)
{
    case TutorialStage.TALK_TO_FARMERS_WIFE: tutorial_text = "Talk to Farmer's Wife"; break;
    case TutorialStage.TRIP_ONE_HAND_FIELDSTONE:
        trip_label = "Trip 1 of 3";
        tutorial_text = "Deliver 6 small fieldstones by hand";
        break;
    case TutorialStage.TRIP_TWO_VEHICLE_FIELDSTONE:
        trip_label = "Trip 2 of 3";
        tutorial_text = "Deliver 10 fieldstones by skidsteer";
        break;
    case TutorialStage.WINCH_READY:
        trip_label = "Trip 3 of 3";
        tutorial_text = "Install the winch attachment";
        break;
    case TutorialStage.HAUL_FIRST_LOG:
        trip_label = "Trip 3 of 3";
        tutorial_text = "Winch the log to Home Delivery";
        break;
    case TutorialStage.COMPLETE: trip_label = "Complete"; tutorial_text = "Cabin materials delivered"; break;
}

var panel_left = 22;
var panel_top = 22;
var panel_right = panel_left + panel_width;
var panel_bottom = panel_top + panel_height;

var panel_color = make_color_rgb(21, 25, 24);
var panel_edge = make_color_rgb(74, 57, 30);
var panel_gold = make_color_rgb(196, 145, 49);
var text_color = make_color_rgb(235, 224, 198);
var accent_color = make_color_rgb(255, 220, 92);

draw_set_alpha(0.92);

draw_set_color(panel_edge);
draw_roundrect(panel_left, panel_top, panel_right, panel_bottom, false);

draw_set_color(panel_gold);
draw_roundrect(panel_left + 2, panel_top + 2, panel_right - 2, panel_bottom - 2, true);

draw_set_alpha(0.88);
draw_set_color(panel_color);
draw_roundrect(panel_left + 4, panel_top + 4, panel_right - 4, panel_bottom - 4, false);

draw_set_alpha(1);
draw_set_halign(fa_left);
draw_set_valign(fa_top);

draw_set_color(accent_color);
draw_text(panel_left + 12, panel_top + 10, "Current Trip");

draw_set_color(accent_color);
draw_text(panel_left + 12, panel_top + 204, trip_label + ": " + tutorial_text);

draw_set_color(text_color);
draw_text(
    panel_left + 12,
    panel_top + 32,
    "Backpack: " + string(pocket_rocks)
    + " / " + string(game_state.player_inventory.capacity)
);

draw_text(
    panel_left + 12,
    panel_top + 50,
    "Vehicle stone: " + string(vehicle_rocks)
    + " / " + string(vehicle_capacity)
);

draw_text(
    panel_left + 12,
    panel_top + 68,
    "Gathered: " + string(game_state.trip_rocks_gathered)
);

draw_text(
    panel_left + 12,
    panel_top + 86,
    "Trip XP: " + string(game_state.trip_xp_gained)
);

draw_set_color(accent_color);
draw_text(panel_left + 12, panel_top + 110, "Homebase");

draw_set_color(text_color);
draw_text(
    panel_left + 12,
    panel_top + 132,
    "Stored: " + string(home_rocks) + " Fieldstone, "
    + string(home_logs) + " Logs"
);

draw_text(
    panel_left + 12,
    panel_top + 150,
    "Cabin goal: " + string(home_rocks) + " / 16 stone, "
    + string(home_logs) + " / 1 log"
);

draw_text(
    panel_left + 12,
    panel_top + 168,
    "Deliveries: " + string(game_state.completed_deliveries)
);

draw_text(
    panel_left + 12,
    panel_top + 186,
    "Winch: " + attachment_get_status_text()
);

draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(c_white);
