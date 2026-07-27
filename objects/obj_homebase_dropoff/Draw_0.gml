/// obj_homebase_dropoff - Draw Event

draw_set_font(-1);

var circle_fill = vehicle_inside_dropoff
    ? make_color_rgb(93, 134, 83)
    : make_color_rgb(92, 126, 70);
var circle_edge = vehicle_inside_dropoff
    ? make_color_rgb(235, 197, 88)
    : make_color_rgb(205, 158, 70);

draw_set_alpha(vehicle_inside_dropoff ? 0.24 : 0.16);
draw_set_color(circle_fill);
draw_circle(x, y, dropoff_radius, false);

draw_set_alpha(vehicle_inside_dropoff ? 0.9 : 0.72);
draw_set_color(circle_edge);
draw_circle(x, y, dropoff_radius, true);

var delivery_vehicle = progress_get_vehicle();
var delivery_label = "HOME DELIVERY";

if (instance_exists(delivery_vehicle))
{
    if (delivery_vehicle.has_driver)
    {
        delivery_label = vehicle_inside_dropoff
            ? "PARKED - EXIT, THEN USE CHEST"
            : "PARK SKIDSTEER HERE";
    }
    else if (vehicle_inside_dropoff)
    {
        delivery_label = "UNLOAD AT CHEST";
    }
}

draw_set_alpha(1);
draw_set_halign(fa_center);
draw_set_valign(fa_top);
draw_set_color(make_color_rgb(35, 29, 23));
draw_text_transformed(
    x + 1,
    y + dropoff_radius + 5,
    delivery_label,
    0.45,
    0.45,
    0
);
draw_set_color(make_color_rgb(244, 232, 203));
draw_text_transformed(
    x,
    y + dropoff_radius + 4,
    delivery_label,
    0.45,
    0.45,
    0
);

// Keep the parking circle beneath the physical delivery point. The second
// chest frame remains open until the interacting player leaves the zone.
var chest_frame = chest_open && sprite_get_number(spr_chest) > 1 ? 1 : 0;
draw_sprite_ext(
    spr_chest,
    chest_frame,
    chest_draw_x,
    chest_draw_y,
    chest_scale_x,
    chest_scale_y,
    0,
    c_white,
    1
);

draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_alpha(1);
draw_set_color(c_white);

