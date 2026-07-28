/// obj_dialogue_bubble - Draw GUI Event

var page = pages[page_index];
var page_text = dialogue_page_text(page);
var choices = dialogue_page_choices(page);
var layout = dialogue_get_layout(
    page_text,
    -1,
    -1,
    array_length(choices)
);
var palette = dialogue_get_palette(speaker_name);

dialogue_draw_panel(layout, palette);
dialogue_draw_portrait(layout, palette, speaker_name);

draw_set_halign(fa_left);
draw_set_valign(fa_top);

draw_set_font(dialogue_font);
draw_set_color(make_color_rgb(18, 14, 10));
draw_text_transformed(layout.text_left + 1, layout.speaker_top + 1, speaker_name, 0.70, 0.70, 0);
draw_set_color(palette.border_gold);
draw_text_transformed(layout.text_left, layout.speaker_top, speaker_name, 0.70, 0.70, 0);

draw_set_alpha(0.42);
draw_set_color(palette.border_gold);
draw_line(
    layout.text_left,
    layout.speaker_top + layout.speaker_height + 6,
    layout.text_right,
    layout.speaker_top + layout.speaker_height + 6
);
draw_set_alpha(1);

draw_set_font(dialogue_font);
draw_set_color(palette.text_color);
draw_text_ext_transformed(
    layout.text_left,
    layout.body_y,
    page_text,
    layout.body_line_sep,
    layout.body_wrap_width,
    layout.body_scale,
    layout.body_scale,
    0
);

draw_set_halign(fa_right);
draw_set_valign(fa_bottom);
draw_set_font(-1);
draw_set_color(palette.prompt_color);

if (array_length(choices) > 0)
{
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    for (var choice_draw = 0;
        choice_draw < array_length(choices);
        choice_draw++)
    {
        var choice_rect = dialogue_choice_get_rect(
            layout,
            choice_draw,
            array_length(choices)
        );
        var selected = choice_draw == choice_index;
        draw_set_color(selected
            ? palette.border_gold
            : palette.border_dark);
        draw_roundrect(
            choice_rect.left,
            choice_rect.top,
            choice_rect.right,
            choice_rect.bottom,
            false
        );
        draw_set_color(selected
            ? palette.panel_color
            : palette.panel_shadow);
        draw_roundrect(
            choice_rect.left + 2,
            choice_rect.top + 2,
            choice_rect.right - 2,
            choice_rect.bottom - 2,
            false
        );
        draw_set_color(selected
            ? palette.text_color
            : palette.prompt_color);
        draw_text(
            (choice_rect.left + choice_rect.right) * 0.5,
            (choice_rect.top + choice_rect.bottom) * 0.5,
            choices[choice_draw].label
        );
    }
}
else
{
    var advance_text = "Continue: Click / E / Enter / Space";
    if (array_length(pages) > 1)
    {
        advance_text += "    " + string(page_index + 1) + "/"
            + string(array_length(pages));
    }
    draw_text(layout.text_right, layout.prompt_y, advance_text);
}

draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(c_white);
draw_set_font(-1);
