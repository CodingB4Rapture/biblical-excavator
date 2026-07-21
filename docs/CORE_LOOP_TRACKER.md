# Core Loop Tracker

This is the plain-language reference for the current playable loop and the
places where art, tuning, and design decisions still belong to Seth.

## Current Playable Loop

1. Collect six small Fieldstones by hand and receive the axe.
2. Chop the standing tutorial tree, leaving a downed tree and stump.
3. Enter the skidsteer and crush Fieldrocks into Fieldstone cargo while gaining
   Equipment XP.
4. Park the vehicle inside `HOME DELIVERY`, exit, and unload all sixteen
   Fieldstones.
5. Collect and install the mailed winch.
6. Tow the downed tree into Home Delivery and unload it as a Timber Log.
7. Return for the stump and unload it as Small Lumber.

The backpack holds `6` items. The vehicle holds `10` loose Fieldstones.

## Winch Introduction

The first winch prototype deliberately uses no final attachment art.

1. Complete the sixteen-Fieldstone tutorial delivery.
2. The wife says that a winch attachment arrived by mail.
3. Walk to the vehicle and press `E` to install it.
4. Walk behind the vehicle and press `E` to take the cable.
5. Walk to the log and press `E` to attach it.
6. Return to the vehicle, enter it, and drive slowly.
7. Pull the log completely inside the Home Delivery circle.
8. Exit and use Home Delivery to record the log in Homebase storage.
9. Repeat the cable flow for the stump; Home Delivery converts it to Small Lumber.

The gold hitch dot and dark cable line are code-drawn placeholders.

## Inventory Ownership

- `game_state.player_inventory`: small items in the player's backpack.
- `obj_skidsteer.cargo_inventory`: loose material loaded in the vehicle.
- `obj_log`: remains a physical world object while attached to the winch.
- `obj_stump`: remains physical until Home Delivery converts it to Small Lumber.
- `game_state.home_inventory`: household supplies managed through the wife.

The player instance is destroyed while driving, so player inventory must never
be stored only on `obj_player`.

## Reusable Resource Pattern

Resource identity is declared in `ResourceId`. Behavior is described in
`resource_get_definition`.

To add a resource variety:

1. Add a `ResourceId` entry.
2. Add one readable definition with its name, size, and allowed transport.
3. Assign that ID to a pickup, crushable, or pullable world object.
4. Add its sprite and collision mask.

Inventory, Homebase, and winch code should not need a new special case unless
the resource introduces genuinely new behavior.

## Resource Regeneration

- Fieldrocks return at their original spawn after one in-game day.
- A tree schedules three-day regrowth only after both its downed tree and stump
  have been delivered.
- Due resources wait when their spawn point is occupied.
- The first six hand-collected Fieldstones prefer nearby spawn-area results;
  one-time tutorial stones are created nearby only as a fallback.
- Editor-placed `obj_fieldstone_spawn_area` markers generate persistent random
  candidate positions. One shared controller rerolls empty positions at noon,
  while only visible `obj_fieldstone` pickups exist at runtime. Fieldrocks
  remain the machine-gathered renewable Fieldstone source.

See `RESOURCE_REGENERATION.md` for persistence, map-edit migration, and tuning.

## Tuning Locations

Player tuning is in `objects/obj_player/Create_0.gml`:

- `move_speed`
- `interact_distance`
- backpack capacity is initialized in `game_state_ensure`

Vehicle and winch tuning is in `objects/obj_skidsteer/Create_0.gml`:

- `cargo_inventory` capacity
- `winch_hitch_distance`
- `winch_hitch_interact_radius`
- `winch_cable_length`
- `winch_tow_length`
- `winch_tow_speed_multiplier`

Log tuning is in `objects/obj_log/Create_0.gml`:

- `block_radius`
- `tow_pull_speed`

Stump tuning is in `objects/obj_stump/Create_0.gml` with its own pull speed,
vehicle multiplier, and smaller obstruction radius.

The first winch delivery is now tied to completing Tutorial Trip 2: sixteen
fieldstones stored at Homebase. See `FIRST_TUTORIAL_FLOW.md`.

## Human Checkpoints

Seth needs to evaluate these in GameMaker:

- Does `E` choose the object that feels obvious?
- Does the interaction distance feel too generous or too precise?
- Are backpack and vehicle capacities enjoyable?
- Does the winch arrive at the right moment after the Fieldstone delivery?
- Is the cable long enough to be convenient without feeling unlimited?
- Does towing feel heavy without becoming frustrating?
- Should speaking to the wife be required every trip, or should later upgrades
  allow quick unloading?

## Control Helpers

Shared keyboard input lives in
`scripts/player_interaction_helpers/player_interaction_helpers.gml`.

- `WASD` and arrow keys both drive movement.
- `E` is the shared interact/enter/exit vehicle button.
- Dialogue also accepts click, `E`, Enter, or Space. Ending dialogue briefly
  locks world interaction so the same `E` press does not reopen the NPC.
- `I` or `Tab` opens the Inventory menu; `Q` opens the Quest Journal.

## Art Still Needed

Mechanics can be tested before these assets exist:

- Wife idle and talking sprite.
- Installed winch or rear-hitch attachment sprite.
- Hook/cable end sprite.
- Backpack and Homebase resource icons.
- Delivery-yard environment art.

When vehicle attachment art is made, keep the hitch origin easy to identify.
The code currently treats the rear hitch as an offset from the vehicle origin,
so the art does not need to contain a permanently drawn cable.

## Next Review

Play the complete tutorial, install the attachment, tow both tree pieces home,
sleep through several homestead days, and confirm Fieldrocks and the delivered
tree renew at a comfortable pace. The next pass should tune this single vertical
slice before adding crafting, more resource types, or upgrades.
