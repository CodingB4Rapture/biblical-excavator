/// obj_gui_hint - Step Event

age += 1;

if (!sticky)
{
    life -= 1;

    if (life <= 0)
    {
        instance_destroy();
    }
}
