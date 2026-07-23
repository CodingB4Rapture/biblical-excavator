/// obj_task_board - Draw Event
/// Temporary readable sign; assigning a sprite replaces only this placeholder.

var game_state = game_state_ensure();
var board_accent = game_state.task_board_unlocked
    ? make_color_rgb(226, 174, 77)
    : make_color_rgb(135, 118, 91);

if (sprite_index != -1)
{
    draw_self();
}
else
{
    draw_set_color(make_color_rgb(74, 48, 28));
    draw_rectangle(x - 3, y + 5, x + 3, y + 25, false);
    draw_set_color(make_color_rgb(104, 68, 36));
    draw_roundrect(x - 18, y - 18, x + 18, y + 8, false);
    draw_set_color(board_accent);
    draw_roundrect(x - 16, y - 16, x + 16, y + 6, true);
    draw_set_color(make_color_rgb(47, 32, 23));
    draw_line(x - 11, y - 9, x + 11, y - 9);
    draw_line(x - 11, y - 4, x + 8, y - 4);
    draw_line(x - 11, y + 1, x + 10, y + 1);
}

world_draw_location_marker(
    x,
    y + 27,
    "TASK BOARD",
    board_accent,
    6
);

draw_set_alpha(1);
draw_set_color(c_white);
