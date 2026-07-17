/// obj_dialogue_bubble - Step Event
/// The world waits until the player deliberately advances the conversation.

if (gameplay_is_paused()) exit;

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
        var finished_action = completion_action;
        instance_destroy();
        dialogue_run_completion_action(finished_action);
    }
}

