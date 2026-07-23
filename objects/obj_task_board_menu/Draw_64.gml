/// obj_task_board_menu - Draw GUI Event

draw_set_font(-1);

var layout = task_board_menu_get_layout();
var definition = task_get_definition(selected_task);
var status = task_get_status(selected_task);
var objectives = task_get_objectives(selected_task);
var panel_color = make_color_rgb(39, 30, 23);
var panel_edge = make_color_rgb(79, 50, 25);
var panel_gold = make_color_rgb(224, 169, 73);
var text_color = make_color_rgb(247, 229, 198);
var muted_color = make_color_rgb(191, 171, 139);

draw_set_alpha(0.74);
draw_set_color(make_color_rgb(14, 11, 9));
draw_rectangle(0, 0, layout.gui_w, layout.gui_h, false);

draw_set_alpha(0.98);
draw_set_color(panel_edge);
draw_roundrect(
    layout.panel_left,
    layout.panel_top,
    layout.panel_right,
    layout.panel_bottom,
    false
);
draw_set_color(panel_gold);
draw_roundrect(
    layout.panel_left + 2,
    layout.panel_top + 2,
    layout.panel_right - 2,
    layout.panel_bottom - 2,
    true
);
draw_set_color(panel_color);
draw_roundrect(
    layout.panel_left + 6,
    layout.panel_top + 6,
    layout.panel_right - 6,
    layout.panel_bottom - 6,
    false
);

draw_set_alpha(1);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(make_color_rgb(255, 216, 112));
draw_text(
    layout.panel_left + 16,
    layout.panel_top + 14,
    "HOMESTEAD TASK BOARD"
);

draw_set_color(make_color_rgb(92, 66, 39));
draw_line(
    layout.list_right + 7,
    layout.content_top,
    layout.list_right + 7,
    layout.content_bottom
);

var visible_rows = max(
    1,
    floor(
        (layout.content_bottom - layout.content_top)
            / task_row_height
    )
);
for (var row = 0; row < visible_rows; row++)
{
    var order_index = list_scroll + row;
    if (order_index >= array_length(task_order)) break;
    var task_id = task_order[order_index];

    var row_top = layout.content_top + row * task_row_height;
    var row_status = task_get_status(task_id);
    var status_color = make_color_rgb(130, 117, 96);

    if (row_status == TaskStatus.AVAILABLE)
        status_color = make_color_rgb(225, 181, 79);
    if (row_status == TaskStatus.ACTIVE)
        status_color = make_color_rgb(255, 220, 92);
    if (row_status == TaskStatus.COMPLETE)
        status_color = make_color_rgb(139, 205, 112);
    if (row_status == TaskStatus.CLAIMED)
        status_color = make_color_rgb(103, 168, 96);

    if (order_index == selected_row)
    {
        draw_set_color(make_color_rgb(66, 52, 38));
        draw_roundrect(
            layout.list_left,
            row_top + 2,
            layout.list_right,
            row_top + task_row_height - 3,
            false
        );
    }

    draw_set_color(status_color);
    draw_circle(
        layout.list_left + 11,
        row_top + task_row_height * 0.5,
        4,
        false
    );
    draw_text(
        layout.list_left + 22,
        row_top + 8,
        task_get_definition(task_id).title
    );
    draw_set_color(muted_color);
    draw_text(
        layout.list_left + 22,
        row_top + 24,
        task_get_status_text(task_id)
    );
}

var detail_width = layout.panel_right - layout.detail_left - 20;
var status_color = make_color_rgb(130, 117, 96);
if (status == TaskStatus.AVAILABLE)
    status_color = make_color_rgb(225, 181, 79);
if (status == TaskStatus.ACTIVE)
    status_color = make_color_rgb(255, 220, 92);
if (status == TaskStatus.COMPLETE)
    status_color = make_color_rgb(139, 205, 112);
if (status == TaskStatus.CLAIMED)
    status_color = make_color_rgb(103, 168, 96);

draw_set_color(status_color);
draw_text(layout.detail_left, layout.content_top, definition.title);
draw_set_halign(fa_right);
draw_text(
    layout.panel_right - 18,
    layout.content_top,
    task_get_status_text(selected_task)
);
draw_set_halign(fa_left);

draw_set_color(text_color);
var summary_text = status >= TaskStatus.COMPLETE
    ? definition.completion_summary
    : definition.summary;
draw_text_ext(
    layout.detail_left,
    layout.content_top + 28,
    summary_text,
    15,
    detail_width
);

var objective_top = layout.content_top + 102;
draw_set_color(make_color_rgb(255, 216, 112));
draw_text(layout.detail_left, objective_top, "OBJECTIVES");

for (var objective_index = 0;
    objective_index < array_length(objectives);
    objective_index++)
{
    var objective = objectives[objective_index];
    draw_set_color(
        objective.complete
            ? make_color_rgb(151, 194, 126)
            : text_color
    );
    draw_text(
        layout.detail_left + 4,
        objective_top + 24 + objective_index * 20,
        (objective.complete ? "[x] " : "[ ] ") + objective.text
    );
}

var reward_top = objective_top + 42
    + array_length(objectives) * 20;
draw_set_color(make_color_rgb(255, 216, 112));
draw_text(layout.detail_left, reward_top, "REWARD");
draw_set_color(text_color);

for (var reward_index = 0;
    reward_index < array_length(definition.reward_labels);
    reward_index++)
{
    draw_text(
        layout.detail_left + 4,
        reward_top + 22 + reward_index * 18,
        "- " + definition.reward_labels[reward_index]
    );
}

var action_text = "LOCKED";
if (status == TaskStatus.AVAILABLE) action_text = "ACCEPT TASK";
if (status == TaskStatus.ACTIVE) action_text = "TASK ACTIVE";
if (status == TaskStatus.COMPLETE) action_text = "CLAIM / ARCHIVE";
if (status == TaskStatus.CLAIMED) action_text = "COMPLETED";

draw_set_color(make_color_rgb(83, 55, 29));
draw_roundrect(
    layout.action_left,
    layout.action_top,
    layout.action_right,
    layout.action_bottom,
    false
);
draw_set_color(status_color);
draw_roundrect(
    layout.action_left + 2,
    layout.action_top + 2,
    layout.action_right - 2,
    layout.action_bottom - 2,
    true
);
draw_set_halign(fa_center);
draw_set_valign(fa_middle);
draw_set_color(text_color);
draw_text(
    (layout.action_left + layout.action_right) * 0.5,
    (layout.action_top + layout.action_bottom) * 0.5,
    action_text
);

draw_set_halign(fa_right);
draw_set_valign(fa_bottom);
draw_set_color(make_color_rgb(242, 195, 128));
draw_text(
    layout.action_right,
    layout.action_top - 6,
    action_message
);

draw_set_halign(fa_center);
draw_set_color(muted_color);
draw_text(
    layout.gui_w * 0.5,
    layout.panel_bottom - 12,
    "Up/Down or click to select    Enter/Space to act    E or Escape to close"
);

draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(c_white);
