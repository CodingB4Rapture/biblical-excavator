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

HUD prompts use the same idea, but they can either expire or stay until replaced:

`world object -> calls notification_show_hint -> obj_gui_hint draws/fades/stays or expires`

This keeps logs, rocks, future chests, and attachment points focused on world behavior while the notification system owns UI.

## Next Systems

Good next scaffolds:

- `obj_interactable_parent`: shared behavior for things the on-foot player can inspect or use.
- `obj_pullable_parent`: shared behavior for logs, stumps, and other winch targets.
- `AttachmentState`: shared names for no attachment, winch equipped, winch attached, and winch pulling.
- `obj_game_controller`: shared game mode, player mode, and high-level setup.

## Rock Reward Flow

Rocks use `RockState`:

- `WAITING`: rock is idle.
- `STRUGGLING`: skidsteer has started crushing it.
- `BREAKING`: reward has been given and the rock is about to smoke/destroy.

The intended feel is:

`contact -> stage 1 chance for +5 XP -> stage 2 chance for +10 XP -> stage 3 breaks for +25 XP`

Rewards flow through `progress_award_rock`, which updates totals and shows both top-left GUI reward text and a floating XP drop near the skidsteer.

## Haul And Drop-Off Flow

The trip haul uses temporary placeholder limits:

- Rocks: `10`
- Logs: `1`

The top-left GUI trip panel shows carried rocks/logs, rocks depleted this trip, and XP gained this trip.

Moment rewards now appear on the right side, so the trip panel can stay readable.

The placeholder `obj_homebase_dropoff` stores carried resources and resets the current trip counters. This is the first pass at the future homestead/base loop.

The `obj_rock_controller` records rock spawn points and respawns depleted rocks after a delay. Tree spawning should get its own separate controller later.
