/// obj_gui_reward_summary - Step Event

if (gameplay_is_paused()) exit;

age += 1;
life -= 1;

if (life <= 0)
{
    instance_destroy();
}

