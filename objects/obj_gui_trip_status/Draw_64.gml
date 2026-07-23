/// obj_gui_trip_status - Draw GUI Event

draw_set_font(-1);

var gui_w = display_get_gui_width();
var gui_h = display_get_gui_height();
var game_state = game_state_ensure();
var vehicle = progress_get_vehicle();
var player = instance_find(obj_player, 0);
var home_dropoff = instance_find(obj_homebase_dropoff, 0);

var pocket_fieldstones = inventory_get_amount(
    game_state.player_inventory,
    ResourceId.FIELDSTONE
);

var vehicle_fieldstones = 0;
var vehicle_capacity = 0;

if (instance_exists(vehicle))
{
    vehicle_fieldstones = inventory_get_amount(
        vehicle.cargo_inventory,
        ResourceId.FIELDSTONE
    );

    vehicle_capacity = vehicle.cargo_inventory.capacity;
}

var home_fieldstones = inventory_get_amount(
    game_state.home_inventory,
    ResourceId.FIELDSTONE
);

var home_logs = inventory_get_amount(
    game_state.home_inventory,
    ResourceId.TIMBER_LOG
);

var home_small_lumber = inventory_get_amount(
    game_state.home_inventory,
    ResourceId.SMALL_LUMBER
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
var trip_heading = "";

switch (game_state.tutorial_stage)
{
    case TutorialStage.TALK_TO_FARMERS_WIFE: tutorial_text = "Talk to Farmer's Wife"; break;
    case TutorialStage.TRIP_ONE_HAND_FIELDSTONE:
        trip_label = "Trip 1 of 3";
        tutorial_text = "Collect 6 Fieldstones by hand ("
            + string(game_state.tutorial_fieldstones_collected) + "/6)";
        break;
    case TutorialStage.CHOP_TREE:
        trip_label = "Axe Work";
        tutorial_text = "Use the gifted axe on a standing tree";
        break;
    case TutorialStage.INSPECT_FALLEN_TREE:
        trip_label = "Axe Work";
        tutorial_text = "Inspect the fallen tree and stump";
        break;
    case TutorialStage.TRIP_TWO_VEHICLE_FIELDSTONE:
        trip_label = "Trip 2 of 3";
        tutorial_text = "Crush 10 Fieldrocks, then deliver all 16 Fieldstones";
        break;
    case TutorialStage.WINCH_PACKAGE_READY:
        trip_label = "Trip 3 of 3";
        tutorial_text = "Collect the winch package";
        break;
    case TutorialStage.WINCH_INSTALL_REQUIRED:
        trip_label = "Trip 3 of 3";
        tutorial_text = "Install the winch on the skidsteer";
        break;
    case TutorialStage.INSPECT_FIRST_LOG:
        trip_label = "Trip 3 of 3";
        tutorial_text = "Inspect the large log";
        break;
    case TutorialStage.TAKE_WINCH_CABLE:
        trip_label = "Trip 3 of 3";
        tutorial_text = "Take the cable from the rear hitch";
        break;
    case TutorialStage.ATTACH_CABLE_TO_LOG:
        trip_label = "Trip 3 of 3";
        tutorial_text = "Attach the cable to the log";
        break;
    case TutorialStage.HAUL_FIRST_LOG:
        trip_label = "Trip 3 of 3";
        tutorial_text = "Winch the log to Home Delivery";
        break;
    case TutorialStage.PULL_STUMP:
        trip_label = "Trip 3 of 3";
        tutorial_text = "Winch the stump to Home Delivery for Small Lumber";
        break;
    case TutorialStage.COMPLETE: trip_label = "Complete"; tutorial_text = "Cabin materials delivered"; break;
}

if (game_state.cabin_placement_unlocked && !game_state.cabin_site_placed)
{
    trip_label = "Cabin Site";
    tutorial_text = "Walk to your chosen spot, then press B";
}
else if (game_state.homestead_stage == HomesteadStage.FIRST_REST_REQUIRED)
{
    trip_label = "Cabin Site";
    tutorial_text = "Rest at the cabin site to begin morning";
}
else if (game_state.homestead_stage == HomesteadStage.HUB_OPEN
&& game_state.tutorial_stage == TutorialStage.COMPLETE)
{
    trip_label = "Homestead Day " + string(game_state.day_number);
    tutorial_text = "Homestead work can begin";
}

trip_heading = "Current Trip - " + trip_label;

var screen_margin = 22;
var trip_left = screen_margin;
var trip_right = trip_left + trip_panel_width;
var trip_bottom = gui_h - screen_margin;
var trip_top = trip_bottom - trip_panel_height;

var home_left = trip_right + panel_gap;
var home_right = home_left + home_panel_width;
var home_bottom = trip_bottom;
var home_top = home_bottom - home_panel_height;

// A narrow gameplay GUI cannot hold both cards side by side. Keep Current
// Trip anchored at bottom-left and stack Homebase directly above it.
if (home_right > gui_w - screen_margin)
{
    home_left = trip_left;
    home_right = trip_right;
    home_bottom = trip_top - panel_gap;
    home_top = home_bottom - home_panel_height;
}

var panel_color = make_color_rgb(21, 25, 24);
var panel_edge = make_color_rgb(74, 57, 30);
var panel_gold = make_color_rgb(196, 145, 49);
var text_color = make_color_rgb(235, 224, 198);
var accent_color = make_color_rgb(255, 220, 92);

if (calendar_should_run())
{
    var clock_left = screen_margin;
    var clock_top = 22;
    var clock_right = clock_left + 150;
    var clock_bottom = clock_top + 52;

    draw_set_alpha(0.92);
    draw_set_color(panel_edge);
    draw_roundrect(clock_left, clock_top, clock_right, clock_bottom, false);
    draw_set_color(panel_gold);
    draw_roundrect(clock_left + 2, clock_top + 2, clock_right - 2, clock_bottom - 2, true);
    draw_set_alpha(0.88);
    draw_set_color(panel_color);
    draw_roundrect(clock_left + 4, clock_top + 4, clock_right - 4, clock_bottom - 4, false);

    draw_set_alpha(1);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    draw_set_color(accent_color);
    draw_text(clock_left + 12, clock_top + 8, "Day " + string(game_state.day_number));
    draw_set_color(text_color);
    draw_text(clock_left + 12, clock_top + 27, calendar_get_time_text());
}

draw_set_alpha(0.92);

draw_set_color(panel_edge);
draw_roundrect(trip_left, trip_top, trip_right, trip_bottom, false);

draw_set_color(panel_gold);
draw_roundrect(trip_left + 2, trip_top + 2, trip_right - 2, trip_bottom - 2, true);

draw_set_alpha(0.88);
draw_set_color(panel_color);
draw_roundrect(trip_left + 4, trip_top + 4, trip_right - 4, trip_bottom - 4, false);

// Conversation takes visual priority beside Current Trip. The contextual
// Homebase card returns as soon as the dialogue closes.
if (show_homebase && !dialogue_is_active())
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
draw_text(trip_left + 12, trip_top + 10, trip_heading);

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
    trip_top + 70,
    "Backpack: " + string(pocket_fieldstones)
    + " / " + string(game_state.player_inventory.capacity)
);

draw_text(
    trip_left + 12,
    trip_top + 88,
    "Vehicle stone: " + string(vehicle_fieldstones)
    + " / " + string(vehicle_capacity)
);

draw_text(
    trip_left + 12,
    trip_top + 106,
    "Gathered: " + string(game_state.trip_rocks_gathered)
    + "    Trip XP: " + string(game_state.trip_xp_gained)
);

draw_set_color(accent_color);
draw_set_halign(fa_left);
draw_text(trip_left + 12, trip_top + 126, "[I/Tab] Inventory");

var journal_prompt = "[Q] Quest Journal";

if (game_state.cabin_placement_unlocked && !game_state.cabin_site_placed)
{
    journal_prompt += "    [B] Cabin Site";
}

draw_text(trip_left + 12, trip_top + 144, journal_prompt);

if (show_homebase && !dialogue_is_active())
{
    draw_set_color(accent_color);
    draw_text(home_left + 12, home_top + 10, "Homebase");

    draw_set_color(text_color);
    draw_text(
        home_left + 12,
        home_top + 32,
        "Stored: " + string(home_fieldstones) + " Fieldstone, "
        + string(home_logs) + " Logs, "
        + string(home_small_lumber) + " Small Lumber"
    );

    draw_text(
        home_left + 12,
        home_top + 50,
        "Cabin goal: " + string(home_fieldstones) + " / 16 stone, "
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
