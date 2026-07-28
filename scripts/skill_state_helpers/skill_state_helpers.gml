/// Durable skill XP schema and pure state mutation.

function skill_axe_notching_state_ensure(_game_state)
{
    if (!variable_struct_exists(_game_state, "tools")
    || !is_struct(_game_state.tools))
    {
        _game_state.tools = {axe_owned: false};
    }

    if (!variable_struct_exists(
        _game_state.tools,
        "axe_notching_preference"
    )
    || (_game_state.tools.axe_notching_preference
        != AxeNotchingPreference.UNDECIDED
        && _game_state.tools.axe_notching_preference
            != AxeNotchingPreference.ENABLED
        && _game_state.tools.axe_notching_preference
            != AxeNotchingPreference.DISABLED))
    {
        _game_state.tools.axe_notching_preference =
            AxeNotchingPreference.UNDECIDED;
    }

    if (!variable_struct_exists(
        _game_state.tools,
        "axe_notching_prompt_pending"
    ))
    {
        _game_state.tools.axe_notching_prompt_pending = false;
    }
    _game_state.tools.axe_notching_prompt_pending =
        _game_state.tools.axe_notching_prompt_pending == true;

    if (!variable_struct_exists(_game_state.tools, "axe_notch_count")
    || !is_numeric(_game_state.tools.axe_notch_count))
    {
        _game_state.tools.axe_notch_count = 0;
    }
    _game_state.tools.axe_notch_count = max(
        0,
        floor(_game_state.tools.axe_notch_count)
    );
    return _game_state;
}

function skill_set_axe_notching_preference_state(
    _game_state,
    _preference
)
{
    skill_axe_notching_state_ensure(_game_state);
    if (_preference != AxeNotchingPreference.ENABLED
    && _preference != AxeNotchingPreference.DISABLED)
    {
        return false;
    }

    _game_state.tools.axe_notching_preference = _preference;
    _game_state.tools.axe_notching_prompt_pending = false;
    return true;
}

function skill_record_axe_notch_state(_game_state)
{
    skill_axe_notching_state_ensure(_game_state);
    if (_game_state.tools.axe_notching_preference
        != AxeNotchingPreference.ENABLED)
    {
        return false;
    }

    _game_state.tools.axe_notch_count += 1;
    return true;
}

function skill_state_create_default_xp()
{
    return array_create(SkillId.COUNT, 0);
}

function skill_state_ensure(_game_state)
{
    if (!variable_struct_exists(_game_state, "skill_xp")
    || !is_array(_game_state.skill_xp))
    {
        _game_state.skill_xp = skill_state_create_default_xp();
        if (variable_struct_exists(_game_state, "equipment_xp")
        && is_numeric(_game_state.equipment_xp))
        {
            _game_state.skill_xp[SkillId.HEAVY_EQUIPMENT] =
                max(0, floor(_game_state.equipment_xp));
        }
    }

    while (array_length(_game_state.skill_xp) < SkillId.COUNT)
        array_push(_game_state.skill_xp, 0);

    for (var skill_id = 0; skill_id < SkillId.COUNT; skill_id++)
    {
        var xp = _game_state.skill_xp[skill_id];
        _game_state.skill_xp[skill_id] =
            is_numeric(xp) ? max(0, floor(xp)) : 0;
    }

    // equipment_xp remains a format-1 compatibility mirror while all current
    // writes route through the Heavy Equipment skill owner.
    var legacy_equipment_xp =
        variable_struct_exists(_game_state, "equipment_xp")
        && is_numeric(_game_state.equipment_xp)
            ? max(0, floor(_game_state.equipment_xp))
            : 0;
    _game_state.skill_xp[SkillId.HEAVY_EQUIPMENT] = max(
        _game_state.skill_xp[SkillId.HEAVY_EQUIPMENT],
        legacy_equipment_xp
    );
    _game_state.equipment_xp =
        _game_state.skill_xp[SkillId.HEAVY_EQUIPMENT];
    return _game_state;
}

function skill_get_xp(_skill_id, _game_state = undefined)
{
    var game_state = is_undefined(_game_state)
        ? game_state_ensure()
        : _game_state;
    skill_state_ensure(game_state);
    if (_skill_id < 0 || _skill_id >= SkillId.COUNT) return 0;
    return game_state.skill_xp[_skill_id];
}

function skill_award_xp_state(_game_state, _skill_id, _amount)
{
    skill_state_ensure(_game_state);
    var definition = skill_definition(_skill_id);
    var amount = floor(_amount);
    if (is_undefined(definition) || amount <= 0)
    {
        return {
            changed: false,
            amount: 0,
            old_level: 1,
            new_level: 1
        };
    }

    var old_xp = _game_state.skill_xp[_skill_id];
    var old_level = skill_level_from_xp(_skill_id, old_xp);
    _game_state.skill_xp[_skill_id] = old_xp + amount;
    var new_level = skill_level_from_xp(
        _skill_id,
        _game_state.skill_xp[_skill_id]
    );
    if (_skill_id == SkillId.HEAVY_EQUIPMENT)
        _game_state.equipment_xp = _game_state.skill_xp[_skill_id];
    if (_skill_id == SkillId.TOOLMANSHIP
    && old_level < 2
    && new_level >= 2)
    {
        skill_axe_notching_state_ensure(_game_state);
        if (_game_state.tools.axe_notching_preference
            == AxeNotchingPreference.UNDECIDED)
        {
            _game_state.tools.axe_notching_prompt_pending = true;
        }
    }

    return {
        changed: true,
        amount: amount,
        old_level: old_level,
        new_level: new_level
    };
}
