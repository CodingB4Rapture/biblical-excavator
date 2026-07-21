# Quest System

## Quest 1: A Firm Foundation

This quest is the complete introductory gameplay loop:

1. Speak with the Farmer.
2. Receive the first task from the Farmer's Wife.
3. Collect 6 small Fieldstones by hand and receive the axe.
4. Chop the marked tree and inspect its downed tree and stump.
5. Crush 10 Fieldrocks with the work vehicle and deliver all 16 Fieldstones.
6. Receive and install the winch attachment.
7. Winch the downed tree into Home Delivery as a Timber Log.
8. Winch the stump into Home Delivery as Small Lumber.

The quest begins after the player reaches the final page of the Farmer's first
conversation. A centered banner announces its start. Delivering the Timber Log
reveals the final stump objective; delivering the stump as Small Lumber finishes
the quest and displays a centered completion banner.

Completing the quest records these rewards in the journal:

- Cabin Site Plan
- Cabin Placement Unlocked

The Farmer's Wife then says, "Now you've got the supplies to build your own
cabin!" Finishing her dialogue opens cabin-site placement. Move the mouse to
choose a 16-pixel-grid position, left-click a clear green area to confirm, or
use right-click/Escape to cancel. Press `B` later to resume placement.

The placed 64 x 64 marker is deliberately a construction site rather than a
finished cabin. Its room and position are saved. Future crafting work can turn
that site into readable construction stages without rewriting Quest 1.

Press `Q` during gameplay to open the Quest Journal. `Q` or Escape closes it.
The journal pauses gameplay and uses a reusable two-pane layout:

- The left pane is a clickable and keyboard-navigable quest list.
- Red quest names have not started, yellow quests are active, and green quests
  are complete.
- The right pane shows the selected quest's summary, objectives, and rewards.
- Completed quests retain a checked objective history and use their completion
  summary to explain what the player accomplished.

The list supports mouse-wheel scrolling and Up/Down navigation, so future
quests only need a `QuestId`, definition, status entry, and objective provider;
they do not need a custom journal object.

Press `I` or `Tab` to open the separate Inventory menu. It pauses gameplay and
reads Backpack, Vehicle, Homebase, and Tools data without owning those values.

Quest status is included in `save_slot_1.json`. Older version-one saves infer
the first quest's status from their tutorial stage.

Crafting, general skills, and skill trees intentionally begin after this quest.
They should be planned as their own systems instead of being embedded in the
tutorial quest code.
