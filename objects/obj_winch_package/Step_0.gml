/// obj_winch_package - Step Event

if (game_state_ensure().winch_attachment_state != AttachmentState.MAIL_READY)
{
    instance_destroy();
}
