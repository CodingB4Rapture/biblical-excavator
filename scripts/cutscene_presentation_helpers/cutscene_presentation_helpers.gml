/// Runtime interpretation of authored cutscene definitions.

function cutscene_approach_value(_current, _target, _amount)
{
    var difference = _target - _current;
    var amount = max(0, abs(_amount));
    if (abs(difference) <= amount)
        return _target;
    return _current + sign(difference) * amount;
}

function cutscene_actor_resolve(_actor_id)
{
    switch (_actor_id)
    {
        case CUTSCENE_ACTOR_PLAYER:
            return instance_find(obj_player, 0);
        case CUTSCENE_ACTOR_FARMER:
            return instance_find(obj_farmer, 0);
    }
    return noone;
}

function cutscene_controller_configure(
    _controller,
    _cutscene_id,
    _checkpoint = 0
)
{
    var definition = cutscene_definition(_cutscene_id);
    if (!instance_exists(_controller) || is_undefined(definition))
        return false;

    _controller.cutscene_id = _cutscene_id;
    _controller.definition = definition;
    _controller.step_index = cutscene_definition_resume_step(
        definition,
        _checkpoint
    );
    _controller.step_started = false;
    _controller.step_timer = 0;
    _controller.move_timeout = 0;
    _controller.fade_alpha = cutscene_definition_resume_fade(
        definition,
        _checkpoint
    );
    _controller.caption_text = "";
    _controller.input_locked = true;
    return true;
}

function cutscene_controller_advance(_controller)
{
    _controller.step_index += 1;
    _controller.step_started = false;
    _controller.step_timer = 0;
    _controller.move_timeout = 0;
}

/// Runs only instant, hidden setup steps before the room can draw. Authored
/// waits, captions, movement, and dialogue still advance normally over time.
function cutscene_controller_prime_hidden_setup(_controller)
{
    var safety = 0;
    while (instance_exists(_controller)
    && is_struct(_controller.definition)
    && _controller.step_index >= 0
    && _controller.step_index
        < array_length(_controller.definition.steps)
    && safety < 16)
    {
        var step_type =
            _controller.definition.steps[_controller.step_index].type;
        if (step_type != CutsceneStepType.LOCK_INPUT
        && step_type != CutsceneStepType.REPOSITION_ACTOR
        && step_type != CutsceneStepType.CAMERA_FOCUS)
        {
            break;
        }

        var previous_index = _controller.step_index;
        cutscene_controller_update(_controller);
        if (_controller.step_index == previous_index)
            break;
        safety += 1;
    }
    return true;
}

function cutscene_controller_finish(_controller)
{
    var game_state = game_state_ensure();
    cutscene_state_complete(game_state, _controller.cutscene_id);
    camera_follow_gameplay();
    input_lock_interaction(3);
    save_write();
    instance_destroy(_controller);
    return true;
}

function cutscene_actor_move_step(_controller, _step)
{
    var actor = cutscene_actor_resolve(_step.actor_id);
    if (!instance_exists(actor)) return false;

    var target_x = variable_struct_exists(_step, "x")
        ? _step.x
        : actor.x;
    var target_y = variable_struct_exists(_step, "y")
        ? _step.y
        : actor.y;
    if (variable_struct_exists(_step, "target_actor_id"))
    {
        var target_actor = cutscene_actor_resolve(
            _step.target_actor_id
        );
        if (!instance_exists(target_actor)) return false;
        target_x = target_actor.x
            + (variable_struct_exists(_step, "offset_x")
                ? _step.offset_x
                : 0);
        target_y = target_actor.y
            + (variable_struct_exists(_step, "offset_y")
                ? _step.offset_y
                : 0);
    }

    var tolerance = variable_struct_exists(_step, "tolerance")
        ? max(1, _step.tolerance)
        : 2;
    var distance = point_distance(
        actor.x,
        actor.y,
        target_x,
        target_y
    );
    if (distance <= tolerance)
    {
        actor.x = target_x;
        actor.y = target_y;
        actor.image_speed = 0;
        actor.image_index = 0;
        return true;
    }

    var actor_speed = variable_struct_exists(_step, "speed")
        ? max(0.1, _step.speed)
        : 0.5;
    var move_direction = point_direction(
        actor.x,
        actor.y,
        target_x,
        target_y
    );
    actor.x += lengthdir_x(
        min(actor_speed, distance),
        move_direction
    );
    actor.y += lengthdir_y(
        min(actor_speed, distance),
        move_direction
    );
    actor.image_speed = 0.14;
    _controller.move_timeout += 1;

    var timeout_frames = variable_struct_exists(
        _step,
        "timeout_frames"
    )
        ? max(1, _step.timeout_frames)
        : 360;
    if (_controller.move_timeout >= timeout_frames)
    {
        // Progression never depends on navigation reaching an exact pixel.
        // A future pathfinder can replace this movement owner without
        // changing any authored cutscene definition.
        actor.x = target_x;
        actor.y = target_y;
        actor.image_speed = 0;
        actor.image_index = 0;
        return true;
    }
    return false;
}

function cutscene_controller_update(_controller)
{
    if (!is_struct(_controller.definition)
    || _controller.step_index < 0
    || _controller.step_index
        >= array_length(_controller.definition.steps))
    {
        return cutscene_controller_finish(_controller);
    }

    var step = _controller.definition.steps[_controller.step_index];
    switch (step.type)
    {
        case CutsceneStepType.LOCK_INPUT:
            _controller.input_locked = true;
            cutscene_controller_advance(_controller);
            break;

        case CutsceneStepType.FADE:
            _controller.fade_alpha = cutscene_approach_value(
                _controller.fade_alpha,
                step.alpha,
                step.speed
            );
            if (abs(_controller.fade_alpha - step.alpha) < 0.001)
                cutscene_controller_advance(_controller);
            break;

        case CutsceneStepType.CAPTION:
            if (!_controller.step_started)
            {
                _controller.caption_text = step.text;
                _controller.step_timer = step.frames;
                _controller.step_started = true;
            }
            _controller.step_timer -= 1;
            if (_controller.step_timer <= 0)
            {
                _controller.caption_text = "";
                cutscene_controller_advance(_controller);
            }
            break;

        case CutsceneStepType.REPOSITION_ACTOR:
        {
            var actor = cutscene_actor_resolve(step.actor_id);
            if (!instance_exists(actor)) break;
            var reposition_x = variable_struct_exists(step, "x")
                ? step.x
                : actor.x;
            var reposition_y = variable_struct_exists(step, "y")
                ? step.y
                : actor.y;
            if (variable_struct_exists(step, "target_actor_id"))
            {
                var target_actor = cutscene_actor_resolve(
                    step.target_actor_id
                );
                if (!instance_exists(target_actor)) break;
                reposition_x = target_actor.x
                    + (variable_struct_exists(step, "offset_x")
                        ? step.offset_x
                        : 0);
                reposition_y = target_actor.y
                    + (variable_struct_exists(step, "offset_y")
                        ? step.offset_y
                        : 0);
            }
            actor.x = reposition_x;
            actor.y = reposition_y;
            actor.image_angle = variable_struct_exists(step, "angle")
                ? step.angle
                : 0;
            actor.image_speed = 0;
            actor.image_index = 0;
            cutscene_controller_advance(_controller);
            break;
        }

        case CutsceneStepType.MOVE_ACTOR:
            if (cutscene_actor_move_step(_controller, step))
                cutscene_controller_advance(_controller);
            break;

        case CutsceneStepType.CAMERA_FOCUS:
        {
            var first_actor = cutscene_actor_resolve(
                step.first_actor_id
            );
            var second_actor = cutscene_actor_resolve(
                step.second_actor_id
            );
            if (!instance_exists(first_actor)
            || !instance_exists(second_actor))
            {
                break;
            }
            camera_focus_between(
                first_actor,
                second_actor,
                step.zoom,
                0
            );
            cutscene_controller_advance(_controller);
            break;
        }

        case CutsceneStepType.DIALOGUE:
            if (!_controller.step_started)
            {
                var speaker_actor = cutscene_actor_resolve(
                    step.actor_id
                );
                if (!instance_exists(speaker_actor)) break;
                notification_show_dialogue(
                    step.pages,
                    speaker_actor,
                    0,
                    NotificationStyle.PROMPT,
                    step.speaker
                );
                _controller.step_started = true;
            }
            else if (!dialogue_is_active())
            {
                cutscene_controller_advance(_controller);
            }
            break;

        case CutsceneStepType.WAIT:
            if (!_controller.step_started)
            {
                _controller.step_timer = step.frames;
                _controller.step_started = true;
            }
            _controller.step_timer -= 1;
            if (_controller.step_timer <= 0)
                cutscene_controller_advance(_controller);
            break;

        case CutsceneStepType.COMMAND:
            if (cutscene_execute_command(step.command_id))
                cutscene_controller_advance(_controller);
            break;

        case CutsceneStepType.CHECKPOINT:
            cutscene_state_set_checkpoint(
                game_state_ensure(),
                _controller.cutscene_id,
                step.checkpoint
            );
            save_write();
            cutscene_controller_advance(_controller);
            break;

        case CutsceneStepType.COMPLETE:
            cutscene_controller_finish(_controller);
            break;
    }
    return true;
}

function cutscene_controller_draw(_controller)
{
    var gui_w = display_get_gui_width();
    var gui_h = display_get_gui_height();
    if (_controller.fade_alpha > 0)
    {
        draw_set_alpha(_controller.fade_alpha);
        draw_set_color(c_black);
        draw_rectangle(0, 0, gui_w, gui_h, false);
    }

    if (_controller.caption_text != "")
    {
        draw_set_alpha(1);
        draw_set_halign(fa_center);
        draw_set_valign(fa_middle);
        draw_set_font(dialogue_font);
        draw_set_color(c_black);
        draw_text(
            gui_w * 0.5 + 2,
            gui_h * 0.78 + 2,
            _controller.caption_text
        );
        draw_set_color(make_color_rgb(244, 232, 203));
        draw_text(
            gui_w * 0.5,
            gui_h * 0.78,
            _controller.caption_text
        );
    }

    draw_set_alpha(1);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    draw_set_font(-1);
    draw_set_color(c_white);
}
