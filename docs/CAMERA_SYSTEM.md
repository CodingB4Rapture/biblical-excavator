# Camera System

`obj_camera_controller` is the only object that moves Camera 0. It follows the on-foot player when one exists, otherwise the skidsteer. This is why leaving the vehicle now immediately transfers camera follow to the player.

## Future scene calls

Call these from tutorial, NPC, or dialogue code:

- `camera_focus_on(obj_farmers_wife, 1.35)` — focus and zoom on one character until `camera_follow_gameplay()` is called.
- `camera_focus_between(player, obj_farmers_wife, 1.2)` — frame both sides of a conversation.
- `camera_focus_on(obj_farmers_wife, 1.35, room_speed * 2)` — focus temporarily, then resume regular follow after two seconds.

The third argument is duration in steps. A duration of `0` holds the cutscene camera until the dialogue or scene explicitly calls `camera_follow_gameplay()`.

## Cabin door asset

The temporary two-frame entrance sprite is named `spr_home_cabin_door` in `World / Homestead`. It remains visual-only for now. Once you draw the cabin interior, the next clean step is an `obj_home_cabin_door` interaction object and a separate interior room; keep the visual sprite and the doorway logic as separate assets.
