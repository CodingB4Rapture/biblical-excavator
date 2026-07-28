/// Stable authored cutscene definitions. Runtime interpretation is owned by
/// cutscene_presentation_helpers; definitions never mutate durable state.

function cutscene_definition(_cutscene_id)
{
    switch (_cutscene_id)
    {
        case CUTSCENE_INTRO_RESCUE:
            return {
                id: _cutscene_id,
                initial_fade_alpha: 1,
                resume_steps: [0, 22],
                resume_fade_alpha: [1, 1],
                steps: [
                    {type: CutsceneStepType.LOCK_INPUT},
                    {
                        type: CutsceneStepType.REPOSITION_ACTOR,
                        actor_id: CUTSCENE_ACTOR_PLAYER,
                        x: 896,
                        y: 560,
                        angle: 90
                    },
                    {
                        type: CutsceneStepType.REPOSITION_ACTOR,
                        actor_id: CUTSCENE_ACTOR_FARMER,
                        x: 896,
                        y: 430,
                        angle: 0
                    },
                    {
                        type: CutsceneStepType.CAMERA_FOCUS,
                        first_actor_id: CUTSCENE_ACTOR_PLAYER,
                        second_actor_id: CUTSCENE_ACTOR_PLAYER,
                        zoom: 1.45
                    },
                    {
                        type: CutsceneStepType.CAPTION,
                        text: "At the edge of a tired homestead...",
                        frames: 48
                    },
                    {
                        type: CutsceneStepType.FADE,
                        alpha: 0,
                        speed: 0.025
                    },
                    {type: CutsceneStepType.WAIT, frames: 12},
                    {
                        type: CutsceneStepType.MOVE_ACTOR,
                        actor_id: CUTSCENE_ACTOR_FARMER,
                        x: 896,
                        y: 490,
                        speed: 0.55,
                        tolerance: 2,
                        timeout_frames: 240
                    },
                    {type: CutsceneStepType.WAIT, frames: 24},
                    {
                        type: CutsceneStepType.FADE,
                        alpha: 1,
                        speed: 0.04
                    },
                    {type: CutsceneStepType.WAIT, frames: 18},
                    {
                        type: CutsceneStepType.FADE,
                        alpha: 0,
                        speed: 0.035
                    },
                    {
                        type: CutsceneStepType.DIALOGUE,
                        actor_id: CUTSCENE_ACTOR_PLAYER,
                        speaker: "YOU",
                        pages: ["...help"]
                    },
                    {
                        type: CutsceneStepType.MOVE_ACTOR,
                        actor_id: CUTSCENE_ACTOR_FARMER,
                        x: 896,
                        y: 524,
                        speed: 0.38,
                        tolerance: 2,
                        timeout_frames: 240
                    },
                    {type: CutsceneStepType.WAIT, frames: 24},
                    {
                        type: CutsceneStepType.FADE,
                        alpha: 1,
                        speed: 0.04
                    },
                    {type: CutsceneStepType.WAIT, frames: 18},
                    {
                        type: CutsceneStepType.FADE,
                        alpha: 0,
                        speed: 0.035
                    },
                    {type: CutsceneStepType.WAIT, frames: 12},
                    {
                        type: CutsceneStepType.DIALOGUE,
                        actor_id: CUTSCENE_ACTOR_FARMER,
                        speaker: "FARMER",
                        pages: ["....."]
                    },
                    {
                        type: CutsceneStepType.FADE,
                        alpha: 1,
                        speed: 0.03
                    },
                    {
                        type: CutsceneStepType.CHECKPOINT,
                        checkpoint: 1
                    },
                    {
                        type: CutsceneStepType.REPOSITION_ACTOR,
                        actor_id: CUTSCENE_ACTOR_PLAYER,
                        x: 1168,
                        y: 224,
                        angle: 0
                    },
                    {
                        type: CutsceneStepType.REPOSITION_ACTOR,
                        actor_id: CUTSCENE_ACTOR_FARMER,
                        x: 1136,
                        y: 224,
                        angle: 0
                    },
                    {
                        type: CutsceneStepType.CAMERA_FOCUS,
                        first_actor_id: CUTSCENE_ACTOR_PLAYER,
                        second_actor_id: CUTSCENE_ACTOR_PLAYER,
                        zoom: 1.3
                    },
                    {
                        type: CutsceneStepType.CAPTION,
                        text: "Some time later...",
                        frames: 72
                    },
                    {
                        type: CutsceneStepType.FADE,
                        alpha: 0,
                        speed: 0.012
                    },
                    {type: CutsceneStepType.WAIT, frames: 20},
                    {
                        type: CutsceneStepType.DIALOGUE,
                        actor_id: CUTSCENE_ACTOR_FARMER,
                        speaker: "FARMER",
                        pages: [
                            "There you are. Easy. You're safe at our homestead.",
                            "I found you passed out near the south field. My wife helped me get you back here, but you have the Lord to thank for breath in your lungs.",
                            "This land was left to ruin before we came. We have always believed our lives were meant for restoration, one faithful piece of work at a time.",
                            "You do not owe us an explanation today. Get your feet under you, meet my wife, and let honest work give you somewhere to begin."
                        ]
                    },
                    {
                        type: CutsceneStepType.COMMAND,
                        command_id: CUTSCENE_COMMAND_FINISH_INTRO
                    },
                    {type: CutsceneStepType.COMPLETE}
                ]
            };

        case CUTSCENE_AXE_HANDOFF:
            return {
                id: _cutscene_id,
                initial_fade_alpha: 0,
                resume_steps: [0],
                resume_fade_alpha: [0],
                steps: [
                    {type: CutsceneStepType.LOCK_INPUT},
                    {
                        type: CutsceneStepType.CAMERA_FOCUS,
                        first_actor_id: CUTSCENE_ACTOR_PLAYER,
                        second_actor_id: CUTSCENE_ACTOR_FARMER,
                        zoom: 1.3
                    },
                    {
                        type: CutsceneStepType.MOVE_ACTOR,
                        actor_id: CUTSCENE_ACTOR_FARMER,
                        target_actor_id: CUTSCENE_ACTOR_PLAYER,
                        offset_x: 26,
                        offset_y: 0,
                        speed: 0.42,
                        tolerance: 3,
                        timeout_frames: 360
                    },
                    {type: CutsceneStepType.WAIT, frames: 18},
                    {
                        type: CutsceneStepType.DIALOGUE,
                        actor_id: CUTSCENE_ACTOR_FARMER,
                        speaker: "FARMER",
                        pages: [
                            "Six good stones. You kept your footing and did not rush the work. That tells me you may be ready for this.",
                            "This axe has been with me a long while. See those little notches worn into the handle?",
                            "One for every tree I felled and walked away from unharmed. I used to call that experience. Age taught me to call it what it was: God protecting me.",
                            "It is yours now. Keep the edge sharp, mind where you stand, and remember that strength is something we are trusted with."
                        ]
                    },
                    {
                        type: CutsceneStepType.COMMAND,
                        command_id: CUTSCENE_COMMAND_GIVE_FARMERS_AXE
                    },
                    {type: CutsceneStepType.COMPLETE}
                ]
            };

        case CUTSCENE_WATER_SUPPLY:
            return {
                id: _cutscene_id,
                initial_fade_alpha: 0,
                resume_steps: [0],
                resume_fade_alpha: [0],
                steps: [
                    {type: CutsceneStepType.LOCK_INPUT},
                    {
                        type: CutsceneStepType.REPOSITION_ACTOR,
                        actor_id: CUTSCENE_ACTOR_FARMER,
                        target_actor_id: CUTSCENE_ACTOR_PLAYER,
                        offset_x: 0,
                        offset_y: -96,
                        angle: 0
                    },
                    {
                        type: CutsceneStepType.CAMERA_FOCUS,
                        first_actor_id: CUTSCENE_ACTOR_PLAYER,
                        second_actor_id: CUTSCENE_ACTOR_PLAYER,
                        zoom: 1.3
                    },
                    {
                        type: CutsceneStepType.DIALOGUE,
                        actor_id: CUTSCENE_ACTOR_PLAYER,
                        speaker: "YOU",
                        pages: [
                            "That was a good day's work... but I'm parched."
                        ]
                    },
                    {
                        type: CutsceneStepType.CAMERA_FOCUS,
                        first_actor_id: CUTSCENE_ACTOR_PLAYER,
                        second_actor_id: CUTSCENE_ACTOR_FARMER,
                        zoom: 1.25
                    },
                    {
                        type: CutsceneStepType.MOVE_ACTOR,
                        actor_id: CUTSCENE_ACTOR_FARMER,
                        target_actor_id: CUTSCENE_ACTOR_PLAYER,
                        offset_x: 28,
                        offset_y: 0,
                        speed: 0.45,
                        tolerance: 3,
                        timeout_frames: 300
                    },
                    {type: CutsceneStepType.WAIT, frames: 18},
                    {
                        type: CutsceneStepType.DIALOGUE,
                        actor_id: CUTSCENE_ACTOR_FARMER,
                        speaker: "FARMER",
                        pages: [
                            "There she stands. You put in a fine day's work raising that cabin.",
                            "You look thirsty, though. One last thing before you rest: make yourself a bucket at the lathe.",
                            "Collect it from the middle Finished Crafts chest, draw water from the pond, then pour it into the tank by the farmyard.",
                            "I keep ten buckets in reserve. Add one now so the gauge reads 11/40. Then drink your fill and get some rest."
                        ]
                    },
                    {
                        type: CutsceneStepType.COMMAND,
                        command_id:
                            CUTSCENE_COMMAND_BEGIN_WATER_TUTORIAL
                    },
                    {type: CutsceneStepType.COMPLETE}
                ]
            };
    }

    return undefined;
}

function cutscene_definition_resume_step(_definition, _checkpoint)
{
    if (!is_struct(_definition)
    || !is_array(_definition.resume_steps)
    || array_length(_definition.resume_steps) == 0)
    {
        return 0;
    }
    var checkpoint = clamp(
        floor(_checkpoint),
        0,
        array_length(_definition.resume_steps) - 1
    );
    return _definition.resume_steps[checkpoint];
}

function cutscene_definition_resume_fade(_definition, _checkpoint)
{
    if (!is_struct(_definition)
    || !is_array(_definition.resume_fade_alpha)
    || array_length(_definition.resume_fade_alpha) == 0)
    {
        return 0;
    }
    var checkpoint = clamp(
        floor(_checkpoint),
        0,
        array_length(_definition.resume_fade_alpha) - 1
    );
    return _definition.resume_fade_alpha[checkpoint];
}
