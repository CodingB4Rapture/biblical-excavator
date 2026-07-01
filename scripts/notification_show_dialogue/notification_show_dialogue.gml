/// notification_show_dialogue(text, follow_target, duration, style)
///
/// Creates a reusable world-space dialogue bubble that can follow an object.
function notification_show_dialogue(_text, _follow_target, _duration, _style)
{
    var bubble = instance_create_depth(0, 0, -1000, obj_dialogue_bubble);

    bubble.message_text = _text;
    bubble.follow_target = _follow_target;
    bubble.life = _duration;
    bubble.life_max = _duration;
    bubble.notification_style = _style;

    if (instance_exists(_follow_target))
    {
        bubble.x = _follow_target.x;
        bubble.y = _follow_target.y;
    }

    return bubble;
}

