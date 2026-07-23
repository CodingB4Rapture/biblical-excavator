/// notification_show_hint(text, duration, sticky)
///
/// Shows one calm bottom-right GUI hint at a time.
function notification_show_hint(_text, _duration, _sticky)
{
    var hint = instance_find(obj_gui_hint, 0);

    if (hint == noone)
    {
        hint = instance_create_depth(0, 0, -1100, obj_gui_hint);
    }

    hint.message_text = _text;
    hint.life = _duration;
    hint.life_max = _duration;
    hint.age = 0;
    hint.sticky = _sticky;
    hint.context_key = "";

    return hint;
}
