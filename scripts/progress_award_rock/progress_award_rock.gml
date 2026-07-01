/// progress_award_rock(rock_amount, xp_amount, source_instance)
///
/// Updates early resource totals and shows reward feedback.
function progress_ensure_inventory()
{
    if (!variable_global_exists("rock_carry_max")) global.rock_carry_max = 10;
    if (!variable_global_exists("log_carry_max")) global.log_carry_max = 1;

    if (!variable_global_exists("carried_rocks")) global.carried_rocks = 0;
    if (!variable_global_exists("carried_logs")) global.carried_logs = 0;

    if (!variable_global_exists("trip_rocks_depleted")) global.trip_rocks_depleted = 0;
    if (!variable_global_exists("trip_xp_gained")) global.trip_xp_gained = 0;

    if (!variable_global_exists("home_rocks")) global.home_rocks = 0;
    if (!variable_global_exists("home_logs")) global.home_logs = 0;

    if (!variable_global_exists("equipment_xp")) global.equipment_xp = 0;
}

function progress_can_collect_rocks(_amount)
{
    progress_ensure_inventory();
    return global.carried_rocks + _amount <= global.rock_carry_max;
}

function progress_show_reward_summary(_line_one, _line_two)
{
    var reward_summary = instance_find(obj_gui_reward_summary, 0);

    if (reward_summary == noone)
    {
        reward_summary = instance_create_depth(0, 0, -1200, obj_gui_reward_summary);
    }

    reward_summary.line_one = _line_one;
    reward_summary.line_two = _line_two;
    reward_summary.life = reward_summary.life_max;
    reward_summary.age = 0;

    return reward_summary;
}

function progress_award_rock(_rock_amount, _xp_amount, _source_instance)
{
    progress_ensure_inventory();

    if (!progress_can_collect_rocks(_rock_amount))
    {
        return 0;
    }

    global.carried_rocks += _rock_amount;
    global.trip_rocks_depleted += _rock_amount;
    global.trip_xp_gained += _xp_amount;
    global.equipment_xp += _xp_amount;

    var rock_word = (_rock_amount == 1) ? "Rock" : "Rocks";
    progress_show_reward_summary(
        "Collected " + string(_rock_amount) + " " + rock_word,
        "+" + string(_xp_amount) + " XP"
    );

    var drop_x = 0;
    var drop_y = 0;

    if (instance_exists(_source_instance))
    {
        drop_x = _source_instance.x + random_range(-5, 5);
        drop_y = _source_instance.y - 18;
    }

    var xp_drop = instance_create_depth(drop_x, drop_y, -900, obj_xp_drop);
    xp_drop.xp_amount = _xp_amount;

    return _xp_amount;
}

function progress_dropoff_homebase()
{
    progress_ensure_inventory();

    var dropped_rocks = global.carried_rocks;
    var dropped_logs = global.carried_logs;

    if (dropped_rocks <= 0 && dropped_logs <= 0)
    {
        return false;
    }

    global.home_rocks += dropped_rocks;
    global.home_logs += dropped_logs;

    global.carried_rocks = 0;
    global.carried_logs = 0;
    global.trip_rocks_depleted = 0;
    global.trip_xp_gained = 0;

    var rock_word = (dropped_rocks == 1) ? "Rock" : "Rocks";
    var log_word = (dropped_logs == 1) ? "Log" : "Logs";
    var dropoff_line = "";

    if (dropped_rocks > 0)
    {
        dropoff_line = "Stored " + string(dropped_rocks) + " " + rock_word;
    }

    if (dropped_logs > 0)
    {
        if (dropoff_line == "")
        {
            dropoff_line = "Stored " + string(dropped_logs) + " " + log_word;
        }
        else
        {
            dropoff_line += ", " + string(dropped_logs) + " " + log_word;
        }
    }

    progress_show_reward_summary(
        "Homebase Drop-off",
        dropoff_line
    );

    return true;
}
