# Extension Readiness

This document records the current ownership boundaries and the smallest safe
seams for water, repair, animal events, and NPC schedules. It describes code as
of save format 8.

## Ownership

| Concern | Owner |
| --- | --- |
| Defaults and normalization | `game_state_helpers`, with feature-specific normalization delegated to state helpers |
| Save snapshot/hydration | `save_system` and `save_data_helpers` |
| Version migration | `save_migration_helpers` |
| Progression commands/effects | `progression_command_helpers` and `progression_effect_helpers` |
| Task/quest definitions and read models | `task_*` and `quest_*` helpers |
| Production definitions/state/commands/read models/UI | the five `production_*` helper modules |
| Cabin sites and fence blueprints | `cabin_site_definition_helpers`, placement/build commands, fence record/topology helpers |
| Room reconstruction | `room_reconciliation_helpers` |
| Calendar/day transition | `calendar_helpers`; day transition explicitly finishes active production jobs |
| Persistent player overlay | `player_menu_presentation_helpers` draws the rail, player menu, then Day/Time |
| Interaction targeting/debounce | `player_interaction_helpers` and interaction lock helpers |
| Regeneration | resource-specific regeneration helpers coordinated by `resource_regeneration_helpers` |
| Skills | `skill_definition_helpers`, `skill_state_helpers`, `skill_command_helpers`, and `skill_read_model_helpers` |
| Authored cutscenes | `cutscene_definition_helpers`, durable cutscene state/commands, and `obj_cutscene_controller` |

The remaining ambiguity is legacy free-form fence planning versus authored
cabin blueprint placement. The former still supports compatibility/free build;
it must not become a second tutorial cabin path.

## Production registry

`production_machine_definitions` is the canonical machine registry. Each entry
owns stable ID, type, display name, authored room/location, object type, unlock
rule label, and recipe IDs. Durable default jobs and normalization iterate this
registry. Recipes intentionally remain single-input/single-output until an
implemented recipe requires a consistent schema migration.

Transaction order is validate recipe/unlock, validate machine and batch count,
validate all input, reserve input, install one durable job, save, complete each
batch once, deliver to its destination, and save at completion. Cancellation
refunds only unfinished batches. Day transition explicitly completes jobs.

## Persistent UI layer order

From low to high: world draw, gameplay HUD/trip status, modal player-menu
content, menu rail, persistent Day/Time card, dialogue, hints/notifications,
reward/quest announcements, and day-transition presentation. The Day/Time card
is drawn once by the player-menu overlay owner and stays visible above Quest,
Inventory, and Map. Layout regressions cover 1280x720, 1100x984, and 1920x1080.
Dialogue uses wrapped text, minimum 0.7 scale, and explicit line spacing;
dialogue-visible hints position above the dialogue panel.

## Water seam

The first reusable water slice is implemented. `water_supply_helpers` owns the
durable tank amount, the broad locked/active/complete tutorial state, a derived
next-step read model, and atomic bucket fill/deposit transactions. `obj_pond`
is the source, `obj_water_tank` is the destination, and saves migrate through
format 9. The normal bucket remains a stackable inventory resource because
each current bucket is identical and carries exactly one unit.

If later buckets gain individual wear, upgrades, ownership, or attachments,
promote them behind the same command seam into a dedicated
`container_state_helpers` schema keyed by stable equipment instance ID:

```text
{id, equipment_definition_id, owner_kind, owner_id, capacity, fill_kind, fill_amount}
```

A normal bucket has capacity 1. A future vehicle bucket is one attachment
record with capacity 10, never ten inventory buckets. Definition data owns
capacity and compatible fill kinds; durable state owns current fill and owner.
The filtration tank is a stable structure record with stored amount/capacity.

Commands should be `container_fill_from_source`, `container_empty_into_tank`,
and `equipment_attach_to_vehicle`. Each validates proximity/compatibility,
available capacity, and ownership before atomically changing source,
container, and destination state, then saving once. Presentation reads command
failure codes and must show a specific hint.

The implemented tutorial starts the tank at `10/40`, returns a filled bucket
to Empty Bucket after deposit, and unlocks first rest at `11/40`. The next
expansion seam is filtration, drinking/needs policy, and equipment-instance
containers; those additions should reuse the existing tank transaction rather
than hard-code new quest-specific inventory writes.

## Repair seam

Repairable structures should use their existing stable blueprint/world IDs.
Add a durable structure record:

```text
{id, kind, room_name, x, y, condition, damage, max_damage}
```

Append-only condition values are `INTACT`, `DAMAGED`, and `BROKEN`; definition
data owns repair cost per damage tier. A `structure_apply_damage` command
changes condition once. A `structure_repair` command validates the stable
record, proximity, recipe/cost, and carried or Homebase Timber Planks; it
removes all required planks atomically, restores condition, saves, and emits a
progression fact without directly completing a task.

Reconciliation selects intact/damaged/broken presentation and collision from
the durable record and never reapplies damage. The smallest next slice is one
authored fence piece damage fixture, one-plank repair, reload reconciliation,
insufficient-plank feedback, and no-double-consumption tests with a new
post-format-9 empty-record migration.

## Deferred work

Water filtration economy, drinking/needs simulation, the ten-unit vehicle
bucket, its forty-plank recipe,
attachment visuals, animal damage events, locusts/beavers, random destruction,
general NPC pathfinding, more complex NPC schedules, and time-based Farmer
dialogue are not implemented here. The Farmer now has one authored 3:00 PM
pond round trip and post-cutscene return routes. Future schedules must still
resolve dialogue by stable NPC identity/location fallback so progression never
depends on one coordinate.

## Verification and playtest

Automated suites run from `obj_main_menu` with
`BIBLICAL_FENCE_TESTS=1`, `BIBLICAL_TASK_TESTS=1`, and
`BIBLICAL_MENU_TESTS=1`. They use isolated state fixtures and must not edit the
live save. A human smoke test still needs both sites, every visible `E` failure
message, repeated-input debounce around dialogue/menus, player displacement
after construction, visual draw order at all three target sizes, save/reload
during each production recipe, and the complete Day 1-to-Day 2 playthrough.
