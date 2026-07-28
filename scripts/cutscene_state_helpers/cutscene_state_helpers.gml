/// Durable authored-cutscene checkpoints. Animation frames and actor positions
/// remain transient; only safe narrative checkpoints are persisted.

function cutscene_record_create(
    _cutscene_id,
    _status = CutsceneStatus.NOT_STARTED,
    _checkpoint = 0
)
{
    return {
        id: _cutscene_id,
        status: _status,
        checkpoint: max(0, floor(_checkpoint))
    };
}

function cutscene_state_create_default_records()
{
    return [
        cutscene_record_create(CUTSCENE_INTRO_RESCUE),
        cutscene_record_create(CUTSCENE_AXE_HANDOFF),
        cutscene_record_create(CUTSCENE_WATER_SUPPLY)
    ];
}

function cutscene_state_infer_status(_game_state, _cutscene_id)
{
    switch (_cutscene_id)
    {
        case CUTSCENE_INTRO_RESCUE:
            return variable_struct_exists(
                _game_state,
                "tutorial_intro_seen"
            ) && _game_state.tutorial_intro_seen
                ? CutsceneStatus.COMPLETE
                : CutsceneStatus.NOT_STARTED;

        case CUTSCENE_AXE_HANDOFF:
            return variable_struct_exists(_game_state, "tools")
                && is_struct(_game_state.tools)
                && variable_struct_exists(
                    _game_state.tools,
                    "axe_owned"
                )
                && _game_state.tools.axe_owned
                    ? CutsceneStatus.COMPLETE
                    : CutsceneStatus.NOT_STARTED;

        case CUTSCENE_WATER_SUPPLY:
        {
            var cabin_built =
                variable_struct_exists(_game_state, "cabin_built")
                && _game_state.cabin_built;
            var water_complete =
                variable_struct_exists(
                    _game_state,
                    "water_tutorial_stage"
                )
                && _game_state.water_tutorial_stage
                    == WaterTutorialStage.COMPLETE;
            var hub_open =
                variable_struct_exists(_game_state, "homestead_stage")
                && _game_state.homestead_stage
                    == HomesteadStage.HUB_OPEN;
            if (water_complete || hub_open)
                return CutsceneStatus.COMPLETE;
            return cabin_built
                ? CutsceneStatus.ACTIVE
                : CutsceneStatus.NOT_STARTED;
        }
    }
    return CutsceneStatus.NOT_STARTED;
}

function cutscene_state_find_record_index(_game_state, _cutscene_id)
{
    for (var index = 0;
        index < array_length(_game_state.cutscene_records);
        index++)
    {
        var record = _game_state.cutscene_records[index];
        if (is_struct(record)
        && variable_struct_exists(record, "id")
        && record.id == _cutscene_id)
        {
            return index;
        }
    }
    return -1;
}

function cutscene_state_ensure(_game_state)
{
    if (!variable_struct_exists(_game_state, "cutscene_records")
    || !is_array(_game_state.cutscene_records))
    {
        _game_state.cutscene_records = [
            cutscene_record_create(
                CUTSCENE_INTRO_RESCUE,
                cutscene_state_infer_status(
                    _game_state,
                    CUTSCENE_INTRO_RESCUE
                )
            ),
            cutscene_record_create(
                CUTSCENE_AXE_HANDOFF,
                cutscene_state_infer_status(
                    _game_state,
                    CUTSCENE_AXE_HANDOFF
                )
            ),
            cutscene_record_create(
                CUTSCENE_WATER_SUPPLY,
                cutscene_state_infer_status(
                    _game_state,
                    CUTSCENE_WATER_SUPPLY
                )
            )
        ];
    }

    var required_ids = [
        CUTSCENE_INTRO_RESCUE,
        CUTSCENE_AXE_HANDOFF,
        CUTSCENE_WATER_SUPPLY
    ];
    for (var required_index = 0;
        required_index < array_length(required_ids);
        required_index++)
    {
        var required_id = required_ids[required_index];
        if (cutscene_state_find_record_index(
            _game_state,
            required_id
        ) < 0)
        {
            array_push(
                _game_state.cutscene_records,
                cutscene_record_create(
                    required_id,
                    cutscene_state_infer_status(
                        _game_state,
                        required_id
                    )
                )
            );
        }
    }

    for (var record_index = 0;
        record_index < array_length(_game_state.cutscene_records);
        record_index++)
    {
        var record = _game_state.cutscene_records[record_index];
        if (!is_struct(record)
        || !variable_struct_exists(record, "id"))
        {
            continue;
        }
        if (!variable_struct_exists(record, "status")
        || record.status < CutsceneStatus.NOT_STARTED
        || record.status > CutsceneStatus.COMPLETE)
        {
            record.status = CutsceneStatus.NOT_STARTED;
        }
        if (!variable_struct_exists(record, "checkpoint")
        || !is_numeric(record.checkpoint))
        {
            record.checkpoint = 0;
        }
        record.checkpoint = max(0, floor(record.checkpoint));
    }
    return _game_state;
}

function cutscene_state_get_record(_game_state, _cutscene_id)
{
    cutscene_state_ensure(_game_state);
    var index = cutscene_state_find_record_index(
        _game_state,
        _cutscene_id
    );
    return index < 0 ? undefined : _game_state.cutscene_records[index];
}

function cutscene_state_activate(_game_state, _cutscene_id)
{
    var record = cutscene_state_get_record(_game_state, _cutscene_id);
    if (is_undefined(record)
    || record.status == CutsceneStatus.COMPLETE)
    {
        return false;
    }
    record.status = CutsceneStatus.ACTIVE;
    return true;
}

function cutscene_state_set_checkpoint(
    _game_state,
    _cutscene_id,
    _checkpoint
)
{
    var record = cutscene_state_get_record(_game_state, _cutscene_id);
    if (is_undefined(record)
    || record.status != CutsceneStatus.ACTIVE)
    {
        return false;
    }
    record.checkpoint = max(record.checkpoint, floor(_checkpoint));
    return true;
}

function cutscene_state_complete(_game_state, _cutscene_id)
{
    var record = cutscene_state_get_record(_game_state, _cutscene_id);
    if (is_undefined(record)) return false;
    record.status = CutsceneStatus.COMPLETE;
    return true;
}
