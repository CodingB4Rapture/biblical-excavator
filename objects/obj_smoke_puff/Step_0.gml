/// obj_smoke_puff - Step Event

if (gameplay_is_paused()) exit;

x += horizontal_speed;
y += vertical_speed;

// Slowly expand.
puff_size += 0.04;

// Count down its life.
life -= 1;

if (life <= 0)
{
    instance_destroy();
}
