# Save System

The game uses one versioned JSON slot named `save_slot_1.json` in GameMaker's
local save area. New saves use `format_version: 9`.

## Pipeline

Saving and loading have separate responsibilities:

```text
snapshot -> JSON file write
JSON file read -> migrate to current -> hydrate game state
-> enter saved room -> reconcile saved room instances
```

- `save_system` owns snapshots, file I/O, hydration, and scene-restoration
  coordination.
- `gameplay_session_helpers` owns pause state, actor recovery, and pending
  restore-room selection.
- `settings_helpers` owns runtime settings and save-slot settings updates.
- `world_removal_helpers` owns one-time removed-world-ID state.
- `save_data_helpers` owns plain array and inventory copy/apply utilities.
- `save_migration_helpers` owns pure version-to-version conversion.
- `game_state_helpers` owns defaults and structural normalization.
- `room_reconciliation_helpers` restores the cabin site, fences, and mailed
  winch package idempotently after a room becomes active.

## Durable data

Saved data includes:

- tutorial stage, dedicated tutorial counters, task-board handoff, quests, and
  task statuses;
- backpack, vehicle, Homebase, and Finished Crafts inventories;
- player/vehicle position, driver state, and current gameplay room;
- axe ownership, the axe-notching preference/count, and winch state;
- Fieldstone, Fieldrock, tree, log, and stump records and regeneration dates;
- removed world IDs and fence records;
- cabin unlock, skidsteer parking, cabin-site room/position, marked-fence and
  built-cabin state, homestead stage, day, and time;
- production jobs, completed-batch counters, crafted-item capacities, and
  cabin/fence blueprint metadata;
- append-only skill XP and safe authored-cutscene status/checkpoints;
- the water tutorial state and durable `0/40` tank amount;
- unfinished story or skill dialogue, including its selected choice;
- fullscreen and master-volume settings.

Short-lived hints, reward popups, animation frames, and an active winch cable
are deliberately not saved. An attached cable restores safely as stowed. Tree
pieces keep their durable positions through tree records.

## Migration

`save_migrate_v1_to_v2` runs before hydration and:

- adds the monotonic `tutorial_fieldrocks_crushed` fact;
- converts the stored-winched-package edge case to the install stage;
- expands quest data for `A Place of Your Own`;
- converts legacy tutorial/task hybrids into one `AVAILABLE` or `ACTIVE` task,
  archiving prior work without granting new rewards;
- restores the cabin-plan unlock for post-stump saves;
- maps old saved dialogue callback strings to stable versioned action IDs;
- supplies normalized scene and settings structures.

The migration covers the Wife-to-board handoff, active gathering, winch
sequence, post-stump/pre-cabin, and post-cabin checkpoints. A v2 save is never
continuously re-derived from tutorial progress after hydration.

`save_migrate_v2_to_v3` appends the parking and site-marking task IDs without
renumbering the six persisted v2 tasks. A v2 save with a placed cabin is treated
as already built and the inserted tasks are claimed. A pre-cabin v2 save is
routed to `Park the Skidsteer`.

`save_migrate_v3_to_v4` appends the boundary task and production state. It
routes pre-cabin saves through the workshop boundary without inventing planks,
while preserving already completed cabins.

`save_migrate_v4_to_v5` moves legacy hidden Homebase Timber Planks into visible
Finished Crafts exactly once, normalizes crafted capacities, preserves active
machine jobs, and repairs selected-site/blueprint state.

`save_migrate_v5_to_v6` moves legacy Equipment XP into the Heavy Equipment
skill and creates durable records for the rescue and axe cutscenes. Existing
story outcomes are inferred from tutorial progress and axe ownership so old
saves do not replay completed scenes. A scene saves only a stable checkpoint,
not an actor's in-between animation frame.

`save_migrate_v6_to_v7` credits the new Toolmanship XP values for hand-gathered
Fieldstones and the required tutorial tree without granting credit for work it
did not complete.

`save_migrate_v7_to_v8` moves Utility Vehicle Winches to Heavy Equipment Level
2, credits the new minimum XP for already-crushed tutorial Fieldrocks, and
creates the durable Toolmanship Level 2 axe-notching decision. It also repairs
the temporary development version of an active level-up dialogue if that old
winch page happened to be saved.

`save_migrate_v8_to_v9` appends the filled Water Bucket resource, the Farmer's
post-cabin water cutscene, and the durable tank/tutorial fields. Cabins still
waiting on their first rest resume at the water lesson with `10/40`.
Established Day 2 homesteads remain open and receive a completed lesson with
`11/40`, so an update never rolls them backward.

Hydration also has additive repair paths for missing production arrays,
partial cabin-site selection, authored site movement, old fence socket
metadata, and missing room instances. The exact active `Mark Cabin Site` save
with no selected site, zero flags, no fence, and no cabin remains actionable;
it does not auto-award a site or edit the player's live save during tests.

Older optional resource records remain supported. Legacy removed Fieldrocks
receive their one-day renewal schedule, and a fully delivered felled tree
receives its normal three-day regrowth schedule.

Home Delivery, task claims, placement, and installing the winch save at their
existing durable checkpoints. The pause menu retains manual Save.
