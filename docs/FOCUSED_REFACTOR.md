# Focused Refactor Result

The July 2026 refactor kept the existing GameMaker helper/controller/object
style and resolved the ten audited seams without introducing a generic
framework.

## Ten outcomes

1. All six tutorial tasks require board acceptance and only one can be active.
2. Cabin placement belongs to the separate `A Place of Your Own` quest.
3. `game_state_ensure` performs structural normalization only.
4. Persisted `TutorialStage` ordering uses `tutorial_stage_rank`, never raw
   numeric comparisons.
5. Task rewards validate as a complete transaction before anything is applied.
6. `tutorial_fieldrocks_crushed` is a dedicated monotonic objective fact.
7. Guidance returns read-only descriptors; `obj_tutorial_guidance` owns
   on-camera and off-camera rendering.
8. New saves use format version 2 and all v1 compatibility runs before
   hydration.
9. Room changes trigger idempotent restoration and ensure the Fieldstone,
   Fieldrock, tree, and guidance controllers. Fieldrock naming and resource
   lifecycle modules are now explicit.
10. The Task Board scrolls with keyboard, mouse selection, and the mouse wheel.

## Runtime ownership

| Module | Owns |
|---|---|
| `game_state_helpers` | Defaults and structural validation |
| `progression_helpers` | Runtime task, quest, stage, and story-unlock writes |
| `task_helpers` / `quest_helpers` | Definitions and read-only status/objective models |
| `tutorial_progression_helpers` | Validating gameplay facts against the active task |
| `tutorial_guidance_helpers` | Pure target descriptors |
| `obj_tutorial_guidance` | World marker and screen-edge arrow presentation |
| `room_reconciliation_helpers` | Cabin, fence, and winch-package restoration |
| `save_migration_helpers` | Pure v1-to-v2 conversion |
| `save_system` | Snapshot, JSON I/O, hydration, and scene restoration |
| resource-specific regeneration helpers | Fieldstone or Fieldrock lifecycle |

The intended extension path remains:

```text
definition -> durable state -> explicit progression event
-> guidance/read model -> object/UI presentation -> save
```

## Automated verification

The final GameMaker VM build completed successfully on July 23, 2026 with 468
compiled scripts and 40 object types. The automated run passed:

- 17 fence planning, validation, removal, sprite-selection, and persistence
  checks;
- 12 task, progression, reward, guidance, v1 migration, and v2 hydration
  checks;
- `git diff --check`.

## Human regression checklist

Automated tests cover state transitions, migration fixtures, reward atomicity,
edge-arrow math, v2 hydration, and the fence system. The following visual and
input checks still require a GameMaker playthrough:

1. Start New Game and confirm the Farmer sends the player to his wife.
2. Finish the Wife's dialogue; confirm guidance points to the board and no
   Fieldstones can be gathered before accepting.
3. Complete, return, claim, and accept each of the five `A Firm Foundation`
   tasks. Confirm guidance returns to the board between tasks.
4. During `Stone Haul`, confirm the board counts exactly ten crushed Fieldrocks
   and sixteen delivered Fieldstones.
5. Save/Continue before collecting the winch package and after collecting it;
   confirm exactly one actionable package/install beat.
6. Claim `Timber Delivery`; confirm Quest 1 completes, Quest 2 starts, and cabin
   placement remains blocked until its task is accepted.
7. Place the cabin site; confirm rest is blocked until the completed task is
   claimed, then confirm the first morning transition.
8. Move the objective outside every camera edge and confirm the labeled arrow
   points correctly without covering modal menus or dialogue.
9. Open a long Task Board list with keyboard and mouse-wheel input and confirm
   the selected row remains visible.
10. Continue one backed-up v1 save, save it as v2, relaunch, and Continue again.
    Verify inventories, axe, winch, actors, tree pieces, resources, fences,
    cabin, day/time, dialogue, and settings.

Do not call the refactor fully playtest-accepted until this checklist passes.
