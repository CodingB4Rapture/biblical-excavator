# Skills and Authored Cutscenes

The skill and cutscene foundations are content-driven systems. New content
should add definitions and call commands rather than putting progression state
writes in NPC or Draw events.

## Skills

Persisted `SkillId` values are append-only. Format 8 begins with:

1. Heavy Equipment
2. Toolmanship
3. Woodwork

Definitions own stable keys, display names, descriptions, maximum level, and
Biblical Excavation's steady mastery curve. The cap is level 50. Level 2
requires 100 total XP, and each next level costs 100 XP more than the previous
one. This creates these milestones:

- Level 2: 100 total XP
- Level 3: 300 total XP
- Level 10: 4,500 total XP
- Level 50: 122,500 total XP

Durable state owns only total XP:

```gml
skill_xp: array_create(SkillId.COUNT, 0)
```

Level and progress are read models calculated from XP; they are not saved.
Heavy Equipment mirrors the legacy `equipment_xp` field until old-save
compatibility references can be retired.

Each definition also owns an ordered `unlocks` array. A level-up queues a
dedicated dialogue after cutscenes and menus are clear. The first page reports
the new level; following pages describe every ability authored at that level.
The Skills menu previews the next unlock. Toolmanship Level 2 currently unlocks
an authored Yes/No prompt asking whether future safely felled trees should add
notches to the player's axe. The preference and notch count are durable.
Heavy Equipment Level 2 unlocks attaching winches to Utility Vehicles:
Skidsteers, Four-Wheelers, Horses, and Donkeys. Gameplay checks the unlock's
stable key rather than duplicating the level number in each vehicle.

Gameplay awards XP through `skill_award_xp` or, inside a larger atomic
transaction, `skill_award_xp_state`. Current sources are powered Fieldrock
crushing for Heavy Equipment; manual Fieldstone gathering and axe work for
Toolmanship; and timber construction rewards for Woodwork. A resource can
declare `hand_skill_id` and `hand_skill_xp` in its definition, so future
hand-mined materials use the same transaction instead of adding one-off object
code. Tutorial Fieldstones award 15 Toolmanship XP each and its required tree
awards 25, reaching Toolmanship Level 2 after the first tree. Tutorial
Fieldrocks award at least 10 Heavy Equipment XP each, guaranteeing Heavy
Equipment Level 2 by the tenth Fieldrock and before winch installation. The
dedicated Skills menu is opened with `Shift+S` or
`spr_skills_button` on the persistent rail. Plain `S` remains downward movement
on foot and reverse throttle in the skidsteer.

To add a skill:

1. Append its `SkillId`.
2. Append one definition.
3. Add XP commands at real completed gameplay transactions.
4. Add stable unlock descriptors to the definition.
5. Add optional `level_prompts` when a level needs a player decision.
6. Gate gameplay through `skill_unlock_is_available_state`.
7. Add read-model and migration regression expectations.
8. Never renumber existing IDs or save a separately mutable level.

## Authored cutscenes

A cutscene definition is an ordered list of reusable steps:

- lock player/menu input;
- fade;
- show a caption;
- reposition an actor at a safe boundary;
- request actor movement;
- focus the camera;
- show dialogue;
- wait;
- execute an idempotent command;
- save a safe checkpoint;
- complete.

Definitions do not change durable progression themselves.
`obj_cutscene_controller` interprets presentation steps, while
`cutscene_command_helpers` owns explicit story transactions. Actor names and
cutscene IDs are stable strings.

The movement step is deliberately behind `cutscene_actor_move_step`. It
currently supports slow authored/direct movement, an arrival radius, timeout,
and safe fallback. A later grid pathfinder can replace that function without
rewriting rescue, reward, quest, or update cutscene definitions.

Leading lock, actor-position, and camera steps are primed before the room can
draw. This prevents a one-frame glimpse of normal gameplay coordinates.
Alternating fade and wait steps can author eyelid blinks, unconsciousness,
dreams, or visions without adding scene-specific controller code.

Only meaningful checkpoints are saved. Reload restarts from the checkpoint
instead of trying to serialize a Farmer halfway between pixels. Command effects
remain idempotent: replaying the axe command leaves one owned axe.

## Implemented scenes

`story.intro_farmer_rescue.v1`:

1. Finds the player unconscious at the field edge.
2. Locks the camera on the player while the Farmer enters from beyond the shot.
3. Stages two Farmer approach legs, separated by full eyelid blinks and the
   player's `"...help"` plea.
4. Lets the Farmer respond with `"....."` before fading fully to black.
5. Repositions the player west of the homestead door and slowly reveals the
   wake-up greeting.
6. Starts `A Firm Foundation` through an explicit progression command.

`story.farmer_axe_handoff.v1`:

1. Begins after the sixth hand-gathered Fieldstone.
2. Moves the Farmer slowly to the player.
3. Plays the notched-handle faith story.
4. Grants the axe through one idempotent command.
5. Returns guidance to the Task Board.

`story.farmer_water_supply.v1`:

1. Stages the Farmer south of the selected cabin.
2. Walks him north to the cabin's front edge without crossing its sprite.
3. Begins the first water-supply lesson through an idempotent command.

When any current Farmer cutscene releases the camera and player controls, the
Farmer follows a transient route back to his authored home position. Once the
calendar is running, he also makes one daily round trip to the pond beginning
at 3:00 PM. He approaches from the pond's east lane and retraces that safe
route home after reaching the bank.

Future quest scenes should reuse these steps and add a new step type only when
real shipped content cannot be represented by the existing vocabulary.
