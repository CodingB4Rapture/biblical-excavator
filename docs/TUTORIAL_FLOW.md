# Tutorial Flow

This document is the plain-language map for changing the tutorial.

## Ownership

- Resource collection and delivery facts:
  `scripts/resource_progress_helpers/resource_progress_helpers.gml`
- Objective event handling:
  `scripts/tutorial_progression_helpers/tutorial_progression_helpers.gml`
- Validated task, quest, stage, and story-state transitions:
  `scripts/progression_state_helpers/progression_state_helpers.gml`
- Command orchestration and explicit world effects:
  `scripts/progression_command_helpers/progression_command_helpers.gml` and
  `scripts/progression_effect_helpers/progression_effect_helpers.gml`
- Plain announcement descriptors and presentation consumption:
  `scripts/progression_announcement_helpers/progression_announcement_helpers.gml`
  and `scripts/progression_presentation_helpers/progression_presentation_helpers.gml`
- Read-only guidance descriptors:
  `scripts/tutorial_guidance_helpers/tutorial_guidance_helpers.gml`
- Post-cabin water state, derived next steps, and bucket/tank transactions:
  `scripts/water_supply_helpers/water_supply_helpers.gml`
- Missing durable room objects:
  `scripts/room_reconciliation_helpers/room_reconciliation_helpers.gml`

Winch mechanics remain in `winch_helpers`. Dialogue dispatch remains in
`dialogue_helpers`. Persisted enum IDs remain in `game_enums`.

## Player-facing sequence

The Task Board presents this sequence as three work chapters rather than one
undifferentiated list:

1. **Know the Land** - learn what the nearby ground can provide safely.
2. **Lay the Foundation** - recover the heavy stone and timber needed for a
   lasting cabin.
3. **Make a Home** - choose a site and turn those supplies into a visible
   homestead.

The chapters are presentation-only groupings. Existing task statuses, rewards,
cutscene triggers, save compatibility, and the one-active-task invariant remain
unchanged.

1. Start a new game. The authored rescue cutscene shows the Farmer finding the
   player unconscious through two eyelid blinks and staged approach movement,
   fading to the homestead, and greeting the player after they wake just west
   of the cabin door. `A Firm Foundation` starts when the greeting completes.
2. Talk to the Farmer's Wife; she posts the first board assignment.
3. Accept `Fieldstone by Hand` and gather six loose Fieldstones for 15
   Toolmanship XP each. The Farmer walks to the player and presents his
   notched axe through the reusable axe handoff cutscene. Then claim the task.
4. Accept `A Fallen Tree`, fell it for 25 Toolmanship XP, and inspect it. The
   tree raises Toolmanship to Level 2. The first dialogue congratulates the
   player; the second asks whether future trees should add notches to the axe.
   Then claim the task.
5. Accept `Stone Haul`, crush ten Fieldrocks, deliver all sixteen Fieldstones,
   and reach at least 100 Heavy Equipment XP. Its Level 2 dialogue unlocks
   Utility Vehicle Winches. Then claim the task to trigger the mailed winch.
6. Accept `Fit the Winch`, collect and install the attachment using the
   Heavy Equipment Level 2 unlock, then claim it.
7. Accept `Timber Delivery`, deliver the log and stump, then claim it.
8. `A Firm Foundation` completes and `A Place of Your Own` starts.
9. Accept `Park the Skidsteer`; park inside the pad, stop, detach any tow, exit,
   and claim the task.
10. Accept `Mark the Cabin Site`; take one corner flag at authored Site I or
    Site II. Selection and task completion happen atomically. Claim the task.
11. Accept `Build the Cabin Boundary`. Use the sawmill to turn the delivered
    Timber Log into Timber Planks, collect them from Finished Crafts, and use
    the sawmill recipes for 10 straight pieces, 4 corners, and 1 two-cell gate.
12. Collect each finished batch and fill the selected site's fixed blueprint
    sockets. Claim the boundary task after the complete enclosure and front
    gate reconcile.
13. Accept `Build the Cabin` and raise it. The thirsty player speaks, then the
    Farmer walks up to praise the day's work and explain the water supply.
14. Turn 1 Small Lumber into 1 Empty Bucket at the lathe, collect it from
    Finished Crafts, fill it at the pond, and pour it into the authored tank.
    Its durable counter starts at `10/40` and becomes `11/40`. The filled
    bucket returns to the player's inventory as an Empty Bucket.
15. Claim the cabin task. Open Skills with `Shift+S` or the authored left-rail
    button. Heavy Equipment XP
    comes from powered work, Toolmanship XP from hand-gathered Fieldstones and
    axe work, and Woodwork XP from timber construction rewards.
16. Rest at the finished cabin after the water lesson. The first rest advances
    to Day 2 at 6:00 AM,
    opens the homestead hub, completes active production jobs, and displays
    the persistent Day/Time card.

## Communication rules

World systems report facts. Progression validates the currently active task and
performs the durable transition. A completed task returns guidance to the Task
Board; claiming it applies its complete reward transaction and exposes the next
assignment.

The gameplay HUD names the broad work chapter and desired outcome. Exact
button-level actions remain contextual interaction prompts or temporary hints;
they are not promoted into separate narrative goals.

Task-start presentations queue while the board is open and play only after the
world is visible. The first task in a chapter introduces the chapter purpose;
later tasks use a smaller `NEXT STEP` framing. Completion banners appear at
chapter boundaries rather than after every claimed task. Objective completion
in the world still uses the smaller return-to-board hint.

Guidance returns a descriptor containing room, target kind, stable world ID
when available, coordinates, and label. `obj_tutorial_guidance` owns the world
marker and the labeled edge arrow. Guidance never advances progression or
creates objects.

Hand gathering, finding a tree, and powered stone collection use area-level
exploration guidance. The arrow leads toward useful ground and disappears once
the player enters that area, leaving nearby resources to be discovered.
Installation, delivery, construction, and winch interactions retain exact
guidance because those actions depend on a precise world object.

The room reconciler reconstructs the mailed winch package beside Home Delivery
when durable state requires it. Cabin and fence restoration use the same
idempotent room-change path.

`TutorialStage` numeric values are persisted and intentionally append-only.
Never compare their raw values for story order; use `tutorial_stage_rank` or an
explicit predicate.

## Safe editing rules

- Append persisted enum IDs; never reorder them.
- Add definitions and durable fields before adding presentation.
- Route runtime task, quest, stage, and story-unlock writes through progression.
- Complete tasks from gameplay events, not from Draw/status queries.
- Validate every reward before applying any reward.
- Keep guidance and journal/task read models free of world mutation.
- Add room restoration to the reconciler rather than a per-frame Draw query.
- Preserve the one-active-task invariant.
- Add a new migration before changing the format-9 schema incompatibly.
