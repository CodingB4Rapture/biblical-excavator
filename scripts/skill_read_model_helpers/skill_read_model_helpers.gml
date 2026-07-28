/// Read-only skill presentation models.

function skill_get_read_model(_skill_id, _game_state = undefined)
{
    var game_state = is_undefined(_game_state)
        ? game_state_read()
        : _game_state;
    var definition = skill_definition(_skill_id);
    if (is_undefined(definition)) return undefined;

    var xp = skill_get_xp(_skill_id, game_state);
    var level = skill_level_from_xp(_skill_id, xp);
    var current_level_xp = skill_xp_for_level(level);
    var next_level_xp = level >= definition.max_level
        ? current_level_xp
        : skill_xp_for_level(level + 1);
    var span = max(1, next_level_xp - current_level_xp);

    return {
        id: _skill_id,
        name: definition.display_name,
        description: definition.description,
        max_level: definition.max_level,
        level: level,
        xp: xp,
        current_level_xp: current_level_xp,
        next_level_xp: next_level_xp,
        next_unlock: skill_next_unlock_definition(_skill_id, level),
        progress: level >= definition.max_level
            ? 1
            : clamp((xp - current_level_xp) / span, 0, 1)
    };
}
