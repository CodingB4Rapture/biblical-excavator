/// obj_quest_menu - Draw GUI Event

draw_set_font(-1);

var gui_w = display_get_gui_width();
var gui_h = display_get_gui_height();
var margin = 14;
var panel_left = margin;
var panel_top = margin;
var panel_right = gui_w - margin;
var panel_bottom = gui_h - margin;
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

draw_set_halign(fa_right);
draw_text(panel_right - 12, panel_top + 10, quest_get_status_text(selected_quest));

draw_set_halign(fa_left);
draw_set_color(make_color_rgb(247, 236, 207));
draw_text(
    panel_left + 12,
    panel_top + 30,
    quest_locked ? "No Active Quest" : quest.title
);

if (quest_locked)
{
    draw_set_color(make_color_rgb(210, 200, 177));
    draw_text_ext(
        panel_left + 12,
        panel_top + 52,
        "Finish speaking with the Farmer. Your first quest will begin when the conversation is complete.",
        14,
        panel_right - panel_left - 24
    );
}
else
{
    draw_set_color(make_color_rgb(210, 200, 177));
    draw_text_ext(panel_left + 12, panel_top + 48, quest.summary, 14, panel_right - panel_left - 24);

    if (quest_finished)
    {
        draw_set_color(make_color_rgb(151, 194, 126));
        draw_text(panel_left + 16, panel_top + 88, "[DONE] All 6 objectives completed");

        draw_set_color(make_color_rgb(255, 220, 92));
        draw_text(panel_left + 16, panel_top + 116, "REWARDS");

        draw_set_color(make_color_rgb(238, 225, 195));

        for (var reward_index = 0; reward_index < array_length(quest.rewards); reward_index++)
        {
            draw_text(
                panel_left + 20,
                panel_top + 136 + reward_index * 18,
                "- " + quest.rewards[reward_index]
            );
        }
    }
    else
    {
        var objective_top = panel_top + 84;

        for (var i = 0; i < array_length(objectives); i++)
        {
            var objective = objectives[i];
            draw_set_color(objective.complete
                ? make_color_rgb(151, 194, 126)
                : make_color_rgb(238, 225, 195));
            draw_text(
                panel_left + 16,
                objective_top + i * 18,
                (objective.complete ? "[DONE] " : "[ ] ") + objective.text
            );
        }
    }
}

draw_set_halign(fa_center);
draw_set_valign(fa_bottom);
draw_set_color(make_color_rgb(232, 209, 158));
draw_text(gui_w * 0.5, panel_bottom - 8, "Q or Escape to close");

draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(c_white);
