# Tutorial Flow

This document is the plain-language map for changing the tutorial.

## Ownership

- Resource collection and delivery facts:
  `scripts/resource_progress_helpers/resource_progress_helpers.gml`
- Objective event handling:
  `scripts/tutorial_progression_helpers/tutorial_progression_helpers.gml`
- Task acceptance, completion, claims, quests, stages, and story unlocks:
  `scripts/progression_helpers/progression_helpers.gml`
- Read-only guidance descriptors:
  `scripts/tutorial_guidance_helpers/tutorial_guidance_helpers.gml`
- Missing durable room objects:
  `scripts/room_reconciliation_helpers/room_reconciliation_helpers.gml`

Winch mechanics remain in `winch_helpers`. Dialogue dispatch remains in
`dialogue_helpers`. Persisted enum IDs remain in `game_enums`.

## Player-facing sequence

1. Talk to the Farmer; `A Firm Foundation` starts.
2. Talk to the Farmer's Wife; she posts the first board assignment.
3. Accept `Fieldstone by Hand`, gather six loose Fieldstones, then claim it.
4. Accept `A Fallen Tree`, fell and inspect a tree, then claim it.
5. Accept `Stone Haul`, crush ten Fieldrocks, deliver all sixteen Fieldstones,
   then claim it to trigger the mailed winch.
6. Accept `Fit the Winch`, collect and install the attachment, then claim it.
7. Accept `Timber Delivery`, deliver the log and stump, then claim it.
8. `A Firm Foundation` completes and `A Place of Your Own` starts.
9. Accept `Park the Skidsteer`; park inside the pad, stop, detach any tow, exit,
   and claim the task.
10. Accept `Mark the Cabin Site`; choose the site, create the fixed boundary,
    add one front gate, and claim the task.
11. Accept `Build the Cabin`; build at the marked site and claim the task.
12. Rest at the finished cabin to open the first homestead day.

## Communication rules

World systems report facts. Progression validates the currently active task and
performs the durable transition. A completed task returns guidance to the Task
Board; claiming it applies its complete reward transaction and exposes the next
assignment.

Task start/completion presentations queue while the board is open and play only
after the world is visible. Objective completion in the world uses the smaller
return-to-board hint.

Guidance returns a descriptor containing room, target kind, stable world ID
when available, coordinates, and label. `obj_tutorial_guidance` owns the world
marker and the labeled edge arrow. Guidance never advances progression or
creates objects.

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
- Add v3 migration before changing the v2 schema incompatibly.
