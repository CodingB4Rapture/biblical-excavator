/// obj_gui_trip_status - Draw GUI Event

draw_set_font(-1);

var gui_w = display_get_gui_width();
var game_state = game_state_ensure();
var vehicle = progress_get_vehicle();
var player = instance_find(obj_player, 0);
var home_dropoff = instance_find(obj_homebase_dropoff, 0);

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

// Homebase details are contextual. They appear only while the controlled
// character is actually inside the Home Delivery area.
var show_homebase = false;

if (instance_exists(home_dropoff))
{
    if (instance_exists(player))
    {
        show_homebase = point_distance(
            player.x,
            player.y,
            home_dropoff.x,
            home_dropoff.y
        ) <= home_dropoff.dropoff_radius;
    }
    else if (instance_exists(vehicle) && vehicle.has_driver)
    {
        show_homebase = point_distance(
            vehicle.x,
            vehicle.y,
            home_dropoff.x,
            home_dropoff.y
        ) <= home_dropoff.dropoff_radius;
    }
}

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

var screen_margin = 22;
var trip_right = gui_w - screen_margin;
var trip_left = trip_right - trip_panel_width;
var trip_top = 22;
var trip_bottom = trip_top + trip_panel_height;

var home_right = trip_left - panel_gap;
var home_left = home_right - home_panel_width;
var home_top = trip_top;

// A narrow gameplay GUI cannot hold both cards side by side. Keep them
// right-aligned and stack Homebase beneath Current Trip in that case.
if (home_left < screen_margin)
{
    home_left = trip_left;
    home_right = trip_right;
    home_top = trip_bottom + panel_gap;
}

var home_bottom = home_top + home_panel_height;

var panel_color = make_color_rgb(21, 25, 24);
var panel_edge = make_color_rgb(74, 57, 30);
var panel_gold = make_color_rgb(196, 145, 49);
var text_color = make_color_rgb(235, 224, 198);
var accent_color = make_color_rgb(255, 220, 92);

draw_set_alpha(0.92);

draw_set_color(panel_edge);
draw_roundrect(trip_left, trip_top, trip_right, trip_bottom, false);

draw_set_color(panel_gold);
draw_roundrect(trip_left + 2, trip_top + 2, trip_right - 2, trip_bottom - 2, true);

draw_set_alpha(0.88);
draw_set_color(panel_color);
draw_roundrect(trip_left + 4, trip_top + 4, trip_right - 4, trip_bottom - 4, false);

if (show_homebase)
{
    draw_set_alpha(0.92);
    draw_set_color(panel_edge);
    draw_roundrect(home_left, home_top, home_right, home_bottom, false);

    draw_set_color(panel_gold);
    draw_roundrect(home_left + 2, home_top + 2, home_right - 2, home_bottom - 2, true);

    draw_set_alpha(0.88);
    draw_set_color(panel_color);
    draw_roundrect(home_left + 4, home_top + 4, home_right - 4, home_bottom - 4, false);
}

draw_set_alpha(1);
draw_set_halign(fa_left);
draw_set_valign(fa_top);

draw_set_color(accent_color);
draw_text(trip_left + 12, trip_top + 10, "Current Trip - " + trip_label);

draw_set_color(text_color);
draw_text_ext(
    trip_left + 12,
    trip_top + 32,
    tutorial_text,
    16,
    trip_panel_width - 24
);

draw_text(
    trip_left + 12,
    trip_top + 64,
    "Backpack: " + string(pocket_rocks)
    + " / " + string(game_state.player_inventory.capacity)
);

draw_text(
    trip_left + 12,
    trip_top + 82,
    "Vehicle stone: " + string(vehicle_rocks)
    + " / " + string(vehicle_capacity)
);

draw_text(
    trip_left + 12,
    trip_top + 100,
    "Gathered: " + string(game_state.trip_rocks_gathered)
    + "    Trip XP: " + string(game_state.trip_xp_gained)
);

if (show_homebase)
{
    draw_set_color(accent_color);
    draw_text(home_left + 12, home_top + 10, "Homebase");

    draw_set_color(text_color);
    draw_text(
        home_left + 12,
        home_top + 32,
        "Stored: " + string(home_rocks) + " Fieldstone, "
        + string(home_logs) + " Logs"
    );

    draw_text(
        home_left + 12,
        home_top + 50,
        "Cabin goal: " + string(home_rocks) + " / 16 stone, "
        + string(home_logs) + " / 1 log"
    );

    draw_text(
        home_left + 12,
        home_top + 68,
        "Deliveries: " + string(game_state.completed_deliveries)
    );

    draw_text(
        home_left + 12,
        home_top + 86,
        "Winch: " + attachment_get_status_text()
    );
}

draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(c_white);
