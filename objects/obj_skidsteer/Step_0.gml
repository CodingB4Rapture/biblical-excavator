/// obj_skidsteer - Step Event

if (gameplay_is_paused()) exit;

if (dialogue_is_active())
{
    exit;
}

skidsteer_update_cooldowns();

switch (skidsteer_state)
{
    case SkidsteerState.DRIVING:
    case SkidsteerState.CONTACT_BLOCKED:
    case SkidsteerState.CRUSHING:
    {
        skidsteer_update_driving();
        break;
    }

    case SkidsteerState.EMPTY:
    {
        skidsteer_update_empty();
        break;
    }
}

