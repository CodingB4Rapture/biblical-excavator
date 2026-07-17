/// obj_rock - Create Event

game_state_ensure();

resource_id = ResourceId.FIELDSTONE;
rock_state = RockState.WAITING;

interaction_enabled = true;
interaction_radius = 24;
interaction_priority = 10;

interaction_get_prompt = function(_actor)
{
    if (rock_state != RockState.WAITING)
    {
        return "";
    }

    var current_game_state = game_state_ensure();

    if (!inventory_can_add(current_game_state.player_inventory, resource_id, 1))
    {
        return "Backpack full";
    }

    return "Pick up " + resource_get_name(resource_id);
};

interaction_run = function(_actor)
{
    if (rock_state == RockState.WAITING)
    {
        progress_collect_rock_by_hand(id);
    }
};

rock_stage = 0;
rock_tick_time = round(game_get_speed(gamespeed_fps) * 0.42);
rock_tick_timer = rock_tick_time;
rock_break_timer = 16;
rock_reward_source = noone;

// Stage 1 can break fast for +5, stage 2 for +10, stage 3 always breaks for +25.
rock_stage_chance = [0.34, 0.55, 1];
rock_stage_xp = [5, 10, 25];
rock_stage_frame = [1, 3, 5];

// Begin as an unmoving rock.
image_index = 0;
image_speed = 0;
