# Task Board Art Handoff

The functional board is `obj_task_board`. Its room instance is
`inst_task_board` at `(784, 112)` in `Room1`.

## Current world art

`spr_task_board` is assigned directly to `obj_task_board`. The Draw event uses
the sprite and adds only the contextual world marker. The interaction radius
and task behavior remain on the object rather than depending on the art.

Current art specification:

- canvas: 32 x 32 pixels at the current world scale;
- origin: center;
- one static frame;
- palette and footprint coordinated with the nearby fence art.

The interaction radius is 38 world pixels and does not depend on the sprite's
mask. The object may be moved in the Room Editor without changing save data.

## Menu art seams

`obj_task_board_menu` currently draws its frame, task rows, selection state,
objectives, reward area, and action button with primitives. Future art can
replace the background and button treatment without changing:

- task definitions or IDs;
- acceptance and claim behavior;
- save migration;
- mouse hit regions;
- keyboard controls.

The menu scales from the current GUI dimensions rather than assuming one fixed
window size. Keep decorative borders inside an 18-pixel outer safe area and
leave the left third readable for the task list.

Task names and reward labels remain provisional. Avoid baking those words into
the board sprite.
