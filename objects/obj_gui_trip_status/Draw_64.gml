/// obj_gui_trip_status - Draw GUI Event

if (cutscene_is_active()) exit;

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
var pocket_planks = inventory_get_amount(
    game_state.player_inventory,
    ResourceId.TIMBER_PLANK
);
var player_fieldstone_capacity = inventory_get_resource_capacity(
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

    vehicle_capacity = inventory_get_resource_capacity(
        vehicle.cargo_inventory,
        ResourceId.FIELDSTONE
    );
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

var trip_model = trip_status_get_read_model(
    game_state,
    vehicle,
    pocket_planks
);

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
draw_text(trip_left + 12, trip_top + 10, trip_model.heading);

draw_set_color(text_color);
var objective_line_sep = 16;
var objective_width = trip_panel_width - 24;
draw_text_ext(
    trip_left + 12,
    trip_top + 32,
    trip_model.objective,
    objective_line_sep,
    objective_width
);

var objective_height = string_height_ext(
    trip_model.objective,
    objective_line_sep,
    objective_width
);
var resource_top = max(70, 32 + objective_height + 6);

draw_text(
    trip_left + 12,
    trip_top + resource_top,
    "Backpack stone: " + string(pocket_fieldstones)
    + " / " + string(player_fieldstone_capacity)
);

draw_text(
    trip_left + 12,
    trip_top + resource_top + 18,
    "Vehicle stone: " + string(vehicle_fieldstones)
    + " / " + string(vehicle_capacity)
);

draw_text(
    trip_left + 12,
    trip_top + resource_top + 36,
    "Gathered: " + string(game_state.trip_rocks_gathered)
    + "    Trip XP: " + string(game_state.trip_xp_gained)
);

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

    var current_work_section = task_get_current_work_section(game_state);
    draw_text(
        home_left + 12,
        home_top + 68,
        "Work chapter: " + current_work_section.title
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
