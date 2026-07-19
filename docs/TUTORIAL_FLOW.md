# Tutorial Flow

This document is the plain-language map for changing or discussing the tutorial.

## Three questions, three code locations

When working on the tutorial, first ask which question the change answers:

- **What did the player collect or deliver?**  
  `scripts/progress_award_rock/progress_award_rock.gml`
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
4. Deliver them to Home Delivery.
5. Enter the skidsteer and gather ten more fieldstones.
6. Deliver those stones.
7. Collect the mailed winch package beside Home Delivery.
8. Install the winch on the skidsteer.
9. Inspect or encounter the large tutorial log.
10. Take the cable from the skidsteer's rear hitch.
11. Attach the cable to the log.
12. Haul the log into Home Delivery.

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

## Safe editing rules

- Add a new durable milestone to `TutorialStage` before targeting it with an arrow.
- Advance stages in progression or domain-action code, never in drawing code.
- Keep `tutorial_guidance_target` read-only except for reconstructing a missing
  package instance.
- Preserve the explicit numeric values of existing stages for save compatibility.
- If a temporary action cannot be reconstructed after loading, recover to the
  nearest earlier actionable stage, as the held winch cable currently does.
