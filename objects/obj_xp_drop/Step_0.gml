/// obj_xp_drop - Step Event

if (gameplay_is_paused()) exit;

y -= rise_speed;
life -= 1;

if (life <= 0)
{
    instance_destroy();
}

