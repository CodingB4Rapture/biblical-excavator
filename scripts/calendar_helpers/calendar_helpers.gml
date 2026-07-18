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
        && game_state.cabin_site_placed;
}

function calendar_update()
{
    if (!calendar_should_run()) return;

    var game_state = game_state_ensure();
    var real_seconds = delta_time / 1000000;
    var game_minutes_per_real_second =
        CALENDAR_MINUTES_PER_DAY / CALENDAR_FULL_DAY_REAL_SECONDS;

    game_state.time_of_day += real_seconds * game_minutes_per_real_second;

    while (game_state.time_of_day >= CALENDAR_MINUTES_PER_DAY)
    {
        game_state.time_of_day -= CALENDAR_MINUTES_PER_DAY;
        game_state.day_number += 1;
    }
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

function cabin_sleep_until_morning()
{
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

    var game_state = game_state_ensure();
    game_state.day_number += 1;
    game_state.time_of_day = CALENDAR_MORNING_MINUTE;

    notification_show_hint(
        "You sleep through the night. Day " + string(game_state.day_number)
            + " begins at 6:00 AM.",
        game_get_speed(gamespeed_fps) * 5,
        false
    );

    save_write();
    return true;
}
