# Biblical Excavator Foundation Scaffolding

This note describes the current early-game systems in plain language.

## Vehicle Flow

The skidsteer now uses `SkidsteerState`:

- `DRIVING`: player is inside and the skidsteer reads driving input.
- `EMPTY`: player has hopped out and the skidsteer is idle.
- `CONTACT_BLOCKED`: skidsteer is touching something it cannot handle yet.
- `CRUSHING`: skidsteer is actively crushing a rock.

The intended flow is:

`DRIVING -> hits log -> CONTACT_BLOCKED -> show memory bubble -> backs away -> DRIVING`

And:

`DRIVING -> press E -> EMPTY -> player walks -> press E near skidsteer -> DRIVING`

## Notification Flow

World objects do not draw their own dialogue anymore.

Instead:

`world object -> calls notification_show_dialogue -> obj_dialogue_bubble draws/follows/expires`

This keeps logs, rocks, future chests, and attachment points focused on world behavior while the notification system owns UI.

## Next Systems

Good next scaffolds:

- `obj_interactable_parent`: shared behavior for things the on-foot player can inspect or use.
- `obj_pullable_parent`: shared behavior for logs, stumps, and other winch targets.
- `AttachmentState`: shared names for no attachment, winch equipped, winch attached, and winch pulling.
- `obj_game_controller`: shared game mode, player mode, and high-level setup.

