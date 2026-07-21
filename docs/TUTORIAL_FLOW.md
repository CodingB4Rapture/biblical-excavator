# Tutorial Flow

This document is the plain-language map for changing or discussing the tutorial.

## Three questions, three code locations

When working on the tutorial, first ask which question the change answers:

- **What did the player collect or deliver?**  
  `scripts/resource_progress_helpers/resource_progress_helpers.gml`
- **Did that action complete an objective, and what comes next?**  
  `scripts/tutorial_progression_helpers/tutorial_progression_helpers.gml`
- **Where should the yellow arrow point right now?**  
  `scripts/tutorial_guidance_helpers/tutorial_guidance_helpers.gml`

Winch mechanics remain in `scripts/winch_helpers/winch_helpers.gml`. Dialogue
completion callbacks remain in `scripts/dialogue_helpers/dialogue_helpers.gml`.
The complete list of durable tutorial stages is `TutorialStage` in
`scripts/game_enums/game_enums.gml`.

## Player-facing sequence

1. Talk to the Farmer.
2. Talk to the Farmer's Wife and finish her task dialogue.
3. Gather six small fieldstones by hand.
4. Receive the axe and chop the marked standing tree.
5. Inspect the resulting downed tree and stump.
6. Enter the skidsteer and crush ten Fieldrocks into Fieldstone cargo.
7. Deliver all sixteen Fieldstones to Home Delivery.
8. Collect the mailed winch package beside Home Delivery.
9. Install the winch on the skidsteer.
10. Take the cable from the skidsteer's rear hitch.
11. Attach the cable to the downed tree and haul it into Home Delivery.
12. Attach the cable to the stump and deliver it as Small Lumber.
13. Open Inventory with `I` or `Tab` to inspect the resulting supplies and tools.
14. Place the cabin site.
15. Rest at the cabin site to open the first homestead day.

## How the systems communicate

Collection code creates a small delivery result struct. It passes that result to
`tutorial_process_delivery`, which may advance the stage and annotate the result
with events such as `mail_became_ready` or `quest_completed`. The Wife and Home
Delivery use those event fields to choose the appropriate dialogue.

The arrow does not change tutorial progress. Every frame it reads the current
stage and returns either one world position or no target. This keeps visual
guidance from accidentally completing objectives.

The winch package is not placed manually in the room. It is reconstructed beside
Home Delivery whenever the durable state says the mail is ready. Collecting it
updates the durable attachment and tutorial states, so saving and loading cannot
lose the package milestone.

The Inventory menu is a separate read-only UI object. It reads the player
backpack and Homebase inventories from durable game state, vehicle cargo from
the live skidsteer, and tool unlocks from the persistent tools and attachment
state. It pauses gameplay like the Quest Journal without owning or copying any
inventory values.

After Quest 1 completes, `HomesteadStage` owns the bridge out of the tutorial.
Quest completion unlocks cabin placement; placing the site sets
`FIRST_REST_REQUIRED`; sleeping there sets `HUB_OPEN`.

Cabin placement is not paused. The player can walk or drive while marking a
site, so the site is not limited to the camera view where the reward dialogue
finished. Before the first rest, `B` or the Farmer's Wife can reopen placement
to move the stakes.

While `FIRST_REST_REQUIRED` is active, the right-side status panel and yellow
guidance arrow point to the placed cabin site. They only read state; the cabin
interaction performs the actual transition.

Sleeping at the cabin moves the player to a temporary doorway exit below the
site before the morning fade completes. That exit beat is the intended hook for
the Farmer approaching about the future workbench area.

## Safe editing rules

- Add a new durable milestone to `TutorialStage` before targeting it with an arrow.
- Advance stages in progression or domain-action code, never in drawing code.
- Keep `tutorial_guidance_target` read-only except for reconstructing a missing
  package instance.
- Preserve the explicit numeric values of existing stages for save compatibility.
- If a temporary action cannot be reconstructed after loading, recover to the
  nearest earlier actionable stage, as the held winch cable currently does.
