/// obj_dialogue_bubble - Step Event

life -= 1;

if (instance_exists(follow_target))
{
    x = follow_target.x;
    y = follow_target.y;
}

if (life <= 0)
{
    instance_destroy();
}

