# Save System

The game currently uses one versioned JSON slot named `save_slot_1.json` in
GameMaker's local save area.

Saved data includes:

- tutorial stage and delivery progress;
- backpack, vehicle cargo, and Homebase inventories;
- player/on-foot state and player position;
- the current gameplay room (with `Room1` as a safe fallback);
- skidsteer position, direction, and driver state;
- removed Fieldstones and Fieldrocks;
- renewable Fieldstone marker presence and last daily roll;
- persistent Fieldrock spawn records and next available day;
- persistent standing-tree, downed-tree, and stump records and positions;
- delivered Timber Log and Small Lumber inventory totals;
- persistent axe ownership;
- winch unlock/install state;
- cabin-placement unlock state and the placed cabin site's room and position;
- homestead progression state (`TUTORIAL`, `FIRST_REST_REQUIRED`, or `HUB_OPEN`);
- the pending one-time first-hub-morning hint;
- Quest 1 status and its completed reward history;
- an unfinished Farmer or Farmer's Wife dialogue and its current page;
- fullscreen and master-volume settings.

Home Delivery and installing the winch autosave. The Escape pause menu also has
a manual Save command. A cable actively attached during a manual save is safely
restored as stowed; tree-derived downed trees and stumps keep their saved
locations through their tree records.

Fieldrock regeneration schedules and each tree record's `respawn_day` are
optional version-one fields. Earlier saves migrate without changing the format
number: legacy removed Fieldrocks receive a one-day renewal schedule, while a
fully delivered felled tree begins its normal three-day regrowth schedule.

Short-lived hints, reward popups, Fieldrock-breaking animation frames, and an active
winch cable are deliberately not saved. They safely restart or disappear while
the durable resource and quest progress remains intact.

The first-hub-morning hint only saves a pending/not-pending flag so sleeping,
saving, or loading around that transition cannot lose the nudge.

Older version-one saves that do not have `homestead_stage` infer it from durable
facts: no cabin site means tutorial, cabin site on Day 1 means first rest is
required, and a placed cabin site on a later day means the hub is open.
