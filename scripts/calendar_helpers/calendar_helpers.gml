/// The durable calendar values live in global.game_state.
/// Change this one value to tune the real-time length of a full game day.
#macro CALENDAR_FULL_DAY_REAL_SECONDS 900

#macro CALENDAR_MINUTES_PER_DAY 1440
#macro CALENDAR_MORNING_MINUTE 360
#macro CALENDAR_NIGHT_MINUTE 1080

function calendar_should_run()
{
    var game_state = game_state_ensure();
    return game_state.tutorial_stage == TutorialStage.COMPLETE
        && game_state.cabin_built
        && game_state.homestead_stage == HomesteadStage.HUB_OPEN;
}

function calendar_update()
{
    if (!calendar_should_run()) return;

    var controller = instance_find(obj_game_controller, 0);
    if (instance_exists(controller) && controller.day_transition_active) return;

    var game_state = game_state_ensure();
    var real_seconds = delta_time / 1000000;
    var game_minutes_per_real_second =
        CALENDAR_MINUTES_PER_DAY / CALENDAR_FULL_DAY_REAL_SECONDS;

    game_state.time_of_day += real_seconds * game_minutes_per_real_second;

    while (game_state.time_of_day >= CALENDAR_MINUTES_PER_DAY)
    {
        game_state.time_of_day -= CALENDAR_MINUTES_PER_DAY;
        game_state.day_number += 1;
        calendar_show_day_transition();
    }
}

function calendar_show_day_transition()
{
    var controller = instance_find(obj_game_controller, 0);
    if (!instance_exists(controller) || controller.day_transition_active) return false;

    var game_state = game_state_ensure();
    // Advancing a day is an explicit workshop progression event. Players may
    // intentionally use it to finish both active machine jobs.
    production_finish_all_jobs();
    controller.day_transition_active = true;
    controller.day_transition_timer = 0;
    controller.day_transition_day = game_state.day_number;
    controller.day_transition_resources = array_create(ResourceId.COUNT, 0);

    for (var resource_id = 0; resource_id < ResourceId.COUNT; resource_id++)
    {
        controller.day_transition_resources[resource_id] =
            game_state.daily_resources_gathered[resource_id];
        game_state.daily_resources_gathered[resource_id] = 0;
    }

    gameplay_set_paused(true);
    return true;
}

function calendar_show_pending_hub_intro()
{
    var game_state = game_state_ensure();

    if (!game_state.first_hub_hint_pending
    || game_state.homestead_stage != HomesteadStage.HUB_OPEN)
    {
        return false;
    }

    game_state.first_hub_hint_pending = false;
    notification_show_hint(
        "First homestead morning. Talk with the Farmer's Wife when you're ready for what comes next.",
        game_get_speed(gamespeed_fps) * 6,
        false
    );
    return true;
}

function calendar_is_nighttime()
{
    var time_of_day = game_state_ensure().time_of_day;
    return time_of_day >= CALENDAR_NIGHT_MINUTE
        || time_of_day < CALENDAR_MORNING_MINUTE;
}

function calendar_get_time_text()
{
    var total_minutes = floor(game_state_ensure().time_of_day);
    var hour_24 = floor(total_minutes / 60);
    var minute = total_minutes mod 60;
    var suffix = hour_24 < 12 ? "AM" : "PM";
    var hour_12 = hour_24 mod 12;
    var minute_text = minute < 10 ? "0" + string(minute) : string(minute);

    if (hour_12 == 0) hour_12 = 12;

    return string(hour_12) + ":" + minute_text + " " + suffix;
}

function calendar_get_status_layout(_gui_w = -1, _gui_h = -1)
{
    if (_gui_w < 0) _gui_w = display_get_gui_width();
    if (_gui_h < 0) _gui_h = display_get_gui_height();

    var margin = 14;
    var panel_width = min(150, max(100, _gui_w - margin * 2));
    var panel_height = 52;
    var panel_right = _gui_w - margin;
    var panel_top = margin;

    return {
        left: panel_right - panel_width,
        top: panel_top,
        right: panel_right,
        bottom: panel_top + panel_height
    };
}

function calendar_draw_status()
{
    if (!calendar_should_run()) return false;

    var game_state = game_state_ensure();
    var layout = calendar_get_status_layout();
    var panel_color = make_color_rgb(21, 25, 24);
    var panel_edge = make_color_rgb(74, 57, 30);
    var panel_gold = make_color_rgb(196, 145, 49);
    var text_color = make_color_rgb(235, 224, 198);
    var accent_color = make_color_rgb(255, 220, 92);

    draw_set_font(-1);
    draw_set_alpha(0.92);
    draw_set_color(panel_edge);
    draw_roundrect(
        layout.left,
        layout.top,
        layout.right,
        layout.bottom,
        false
    );
    draw_set_color(panel_gold);
    draw_roundrect(
        layout.left + 2,
        layout.top + 2,
        layout.right - 2,
        layout.bottom - 2,
        true
    );
    draw_set_alpha(0.88);
    draw_set_color(panel_color);
    draw_roundrect(
        layout.left + 4,
        layout.top + 4,
        layout.right - 4,
        layout.bottom - 4,
        false
    );

    draw_set_alpha(1);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    draw_set_color(accent_color);
    draw_text(
        layout.left + 12,
        layout.top + 8,
        "Day " + string(game_state.day_number)
    );
    draw_set_color(text_color);
    draw_text(
        layout.left + 12,
        layout.top + 27,
        calendar_get_time_text()
    );
    draw_set_color(c_white);
    return true;
}

function cabin_sleep_until_morning(_actor = noone)
{
    var game_state = game_state_ensure();

    if (game_state.homestead_stage == HomesteadStage.FIRST_REST_REQUIRED)
    {
        if (task_get_status(TaskId.PLACE_CABIN) != TaskStatus.CLAIMED)
        {
            notification_show_hint(
                "Claim the completed cabin task at the Task Board before resting.",
                game_get_speed(gamespeed_fps) * 4,
                false
            );
            return false;
        }

        if (!progression_open_homestead_hub_state(game_state))
            return false;
        game_state.day_number += 1;
        game_state.time_of_day = CALENDAR_MORNING_MINUTE;
        cabin_place_actor_at_exit(_actor);
        calendar_show_day_transition();
        save_write();
        return true;
    }

    if (!calendar_should_run()) return false;

    if (!calendar_is_nighttime())
    {
        notification_show_hint(
            "It is too early to sleep. Come back after 6:00 PM.",
            game_get_speed(gamespeed_fps) * 4,
            false
        );
        return false;
    }

    game_state.day_number += 1;
    game_state.time_of_day = CALENDAR_MORNING_MINUTE;
    cabin_place_actor_at_exit(_actor);
    calendar_show_day_transition();

    save_write();
    return true;
}
