/// obj_quest_menu - Draw GUI Event

draw_set_font(-1);

var layout = quest_menu_get_layout();
var gui_w = layout.gui_w;
var gui_h = layout.gui_h;
var panel_left = layout.panel_left;
var panel_top = layout.panel_top;
var panel_right = layout.panel_right;
var panel_bottom = layout.panel_bottom;
var quest = quest_get_definition(selected_quest);
var objectives = quest_get_objectives(selected_quest);
var quest_locked = quest_get_status(selected_quest) == QuestStatus.LOCKED;
var quest_finished = quest_get_status(selected_quest) == QuestStatus.COMPLETE;

draw_set_alpha(0.72);
draw_set_color(make_color_rgb(14, 13, 11));
draw_rectangle(0, 0, gui_w, gui_h, false);

draw_set_alpha(0.98);
draw_set_color(make_color_rgb(70, 50, 27));
draw_roundrect(panel_left, panel_top, panel_right, panel_bottom, false);
draw_set_color(make_color_rgb(213, 164, 67));
draw_roundrect(panel_left + 2, panel_top + 2, panel_right - 2, panel_bottom - 2, true);
draw_set_color(make_color_rgb(31, 28, 23));
draw_roundrect(panel_left + 5, panel_top + 5, panel_right - 5, panel_bottom - 5, false);

draw_set_alpha(1);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(make_color_rgb(255, 220, 92));
draw_text(panel_left + 12, panel_top + 10, "QUEST JOURNAL");

// Left pane: reusable, scrollable quest list.
draw_set_color(make_color_rgb(66, 57, 43));
draw_line(layout.list_right + 5, layout.content_top, layout.list_right + 5, layout.content_bottom);

var visible_rows = max(1, floor((layout.content_bottom - layout.content_top) / quest_row_height));
for (var row = 0; row < visible_rows; row++)
{
    var quest_id = list_scroll + row;
    if (quest_id >= QuestId.COUNT) break;

    var row_top = layout.content_top + row * quest_row_height;
    var status = quest_get_status(quest_id);
    var status_color = make_color_rgb(194, 72, 61);
    if (status == QuestStatus.ACTIVE) status_color = make_color_rgb(232, 190, 65);
    if (status == QuestStatus.COMPLETE) status_color = make_color_rgb(105, 185, 102);

    if (quest_id == selected_quest)
    {
        draw_set_color(make_color_rgb(59, 53, 42));
        draw_roundrect(layout.list_left, row_top + 2, layout.list_right, row_top + quest_row_height - 2, false);
    }

    draw_set_color(status_color);
    draw_circle(layout.list_left + 10, row_top + quest_row_height * 0.5, 4, false);
    draw_set_color(status_color);
    draw_text(layout.list_left + 20, row_top + 9, quest_get_definition(quest_id).title);
}

// Right pane: selected quest details and permanent objective history.
var detail_left = layout.detail_left;
var detail_width = panel_right - detail_left - 14;
var status_color = make_color_rgb(194, 72, 61);
if (!quest_locked) status_color = make_color_rgb(232, 190, 65);
if (quest_finished) status_color = make_color_rgb(105, 185, 102);

draw_set_color(status_color);
draw_text(detail_left, layout.content_top, quest.title);
draw_set_halign(fa_right);
draw_text(panel_right - 14, layout.content_top, quest_get_status_text(selected_quest));
draw_set_halign(fa_left);

draw_set_color(make_color_rgb(210, 200, 177));
var summary_text = quest_finished ? quest.completion_summary : quest.summary;
draw_text_ext(detail_left, layout.content_top + 24, summary_text, 14, detail_width);

var objective_top = layout.content_top + 78;
draw_set_color(make_color_rgb(255, 220, 92));
draw_text(detail_left, objective_top, "OBJECTIVES");

for (var i = 0; i < array_length(objectives); i++)
{
    var objective = objectives[i];
    draw_set_color(objective.complete
        ? make_color_rgb(151, 194, 126)
        : make_color_rgb(238, 225, 195));
    draw_text(
        detail_left + 4,
        objective_top + 22 + i * 16,
        (objective.complete ? "[x] " : "[ ] ") + objective.text
    );
}

var rewards_top = objective_top + 28 + array_length(objectives) * 16;
draw_set_color(make_color_rgb(255, 220, 92));
draw_text(detail_left, rewards_top, quest_finished ? "REWARDS RECEIVED" : "REWARDS");
draw_set_color(make_color_rgb(238, 225, 195));
for (var reward_index = 0; reward_index < array_length(quest.rewards); reward_index++)
{
    draw_text(detail_left + 4, rewards_top + 18 + reward_index * 16, "- " + quest.rewards[reward_index]);
}

draw_set_halign(fa_center);
draw_set_valign(fa_bottom);
draw_set_color(make_color_rgb(232, 209, 158));
draw_text(gui_w * 0.5, panel_bottom - 8, "Click a quest or use Up/Down    Q or Escape to close");

draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(c_white);
