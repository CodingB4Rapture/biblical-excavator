/// obj_task_board - Draw Event

var game_state = game_state_ensure();
var board_accent = game_state.task_board_unlocked
    ? make_color_rgb(226, 174, 77)
    : make_color_rgb(135, 118, 91);

draw_self();

world_draw_location_marker(
    x,
    y + 27,
    "TASK BOARD",
    board_accent,
    6
);

draw_set_alpha(1);
draw_set_color(c_white);
