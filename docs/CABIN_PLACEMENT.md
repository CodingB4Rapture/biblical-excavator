# Cabin Site and Construction

The cabin arc introduces parking, bounded fence planning, and the transition
from a marked construction site to the finished cabin.

## Player flow

1. Claim `Timber Delivery`, then accept `Park the Skidsteer`.
2. Get into the skidsteer and follow guidance to the 96 x 64 parking pad beside
   the Farmer.
3. Park fully inside the pad, stop, detach any tow target, and exit.
4. Claim the task and accept `Mark the Cabin Site`.
5. Compare the two predefined sites: gold Site I in Eireneikos Meadows and
   blue Site II in Farmer's Workfield.
6. Use `Take Flag` at either site's corner to commit that site. The other
   site's flags are removed and cannot be selected afterward.
7. Use `Place Fence` at the cleared corner. The bounded fence lesson begins
   with that exact corner selected.
8. Click the opposite highlighted corner to create the exact boundary.
9. Press `G` and install one gate on the front/south side.
10. Press `F` to validate and finish, then claim the task.
11. Accept `Build the Cabin`, return to the site, and press `E` to replace
    `spr_cabin_before` with `spr_cabin_after`.
12. Claim the build task and rest at the cabin to begin the first homestead
    morning.

The site preview reserves a fixed four-by-five-grid-interval enclosure. The
64 x 64 cabin has one grid cell of side/back clearance and a two-cell front
yard. The fixed dimensions prevent the tutorial fence from being used to claim
an arbitrarily large area.

The authored site records own their room, center, fixed footprint, color, and
site ID. The four `spr_marker` flag instances derive their corners from that
record; removing flags never changes the permitted footprint. Renewable
resource spawning reserves both footprints so either remains usable until the
player commits.

Site I occupies the open northwest corner of Eireneikos Meadows. Site II is in
the southern grass of Farmer's Workfield, immediately east of the lower-center
tree and west of the Fieldrock Minefield.

## Progression state

```text
TUTORIAL
-> park skidsteer
-> choose site
-> mark exact fence and front gate
-> build cabin
-> FIRST_REST_REQUIRED
-> rest
-> HUB_OPEN
```

Durable state records parking, the selected site ID and room/position, taken
flag mask, marked boundary, built cabin, and purpose-tagged fence records.
Selection is one-way: committing either predefined site disables the other.

This pass does not spend resources or introduce construction recipes, damage,
livestock, NPC automation, or other crafting behavior.
