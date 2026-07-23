# Biblical Excavator - Focused Architecture Refactor Prompt

> Historical specification: the focused refactor was implemented in July 2026.
> Do not run this prompt again against the current project. See
> `docs/FOCUSED_REFACTOR.md` for the resulting ownership model and regression
> checklist.

## Prompt

Work in my existing GameMaker project at:

`C:\Users\sethj\GameMakerProjects\biblical-excavator`

Perform a focused architecture refactor of Biblical Excavator without changing its intended gameplay, map layout, art, balance, dialogue, tutorial order, controls, or save outcomes.

The current early-game vertical slice has passed a human end-to-end playtest. Treat the current behavior as the acceptance baseline. Preserve all user-made room edits and assets, including the pond, resource placements, Fieldstone spawn areas, NPC positions, and cabin-site behavior. The worktree may contain unrelated or uncommitted user changes; inspect it first and do not overwrite or revert them.

### Primary objectives

1. Separate game-state ownership from inventory helpers.
   - Create a dedicated `game_state_helpers` script/resource.
   - Move `game_state_create_default`, `game_state_ensure`, homestead-stage inference/sanitization, and closely related state-schema logic out of `resource_inventory_helpers`.
   - Keep resource definitions and inventory operations in `resource_inventory_helpers`.
   - Preserve all existing values, capacities, enum IDs, and fallback behavior.

2. Introduce explicit save migrations.
   - Move from the current format version 1 to format version 2.
   - Keep existing version-one saves readable.
   - Add a clear migration pipeline such as `save_migrate_v1_to_v2` and a single entry function that migrates older data before hydration.
   - Centralize optional-field defaults instead of scattering compatibility checks through the loader.
   - Separate snapshot creation, JSON file I/O, migration, state hydration, and room-instance restoration into clearly named functions or scripts.
   - Preserve the current deliberate rules: transient hints and animation frames are not saved; an active winch cable restores safely as stowed; tree/log/stump positions and regeneration schedules remain durable.

3. Centralize tutorial transitions.
   - Add a small tutorial transition API, for example `tutorial_get_stage`, `tutorial_set_stage`, `tutorial_try_advance`, and/or event-reporting functions.
   - Systems should report facts such as fieldstone collected, tree felled, delivery completed, package collected, cable attached, and stump delivered.
   - Avoid having unrelated systems assign `game_state.tutorial_stage` directly when a tutorial helper can own the transition.
   - Keep the exact current tutorial order, prompts, quest objectives, guidance targets, restrictions, autosave points, and legacy enum numeric values.
   - Do not attempt a large generic quest framework or data-driven dialogue rewrite during this pass.

4. Split regeneration by resource family.
   - Separate Fieldstone spawn-area logic from Fieldrock persistence/respawn logic.
   - Keep tree persistence and regrowth in its existing tree-focused module unless a small shared utility clearly reduces duplication.
   - A coordinator may call the separate modules, but it should not contain each resource's full lifecycle.
   - Preserve current timing: Fieldstone rerolls at noon, Fieldrocks return after one in-game day, and trees return three days after both physical pieces are delivered.

5. Finish the Fieldrock naming cleanup.
   - Rename `obj_rock_controller` to `obj_fieldrock_controller` and update the GameMaker resource metadata and all references.
   - Do not rename valid legacy save keys or world IDs unless a migration explicitly preserves them.

### Guardrails

- Do not rewrite the project from scratch.
- Do not replace working GameMaker objects with an unrelated framework.
- Do not reorder enum values that are persisted in saves.
- Do not remove compatibility code until its behavior is represented by a migration.
- Do not change resource capacities, interaction radii, vehicle physics, winch lengths, XP values, spawn chances, respawn delays, or tutorial requirements.
- Do not move room instances or modify sprites, fonts, sounds, tiles, paths, or visual assets.
- Preserve `obj_interactable_parent`, `obj_pullable_parent`, the controller pattern, and the existing small object-event style where they are working well.
- Keep GameMaker `.yyp`, `.yy`, and folder metadata consistent when adding or renaming resources.
- Use small, reviewable edits. Compile after every structural phase.
- If a current behavior is ambiguous, inspect the code and documentation and preserve what the passing build does. Ask before making a design change.

### Required workflow

1. Audit first.
   - Read `git status` and identify user-owned changes.
   - Map the current dependencies among game state, inventory, save/load, tutorial, regeneration, controllers, and UI.
   - Record the baseline compile command and current save format.

2. Refactor in phases.
   - Phase A: game-state extraction.
   - Phase B: save version 2 plus v1 migration.
   - Phase C: tutorial transition API and call-site cleanup.
   - Phase D: regeneration split and Fieldrock controller rename.
   - Do not mix gameplay feature additions into these phases.

3. Verify each phase.
   - Compile the GameMaker project.
   - Search for stale resource names and direct tutorial-stage assignments.
   - Confirm all newly added resources are present in the project metadata.
   - Preserve room instance counts and user placements.

4. Save compatibility verification.
   - Back up or copy an existing v1 save before testing migration.
   - Test New Game.
   - Test Continue from a v1 save.
   - Test saving as v2 and loading it again.
   - Verify backpack, vehicle, Homebase inventory, axe, winch, tutorial/quest status, player/vehicle positions, tree pieces, Fieldstone records, Fieldrock records, cabin site, day/time, and settings.

5. Human checkpoints.
   - Stop after the save migration compiles and provide a concise playtest checklist for v1 Continue and v2 re-save.
   - After that checkpoint passes, finish the remaining phases.
   - At the end, provide one clean end-to-end regression checklist. Do not claim the refactor is fully accepted until I report the human playtest result.

### Completion criteria

- The game compiles and starts.
- Existing v1 saves migrate successfully to v2.
- New v2 saves reload successfully.
- The tutorial, resource loop, chopping, towing, delivery, cabin placement, calendar, and regeneration behave exactly as before.
- Game-state schema and validation no longer live in the inventory helper.
- Save migrations are explicit and centralized.
- Tutorial stage changes are owned by tutorial helpers except for clearly documented initialization/migration cases.
- Fieldstone and Fieldrock regeneration logic are in separate modules.
- `obj_rock_controller` has been cleanly renamed to `obj_fieldrock_controller`.
- Documentation is updated to match the resulting filenames, save version, and ownership boundaries.

### Final report

When finished, give me:

- a summary of each refactor phase;
- every added, renamed, and materially changed file;
- the v1-to-v2 migration rules;
- compile/test results;
- the human playtest checklist;
- any remaining technical debt that was deliberately left out of scope.
