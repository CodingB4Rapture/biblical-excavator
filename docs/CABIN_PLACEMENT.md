# Cabin Site and Construction

The cabin arc introduces parking, bounded fence planning, and the transition
from a marked construction site to the finished cabin.

## Player flow

1. Claim `Timber Delivery`, then accept `Park the Skidsteer`.
2. Get into the skidsteer and follow guidance to the 96 x 64 parking pad beside
   the Farmer.
3. Park fully inside the pad, stop, detach any tow target, and exit.
4. Claim the task and accept `Mark the Cabin Site`.
5. Press `B` to choose a clear site on the 32 x 32 grid.
6. Go to `spr_cabin_before` and press `E` to enter the bounded fence lesson.
7. Click one highlighted corner and its opposite to create the exact boundary.
8. Press `G` and install one gate on the front/south side.
9. Press `F` to validate and finish, then claim the task.
10. Accept `Build the Cabin`, return to the site, and press `E` to replace
    `spr_cabin_before` with `spr_cabin_after`.
11. Claim the build task and rest at the cabin to begin the first homestead
    morning.

The site preview reserves a fixed four-by-five-grid-interval enclosure. The
64 x 64 cabin has one grid cell of side/back clearance and a two-cell front
yard. The fixed dimensions prevent the tutorial fence from being used to claim
an arbitrarily large area.

Placement rejects room edges and nearby gameplay objects, including the
player, vehicle, NPCs, resources, Home Delivery, and another cabin site.
Decorative asset-layer art still has no collision data, so it remains a visual
check.

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

Durable state records parking, the chosen room/position, the marked boundary,
the built cabin, and purpose-tagged fence records. A site may be relocated only
while `Mark the Cabin Site` is active and before its fence is completed.
Relocation removes the old tutorial boundary.

This pass does not spend resources or introduce construction recipes, damage,
livestock, NPC automation, or other crafting behavior.
