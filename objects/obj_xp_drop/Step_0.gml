/// obj_xp_drop - Step Event

y -= rise_speed;
life -= 1;

if (life <= 0)
{
    instance_destroy();
}

