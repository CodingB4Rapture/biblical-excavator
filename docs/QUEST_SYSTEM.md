# Quest System

## Quest, task, and objective roles

- A **quest** is a larger story arc shown in the Quest Journal.
- A **task** is one board-sized assignment within a quest.
- An **objective** is a checklist item within a task.

The Task Board uses one explicit state flow:

```text
LOCKED -> AVAILABLE -> ACTIVE -> COMPLETE -> CLAIMED
```

Only one tutorial task can be `ACTIVE`. Every task must be accepted at the
board before its mechanics unlock. Gameplay events complete the active task;
completion never derives continuously from inventory or drawing code. A
completed task must be claimed at the board before the next assignment becomes
available.

## Quest 1: A Firm Foundation

`A Firm Foundation` contains five tasks:

1. `Fieldstone by Hand`
2. `A Fallen Tree`
3. `Stone Haul`
4. `Fit the Winch`
5. `Timber Delivery`

The Farmer starts the quest. The Farmer's Wife then posts the first assignment
and points the player to the Task Board. Claiming `Timber Delivery` completes
the quest, records the gathered foundation materials, unlocks the cabin plan,
and starts `A Place of Your Own`.

## Quest 2: A Place of Your Own

This quest contains three tasks:

1. `Park the Skidsteer`
2. `Mark the Cabin Site`
3. `Build the Cabin`

Parking requires the whole stopped skidsteer inside the visible pad, no tow
target, and the player on foot. Site marking uses a fixed 32-pixel-grid
enclosure around `spr_cabin_before` with exactly one front gate. Building
changes that same saved site to `spr_cabin_after`. Claiming the build task
completes the quest and allows the first rest.

## Ownership

Task definitions and reward descriptors live in `task_definition_helpers`.
Task status/objective models, structural compatibility, and atomic reward
application live in `task_read_model_helpers`, `task_state_helpers`, and
`task_reward_helpers` respectively. Quest definitions and journal models live
in `quest_definition_helpers` and `quest_read_model_helpers`.

Runtime writes go through `progression_state_helpers`. Compatibility commands
coordinate those transactions with `progression_effect_helpers` and enqueue
plain announcement descriptors. `progression_presentation_helpers` is the only
progression module that creates notice or hint presentation instances.

Small Equipment XP or Homebase-resource rewards can be attached to tasks.
Claiming first validates the complete reward array and applies nothing if any
entry is invalid. The current task payloads remain empty until their balance is
chosen. Story effects such as the axe, winch delivery, and cabin plan remain
explicit progression effects rather than duplicate task rewards.

The Quest Journal groups task summaries beneath their parent quest. The Task
Board shows detailed objectives and reward labels for one selected task. Both
lists support keyboard/mouse selection and wheel scrolling.

Quest and task state are saved in format version 3. Version-one saves migrate
through v2; v2 saves with an already placed cabin preserve that cabin as built
and claim the two newly inserted tutorial tasks. Pre-cabin saves resume at
`Park the Skidsteer`.

Task-start and task-complete presentations use a FIFO queue. Board actions can
queue multiple announcements, but none display until the board closes. A
claim-and-accept visit therefore presents completion and rewards before the new
task-start banner.

Press `Q` to open the Quest Journal. Press `E` at the board to open the Task
Board. Press `I` or `Tab` for the separate read-only Inventory menu.

Crafting, general skills, and skill trees remain outside this system.
