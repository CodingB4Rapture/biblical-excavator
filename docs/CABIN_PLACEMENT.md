# Cabin Placement

Cabin placement is the small bridge between the introductory quest and the
future crafting system.

## Player Flow

1. Complete **A Firm Foundation** by delivering the first log.
2. Advance through the Farmer's Wife's completion dialogue.
3. Walk to the part of the homestead where the cabin should go.
4. Press `B`, or speak with the Farmer's Wife, to start marking the site.
5. Move around as needed while the 64 x 64 cabin preview follows the mouse on a
   16-pixel grid.
6. Left-click a green preview to place it.
7. Before resting, press `B` or speak with the Farmer's Wife again to move the
   cabin site.
8. Rest at the placed cabin site to begin the first homestead morning.
9. Right-click or press Escape to cancel placement.

The preview rejects room edges and nearby gameplay objects, including the
player, vehicle, NPCs, resources, Home Delivery, and another cabin site. The
player still visually checks background scenery because decorative asset-layer
art does not currently provide collision data.

## Current Boundary

The site is a plain, readable placeholder and does not spend the delivered
materials yet. The Homebase inventory retains the 16 fieldstones and one log.
The next crafting pass should decide recipes, material consumption, build
stages, cancel/refund behavior, and the temporary cabin art before converting
the site into a finished structure.

## Progression State

The cabin site creates the post-tutorial bridge:

`TUTORIAL -> place cabin site -> FIRST_REST_REQUIRED -> rest -> HUB_OPEN`

Crafting is intentionally not available in `FIRST_REST_REQUIRED`; that state
only asks the player to rest and start the next day.

The cabin site can be moved only during `FIRST_REST_REQUIRED`, while it is still
stakes in the ground. After the first rest opens `HUB_OPEN`, moving an
established home should be handled as its own later feature.

Sleeping at the cabin places the player at a temporary doorway exit just below
the site. Future cabin/interior art can move that anchor, and the first
hub-morning workbench conversation should begin from that exit beat.
