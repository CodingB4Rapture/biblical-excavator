/// obj_quest_menu - Create Event

selected_quest = QuestId.FIRM_FOUNDATION;
list_scroll = 0;
quest_row_height = 32;

// Prefer the currently active quest when the journal eventually contains many.
for (var quest_id = 0; quest_id < QuestId.COUNT; quest_id++)
{
    if (quest_get_status(quest_id) == QuestStatus.ACTIVE)
    {
        selected_quest = quest_id;
        break;
    }
}

// Step and Draw use one shared layout so click targets always match the art.
quest_menu_get_layout = function()
{
    var gui_w = display_get_gui_width();
    var gui_h = display_get_gui_height();
    var margin = 14;
    var panel_left = margin;
    var panel_top = margin;
    var panel_right = gui_w - margin;
    var panel_bottom = gui_h - margin;
    var list_width = clamp((panel_right - panel_left) * 0.32, 150, 230);

    return {
        gui_w: gui_w,
        gui_h: gui_h,
        panel_left: panel_left,
        panel_top: panel_top,
        panel_right: panel_right,
        panel_bottom: panel_bottom,
        list_left: panel_left + 8,
        list_right: panel_left + list_width,
        content_top: panel_top + 48,
        content_bottom: panel_bottom - 34,
        detail_left: panel_left + list_width + 12
    };
};

gameplay_set_paused(true);
