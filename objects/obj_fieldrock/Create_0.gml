/// obj_fieldrock - Create Event

game_state_ensure();

resource_id = ResourceId.FIELDROCK;
fieldrock_state = FieldrockState.WAITING;
// Include the room so future maps may reuse coordinates safely. Migrate the
// coordinate-only ID used by earlier format-version-one saves.
var legacy_world_id = "large_rock_" + string(round(x)) + "_" + string(round(y));
world_id = "large_rock_" + room_get_name(room) + "_"
    + string(round(x)) + "_" + string(round(y));

if (save_world_id_is_removed(legacy_world_id)
&& !save_world_id_is_removed(world_id))
{
    save_unmark_world_removed(legacy_world_id);
    save_mark_world_removed(world_id);
}

var fieldrock_record = fieldrock_record_ensure(
    world_id,
    room_get_name(room),
    x,
    y
);

if (!fieldrock_record_can_spawn(fieldrock_record))
{
    instance_destroy();
    exit;
}

if (fieldrock_record.respawn_day >= 0)
{
    fieldrock_record_make_available(fieldrock_record);
}

interaction_enabled = true;
interaction_radius = 24;
interaction_priority = 10;

interaction_get_prompt = function(_actor)
{
    if (fieldrock_state != FieldrockState.WAITING)
    {
        return "";
    }

    return "Fieldrock - use skidsteer";
};

interaction_run = function(_actor)
{
    notification_show_hint("This Fieldrock needs the skidsteer.", game_get_speed(gamespeed_fps) * 2, false);
};

fieldrock_stage = 0;
fieldrock_tick_time = round(game_get_speed(gamespeed_fps) * 0.42);
fieldrock_tick_timer = fieldrock_tick_time;
fieldrock_break_timer = 16;
fieldrock_reward_source = noone;

// Stage 1 can break fast for +5, stage 2 for +10, stage 3 always breaks for +25.
fieldrock_stage_chance = [0.34, 0.55, 1];
fieldrock_stage_xp = [5, 10, 25];
fieldrock_stage_frame = [1, 3, 5];

// Begin as an unmoving Fieldrock.
image_index = 0;
image_speed = 0;
