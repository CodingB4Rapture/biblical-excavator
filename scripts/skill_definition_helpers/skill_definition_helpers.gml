/// Stable skill definitions and Biblical Excavation's steady mastery curve.

#macro SKILL_MASTERY_LEVEL_CAP 50

function skill_definitions()
{
    return [
        {
            id: SkillId.HEAVY_EQUIPMENT,
            stable_key: "heavy_equipment",
            display_name: "Heavy Equipment",
            description: "Operating work vehicles and powered equipment.",
            max_level: SKILL_MASTERY_LEVEL_CAP,
            unlocks: [
                {
                    stable_key: SKILL_UNLOCK_UTILITY_VEHICLE_WINCH,
                    level: 2,
                    title: "Utility Vehicle Winches",
                    description: "You can now attach winches to Skidsteers, Four-Wheelers, Horses, and Donkeys."
                }
            ],
            level_prompts: []
        },
        {
            id: SkillId.TOOLMANSHIP,
            stable_key: "toolmanship",
            display_name: "Toolmanship",
            description: "Using hand tools to gather, mine, cut, and shape natural materials.",
            max_level: SKILL_MASTERY_LEVEL_CAP,
            unlocks: [],
            level_prompts: [
                {
                    level: 2,
                    text: "Would you like to notch your axe after each tree you safely fell from now on?",
                    choices: [
                        {
                            label: "Yes - notch the axe",
                            action: DIALOGUE_ACTION_ENABLE_AXE_NOTCHING
                        },
                        {
                            label: "No - leave it plain",
                            action: DIALOGUE_ACTION_DISABLE_AXE_NOTCHING
                        }
                    ]
                }
            ]
        },
        {
            id: SkillId.WOODWORK,
            stable_key: "woodwork",
            display_name: "Woodwork",
            description: "Joining timber and constructing durable wooden structures.",
            max_level: SKILL_MASTERY_LEVEL_CAP,
            unlocks: [],
            level_prompts: []
        }
    ];
}

function skill_definition(_skill_id)
{
    var definitions = skill_definitions();
    if (_skill_id < 0 || _skill_id >= array_length(definitions))
        return undefined;
    return definitions[_skill_id];
}

function skill_unlock_definition(_skill_id, _unlock_key)
{
    var definition = skill_definition(_skill_id);
    if (is_undefined(definition)) return undefined;

    for (var unlock_index = 0;
        unlock_index < array_length(definition.unlocks);
        unlock_index++)
    {
        var unlock = definition.unlocks[unlock_index];
        if (unlock.stable_key == _unlock_key) return unlock;
    }
    return undefined;
}

function skill_unlocks_at_level(_skill_id, _level)
{
    var definition = skill_definition(_skill_id);
    var matches = [];
    if (is_undefined(definition)) return matches;

    for (var unlock_index = 0;
        unlock_index < array_length(definition.unlocks);
        unlock_index++)
    {
        var unlock = definition.unlocks[unlock_index];
        if (unlock.level == _level) array_push(matches, unlock);
    }
    return matches;
}

function skill_next_unlock_definition(_skill_id, _current_level)
{
    var definition = skill_definition(_skill_id);
    if (is_undefined(definition)) return undefined;

    var next_unlock = undefined;
    for (var unlock_index = 0;
        unlock_index < array_length(definition.unlocks);
        unlock_index++)
    {
        var unlock = definition.unlocks[unlock_index];
        if (unlock.level > _current_level
        && (is_undefined(next_unlock)
            || unlock.level < next_unlock.level))
        {
            next_unlock = unlock;
        }
    }
    return next_unlock;
}

function skill_level_prompts_at_level(_skill_id, _level)
{
    var definition = skill_definition(_skill_id);
    var matches = [];
    if (is_undefined(definition)) return matches;

    for (var prompt_index = 0;
        prompt_index < array_length(definition.level_prompts);
        prompt_index++)
    {
        var prompt = definition.level_prompts[prompt_index];
        if (prompt.level == _level) array_push(matches, prompt);
    }
    return matches;
}

function skill_unlock_is_available_state(
    _game_state,
    _skill_id,
    _unlock_key
)
{
    var unlock = skill_unlock_definition(_skill_id, _unlock_key);
    if (is_undefined(unlock)) return false;

    return skill_level_from_xp(
        _skill_id,
        skill_get_xp(_skill_id, _game_state)
    ) >= unlock.level;
}

function skill_levelup_pages(_skill_id, _level)
{
    var definition = skill_definition(_skill_id);
    if (is_undefined(definition)) return [];

    var pages = [
        "Congratulations! Your " + definition.display_name
            + " level is now " + string(_level) + "."
    ];
    var unlocks = skill_unlocks_at_level(_skill_id, _level);
    for (var unlock_index = 0;
        unlock_index < array_length(unlocks);
        unlock_index++)
    {
        var unlock = unlocks[unlock_index];
        array_push(
            pages,
            "New ability: " + unlock.title + ". "
                + unlock.description
        );
    }

    var prompts = skill_level_prompts_at_level(_skill_id, _level);
    for (var prompt_index = 0;
        prompt_index < array_length(prompts);
        prompt_index++)
    {
        var prompt = prompts[prompt_index];
        array_push(
            pages,
            {
                text: prompt.text,
                choices: prompt.choices
            }
        );
    }
    return pages;
}

function skill_xp_for_level(_level)
{
    var level = clamp(
        floor(_level),
        1,
        SKILL_MASTERY_LEVEL_CAP
    );
    if (level <= 1) return 0;

    // Reaching level 2 costs 100 XP. Each following level costs 100 XP
    // more than the one before it: 100, 200, 300, 400, and so on.
    var completed_levels = level - 1;
    return 50 * completed_levels * (completed_levels + 1);
}

function skill_level_from_xp(_skill_id, _xp)
{
    var definition = skill_definition(_skill_id);
    if (is_undefined(definition)) return 1;

    var xp = max(0, floor(_xp));
    var level = 1;
    while (level < definition.max_level
    && xp >= skill_xp_for_level(level + 1))
    {
        level += 1;
    }
    return level;
}
