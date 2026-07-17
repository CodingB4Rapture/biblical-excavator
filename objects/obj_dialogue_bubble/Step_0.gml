/// obj_dialogue_bubble - Step Event
/// The world waits until the player deliberately advances the conversation.

if (input_lock_frames > 0)
{
    input_lock_frames -= 1;
    exit;
}

if (dialogue_advance_pressed())
{
    if (page_index < array_length(pages) - 1)
    {
        page_index += 1;
    }
    else
    {
        instance_destroy();
    }
}

