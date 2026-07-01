/// obj_rock - Create Event

rock_state = RockState.WAITING;

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
