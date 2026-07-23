/// obj_fence_planning_controller - Draw Event

var preview_colour = (preview_in_room && placement_result.valid)
    ? make_color_rgb(92, 210, 126)
    : make_color_rgb(224, 82, 72);
var half_grid = fence_grid_size() * 0.5;

if (cabin_tutorial_mode)
{
    draw_set_alpha(0.10);
    draw_set_color(make_color_rgb(255, 206, 103));
    draw_rectangle(
        tutorial_bounds.min_x,
        tutorial_bounds.min_y,
        tutorial_bounds.max_x,
        tutorial_bounds.max_y,
        false
    );

    draw_set_alpha(0.75);
    draw_rectangle(
        tutorial_bounds.min_x,
        tutorial_bounds.min_y,
        tutorial_bounds.max_x,
        tutorial_bounds.max_y,
        true
    );

    var corner_xs = [tutorial_bounds.min_x, tutorial_bounds.max_x];
    var corner_ys = [tutorial_bounds.min_y, tutorial_bounds.max_y];

    for (var corner_x_index = 0; corner_x_index < 2; corner_x_index++)
    {
        for (var corner_y_index = 0; corner_y_index < 2; corner_y_index++)
        {
            var corner_x = corner_xs[corner_x_index];
            var corner_y = corner_ys[corner_y_index];
            draw_rectangle(
                corner_x - half_grid,
                corner_y - half_grid,
                corner_x + half_grid,
                corner_y + half_grid,
                true
            );
        }
    }

    draw_set_alpha(0.9);
    draw_set_color(make_color_rgb(112, 220, 132));
    draw_line_width(
        tutorial_bounds.min_x + fence_grid_size(),
        tutorial_bounds.max_y,
        tutorial_bounds.max_x - fence_grid_size(),
        tutorial_bounds.max_y,
        3
    );
}

if (gate_mode)
{
    var gate_left_x = placement_result.gate_x;

    draw_set_alpha(0.28);
    draw_set_color(preview_colour);
    draw_rectangle(
        gate_left_x - half_grid,
        preview_y - half_grid,
        gate_left_x + fence_grid_size() + half_grid,
        preview_y + half_grid,
        false
    );
    draw_set_alpha(0.9);
    draw_rectangle(
        gate_left_x - half_grid,
        preview_y - half_grid,
        gate_left_x + fence_grid_size() + half_grid,
        preview_y + half_grid,
        true
    );
    draw_set_alpha(0.65);
    draw_sprite_ext(
        spr_fence_gate,
        0,
        gate_left_x + half_grid,
        preview_y,
        1,
        1,
        0,
        preview_colour,
        1
    );
}
else if (anchor_set)
{
    draw_set_alpha(0.12);
    draw_set_color(preview_colour);
    draw_rectangle(anchor_x, anchor_y, preview_x, preview_y, false);

    for (var preview_index = 0;
        preview_index < array_length(preview_records);
        preview_index++)
    {
        var preview_sprite = fence_sprite_for_record(
            preview_records,
            preview_index
        );
        var preview_record = preview_records[preview_index];
        draw_set_alpha(0.72);
        draw_sprite_ext(
            preview_sprite,
            0,
            preview_record.x,
            preview_record.y,
            1,
            1,
            0,
            preview_colour,
            1
        );
    }

    draw_set_alpha(1);
    draw_set_color(make_color_rgb(255, 220, 92));
    draw_rectangle(
        anchor_x - half_grid,
        anchor_y - half_grid,
        anchor_x + half_grid,
        anchor_y + half_grid,
        true
    );
}
else
{
    draw_set_alpha(0.28);
    draw_set_color(preview_colour);
    draw_rectangle(
        preview_x - half_grid,
        preview_y - half_grid,
        preview_x + half_grid,
        preview_y + half_grid,
        false
    );
    draw_set_alpha(0.9);
    draw_rectangle(
        preview_x - half_grid,
        preview_y - half_grid,
        preview_x + half_grid,
        preview_y + half_grid,
        true
    );
}

draw_set_alpha(1);
draw_set_color(c_white);
