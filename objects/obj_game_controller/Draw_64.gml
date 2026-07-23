/// obj_game_controller - Draw GUI Event
/// Full-screen day transition and daily summary.

if (!day_transition_active) exit;

var fade_in = clamp(day_transition_timer / day_transition_fade_frames, 0, 1);
var fade_out_start = day_transition_fade_frames + day_transition_hold_frames;
var fade_out = clamp(1 - ((day_transition_timer - fade_out_start) / day_transition_fade_frames), 0, 1);
var overlay_alpha = min(fade_in, fade_out);

var gui_w = display_get_gui_width();
var gui_h = display_get_gui_height();

draw_set_alpha(overlay_alpha);
draw_set_color(c_black);
draw_rectangle(0, 0, gui_w, gui_h, false);

// Keep the card hidden until the fade has almost covered the outgoing day.
var card_alpha = clamp((fade_in - 0.8) / 0.2, 0, 1) * fade_out;
draw_set_alpha(card_alpha);
draw_set_halign(fa_center);
draw_set_valign(fa_middle);
draw_set_font(Header_font);
draw_set_color(make_color_rgb(220, 170, 70));
draw_text(gui_w * 0.5, gui_h * 0.5 - 48, "Day " + string(day_transition_day));

draw_set_font(UI_font);
draw_set_color(make_color_rgb(255, 240, 208));
draw_text(gui_w * 0.5, gui_h * 0.5, "Resources gathered");

var summary = "";
for (var resource_id = 0; resource_id < ResourceId.COUNT; resource_id++)
{
    var amount = day_transition_resources[resource_id];
    if (amount <= 0) continue;
    if (summary != "") summary += "    ";
    summary += resource_get_name(resource_id) + ": " + string(amount);
}

if (summary == "") summary = "None";
draw_set_color(make_color_rgb(232, 209, 158));
draw_text(gui_w * 0.5, gui_h * 0.5 + 30, summary);

draw_set_alpha(1);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(c_white);
draw_set_font(-1);
