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

gameplay_set_paused(true);
