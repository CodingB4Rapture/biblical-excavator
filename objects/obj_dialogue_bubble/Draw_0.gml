/// obj_dialogue_bubble - Draw Event

var fade_in = min(1, (life_max - life) / 12);
var fade_out = min(1, life / 20);
var bubble_alpha = min(fade_in, fade_out);

var source_x = x;
var source_y = y;
var bubble_x = clamp(source_x, bubble_width * 0.5 + 6, room_width - bubble_width * 0.5 - 6);
var bubble_y = clamp(source_y - 36, bubble_height + 6, room_height - 6);

var bubble_left = bubble_x - bubble_width * 0.5;
var bubble_top = bubble_y - bubble_height;
var bubble_right = bubble_x + bubble_width * 0.5;
var bubble_bottom = bubble_y;

var text_margin = 10;
var panel_color = make_color_rgb(45, 34, 24);
var border_dark = make_color_rgb(70, 45, 20);
var border_gold = make_color_rgb(210, 156, 54);
var text_color = make_color_rgb(255, 237, 196);

draw_set_alpha(bubble_alpha);

draw_set_color(border_dark);
draw_roundrect(bubble_left, bubble_top, bubble_right, bubble_bottom, false);

draw_set_color(border_gold);
draw_roundrect(bubble_left + 2, bubble_top + 2, bubble_right - 2, bubble_bottom - 2, false);

draw_set_color(panel_color);
draw_roundrect(bubble_left + 5, bubble_top + 5, bubble_right - 5, bubble_bottom - 5, false);

draw_set_color(border_dark);
draw_triangle(
    bubble_x - 9,
    bubble_bottom - 4,
    bubble_x + 9,
    bubble_bottom - 4,
    source_x,
    source_y - 13,
    false
);

draw_set_color(border_gold);
draw_triangle(
    bubble_x - 6,
    bubble_bottom - 5,
    bubble_x + 6,
    bubble_bottom - 5,
    source_x,
    source_y - 16,
    false
);

draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(text_color);
draw_text_ext(
    bubble_left + text_margin,
    bubble_top + 9,
    message_text,
    10,
    bubble_width - text_margin * 2
);

draw_set_alpha(1);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(c_white);

