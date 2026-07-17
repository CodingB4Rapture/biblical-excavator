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

The trip haul now has three separate owners:

- Player backpack: `6` small items.
- Vehicle cargo: `10` loose Fieldstones.
- Homebase: unlimited placeholder household storage.

The player can press `E` near a waiting rock to pocket it. Crushing a rock still
loads the vehicle and awards Equipment XP.

The wife performs the Homebase transfer. The vehicle must be parked in the Home
Delivery circle to unload its cargo, while backpack contents transfer directly.
Large winched objects remain physical until they are inside that circle.

After three non-empty deliveries, the wife reports that a winch attachment has
arrived by mail. The player can install it on the vehicle, take the cable from
the rear hitch, attach it to the log, and tow the log into the delivery circle.

The `obj_rock_controller` records rock spawn points and respawns depleted rocks after a delay. Tree spawning should get its own separate controller later.

See `docs/CORE_LOOP_TRACKER.md` for controls, tuning locations, art needs, and
the current human playtest checkpoints.
