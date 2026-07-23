# Resource Regeneration

Renewable resources use the persistent game calendar. They do not return on a
short real-time timer.

## Fieldrocks

- Crushing a Fieldrock records its room, original spawn position, and the day
  on which it may return.
- A Fieldrock becomes available again after `1` in-game day.
- It returns only at its original map spawn.
- If the player, skidsteer, cabin, pond, hauled resource, NPC, tree, or another
  Fieldrock occupies that spawn, regeneration remains pending until it is clear.
- The old 12-second respawn loop has been removed.

The respawn delay is `FIELDROCK_RESPAWN_DAYS` in
`scripts/fieldrock_regeneration_helpers/fieldrock_regeneration_helpers.gml`.

## Trees

- Felling a tree still creates one downed tree and one stump.
- Regrowth does not begin while either physical piece remains in the world.
- Delivering both pieces schedules the original tree to return after `3`
  in-game days.
- A due tree waits if its original position is occupied.
- Regrowth currently restores the mature standing-tree sprite immediately;
  seedling and growth-stage art are a future visual pass.

The delay is `TREE_REGROWTH_DAYS` in the small shared
`resource_regeneration_helpers` module. Tree records remain owned by
`tree_persistence_helpers`, and `obj_tree_controller` performs the room-level
regrowth check. Trees are not managed by `obj_fieldrock_controller`.

## Fieldstones

The first six hand-gathered Fieldstones now come from the same spawn-area system
when the room provides enough candidate positions. Entering the gathering stage
promotes enough clear spawn records to guarantee the remaining objective, and
the guidance arrow selects the closest visible stone. If a room has no usable
spawn area, nearby one-time `obj_small_fieldstone` objects are created as a
local fallback instead of using fixed coordinates elsewhere on the map.

For scalable renewable hand-gathering, place one or more
`obj_fieldstone_spawn_area` objects. Each area exposes these Object Variables in
the Room Editor:

- `spawn_radius`: radius around the marker used for candidate positions;
- `spawn_points`: number of persistent candidate positions generated;
- `spawn_chance`: initial and daily chance at each position.

The default area creates `16` candidate positions within `128` pixels, each
with a `45%` chance. Candidate coordinates are generated once and then saved.
The area marker destroys itself during room creation; one shared
`obj_fieldstone_controller` manages all records. Only currently visible
Fieldstones remain as live objects.

An individually placed `obj_fieldstone` still works as a deliberate one-off
spawn marker. For broad natural scatter, use spawn areas instead of placing
dozens of individual objects.

For every registered candidate:

- a new marker has a `45%` chance to show a Fieldstone initially;
- an empty marker rolls once at `12:00 PM` each in-game day;
- a successful roll that is temporarily obstructed remains pending and appears
  when the location becomes clear;
- spawned Fieldstones can be collected during the first six-stone objective and
  again after the tutorial; intermediate tutorial stages keep them inactive.

Tune each area's density and chance through its Object Variables. The
`FIELDSTONE_DAILY_SPAWN_CHANCE` macro controls one-off `obj_fieldstone`
markers, and `FIELDSTONE_NOON_MINUTE` controls the shared reroll time; both live
in `scripts/fieldstone_regeneration_helpers/fieldstone_regeneration_helpers.gml`.

## Saves And Map Editing

Fieldstone rolls, Fieldrock schedules, and tree schedules are stored in the
version-two save snapshot. Version-one saves migrate before hydration. When an
older save contains a permanently removed Fieldrock, it receives a one-day
regeneration schedule. Fieldrock IDs include the room name; coordinate-only IDs
from earlier saves migrate when their room resource is constructed.

Room resources mark their records when the room is constructed. Records for
resource positions removed or moved in the room editor are ignored and pruned
for that room, preventing old map coordinates from producing duplicate spawns.
