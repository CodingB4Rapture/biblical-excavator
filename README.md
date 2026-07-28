# biblical-excavator
A top-down 2D excavation and base-building game made in GameMaker.

Copyright © 2026 Seth Jackson and contributors.
All rights reserved unless otherwise stated.

The source code and game assets in this repository may be viewed for
educational and portfolio purposes but may not be redistributed,
commercialized, or incorporated into another project without permission.

## Current Prototype Controls

- `WASD` or arrow keys: walk or drive.
- `E` while driving: exit the vehicle.
- `E` on foot: use the currently displayed contextual action.
- `M` or the left-side Map button: open the live whole-area overview. The
  player or driven skidsteer is marked, and `M`/Escape closes the map.
- `Q` or the Quest button: open the quest journal.
- `I` or the Inventory button: open the backpack.
- `Shift+S` or the Skills button: open Heavy Equipment, Toolmanship, and
  Woodwork levels, XP, and upcoming ability unlocks. Reaching a new level
  opens a click-through level-up dialogue.
- The Build button opens free-build options after that feature unlocks.
- `E` at the Task Board: open the board after the Farmer's Wife posts the
  first assignment. Accept each assignment there, then return to claim
  completed work before the next one unlocks. Use Up/Down or click to select,
  Enter/Space to act, the mouse wheel to scroll, and `E`/Escape to close.
- The yellow world marker points at an on-camera objective. When that objective
  is outside the camera, a labeled yellow arrow appears at the screen edge.
- `E` at a Site I or Site II flag: claim that authored cabin site.
- `E` at the selected site's blueprint sockets: place the displayed crafted
  fence piece, gate, or completed cabin. Fence pieces are produced at the
  sawmill and collected from Finished Crafts.
- Production menus use click/Up/Down to select a recipe, Left/Right or `-`/`+`
  for quantity, Enter/`E` to start, and `C` to cancel unfinished batches.
- `E` at the pond with an Empty Bucket: fill it with water.
- `E` at the water tank with a Water Bucket: add one unit and recover the
  Empty Bucket. The tutorial tank begins at `10/40`.
- `E` at the finished cabin: sleep when the cabin task and first water delivery
  allow it.

New games begin with an authored rescue/wake-up cutscene: the Farmer finds the
player unconscious, brings them to the homestead, and gives the first greeting.
The current Day 1 loop then includes backpack collection, vehicle rock hauling,
winching, Home Delivery, two authored cabin sites, durable fence/cabin
blueprints, sawmill and lathe jobs, Finished Crafts pickup, the Farmer's
post-cabin water lesson, a durable `10/40` tank, sleep, and the transition to
Day 2. See `docs/TUTORIAL_FLOW.md` for the
implemented sequence and `docs/EXTENSION_READINESS.md` for architecture and
deferred-system boundaries.

**Before beginning work**:

**Do not edit the same room, sprite, sequence, or object at the same time without coordinating first.**

1. Open GitHub Desktop.
2. Click Fetch origin.
3. Pull any available changes.
4. Create a new branch.

**EXAMPLES**
seth/skidsteer-movement
jacob/warehouse-map
jacob/player-collision
seth/environment-art

Then: 
Make one focused change.
Test the game.
Commit it.
Push the branch.
Open a pull request on GitHub.
Have the other person review it.
Merge it into main.
Both people pull the updated main.
