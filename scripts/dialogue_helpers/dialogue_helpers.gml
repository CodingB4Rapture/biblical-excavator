/// Shared conversation helpers.

function dialogue_is_active()
{
    return instance_exists(obj_dialogue_bubble);
}

function dialogue_advance_pressed()
{
    // Mouse and keyboard are equal ways to advance a conversation.
    return mouse_check_button_pressed(mb_left)
        || keyboard_check_pressed(ord("E"))
        || keyboard_check_pressed(vk_enter)
        || keyboard_check_pressed(vk_space);
}

function dialogue_get_speaker_name(_speaker)
{
    if (instance_exists(_speaker))
    {
        if (_speaker.object_index == obj_farmers_wife) return "FARMER'S WIFE";
        if (_speaker.object_index == obj_farmer) return "FARMER";
        if (_speaker.object_index == obj_player) return "YOU";
    }

    return "HOMESTEAD";
}
