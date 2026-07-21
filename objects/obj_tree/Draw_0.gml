/// obj_tree - Draw Event

var shake_x = 0;
if (tree_state == TreeState.CHOPPING)
{
    shake_x = ((chop_shake_timer div 4) mod 2) * 2 - 1;
}

draw_sprite_ext(
    sprite_index,
    image_index,
    x + shake_x,
    y,
    image_xscale,
    image_yscale,
    image_angle,
    image_blend,
    image_alpha
);

if (tree_state == TreeState.CHOPPING
|| (chop_progress > 0 && tree_state == TreeState.STANDING))
{
    var progress_label = tree_state == TreeState.CHOPPING
        ? "Chopping"
        : "Chopping paused";
    world_draw_progress_bar(x, bbox_top - 10, 42, chop_progress / chop_duration, progress_label);
}
