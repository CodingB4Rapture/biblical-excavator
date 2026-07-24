/// Runtime settings defaults, application, and save-slot coordination.

function settings_ensure()
{
    if (!variable_global_exists("game_settings") || !is_struct(global.game_settings))
    {
        global.game_settings = {
            master_volume: 1,
            fullscreen: window_get_fullscreen()
        };
    }

    return global.game_settings;
}

function settings_apply()
{
    var settings = settings_ensure();
    audio_master_gain(settings.master_volume);
    window_set_fullscreen(settings.fullscreen);
}

function save_update_settings()
{
    if (!save_slot_exists())
    {
        return false;
    }

    var save_file = file_text_open_read(save_file_name());
    var save_text = file_text_read_string(save_file);
    file_text_close(save_file);

    try
    {
        var data = json_parse(save_text);
        data = save_migrate_to_current(data);
        if (is_undefined(data)) return false;

        if (!variable_struct_exists(data, "settings")
        || !is_struct(data.settings))
        {
            data.settings = {};
        }

        var settings = settings_ensure();
        data.settings.master_volume = settings.master_volume;
        data.settings.fullscreen = settings.fullscreen;
        return save_write_snapshot(data);
    }
    catch (_error)
    {
        return false;
    }
}
