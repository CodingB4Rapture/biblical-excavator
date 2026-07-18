/// obj_cabin_site - Draw Event
/// This is a world object, so the cabin must be drawn in room coordinates.

if (game_state_ensure().tutorial_stage == TutorialStage.COMPLETE)
{
    draw_self();
}
