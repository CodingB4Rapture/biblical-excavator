/// obj_game_controller - Draw Event
/// One temporary tutorial arrow points to the next meaningful action.

if (gameplay_is_paused()
|| dialogue_is_active()
|| instance_exists(obj_quest_menu)
|| instance_exists(obj_pause_menu)
|| instance_exists(obj_cabin_placement_controller)) exit;

var guidance = tutorial_guidance_target();
if (!guidance.valid) exit;

var bob = sin(current_time * 0.008) * 3;
var arrow_x = guidance.x;
var arrow_tip_y = guidance.y - 20 + bob;
var arrow_top_y = arrow_tip_y - 14;

draw_set_alpha(0.45);
draw_set_color(make_color_rgb(92, 65, 12));
draw_triangle(arrow_x - 7, arrow_top_y + 2, arrow_x + 7, arrow_top_y + 2, arrow_x, arrow_tip_y + 2, false);

draw_set_alpha(1);
draw_set_color(make_color_rgb(255, 216, 64));
draw_triangle(arrow_x - 7, arrow_top_y, arrow_x + 7, arrow_top_y, arrow_x, arrow_tip_y, false);
draw_set_color(c_white);
