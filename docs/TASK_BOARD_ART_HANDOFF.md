# Task Board Art Handoff

The functional board is `obj_task_board`. Its temporary room instance is
`inst_task_board` at `(1120, 208)` in `Room1`.

## Replacing the placeholder

Assign the finished board sprite directly to `obj_task_board`. Its Draw event
automatically uses `draw_self()` when a sprite exists and only draws the
temporary wooden sign when no sprite is assigned.

Recommended starting specification:

- canvas: roughly 32 x 40 pixels at the current world scale;
- origin: bottom-center, at the foot of the board post;
- collision: none for the first art pass;
- readable silhouette: notice surface above one or two narrow posts;
- palette: warm wood with a parchment, cloth, or lighter pinned-note area.

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
