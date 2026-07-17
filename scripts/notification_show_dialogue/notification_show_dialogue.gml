/// notification_show_dialogue(text or page array, follow_target, duration, style, speaker)
/// Creates or extends the single bottom-screen conversation panel.
function notification_show_dialogue(_text, _follow_target, _duration, _style, _speaker_name = "")
{
    var pages = is_array(_text) ? _text : [_text];
    var bubble = instance_find(obj_dialogue_bubble, 0);

    if (instance_exists(bubble))
    {
        for (var i = 0; i < array_length(pages); i++)
        {
            array_push(bubble.pages, pages[i]);
        }

        return bubble;
    }

    bubble = instance_create_depth(0, 0, -1000, obj_dialogue_bubble);

    bubble.pages = pages;
    bubble.page_index = 0;
    bubble.follow_target = _follow_target;
    bubble.notification_style = _style;
    bubble.speaker_name = (_speaker_name == "")
        ? dialogue_get_speaker_name(_follow_target)
        : _speaker_name;
    bubble.input_lock_frames = 6;

    return bubble;
}

