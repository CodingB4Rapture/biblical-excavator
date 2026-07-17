# Cabin Placement

Cabin placement is the small bridge between the introductory quest and the
future crafting system.

## Player Flow

1. Complete **A Firm Foundation** by delivering the first log.
2. Advance through the Farmer's Wife's completion dialogue.
3. Move the mouse to preview a 64 x 64 cabin site on a 16-pixel grid.
4. Left-click a green preview to place it.
5. Right-click or press Escape to cancel; press `B` later to try again.

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
