# Cabin Site and Construction

The cabin arc introduces parking, authored blueprint construction, and the transition
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
7. Claim `Mark the Cabin Site` and accept `Build the Cabin Boundary`.
8. Mill the delivered Timber Log into Timber Planks at the sawmill. Collect
   output from Finished Crafts, then make 10 straights, 4 corners, and 1 gate.
9. Collect the crafted pieces and press `E` at each matching blueprint socket.
   The gate occupies the authored two-cell opening on the front/south side.
10. Claim the boundary task after all sockets reconcile as completed.
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
flag mask, marked boundary, built cabin, purpose-tagged fence records, crafted
piece type/rotation/socket IDs, and cabin blueprint completion.
Selection is one-way: committing either predefined site disables the other.

Legacy free-form planning helpers remain only where old-save/free-build
compatibility still references them. The tutorial's canonical path is the
authored socket blueprint above; there is no `B` cabin-placement step.
