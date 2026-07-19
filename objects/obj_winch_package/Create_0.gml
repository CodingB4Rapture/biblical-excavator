/// obj_winch_package - Create Event

if (game_state_ensure().winch_attachment_state != AttachmentState.MAIL_READY)
{
    instance_destroy();
    exit;
}

interaction_enabled = true;
interaction_radius = 28;
interaction_priority = 60;

interaction_get_prompt = function(_actor) { return "Collect winch attachment"; };
interaction_run = function(_actor)
{
    if (!tutorial_collect_winch_package()) return;

    progress_show_reward_summary("Winch Attachment Collected", "Ready to install");
    notification_show_hint(
        "Take the attachment to the marked skidsteer.",
        game_get_speed(gamespeed_fps) * 4,
        false
    );
    instance_destroy();
};
