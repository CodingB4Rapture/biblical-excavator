/// obj_dialogue_bubble - Draw GUI Event

var page_text = pages[page_index];
var layout = dialogue_get_layout(page_text);
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
draw_text_ext(
    layout.text_left,
    layout.body_y,
    page_text,
    layout.body_line_sep,
    layout.body_width
);

draw_set_halign(fa_right);
draw_set_valign(fa_bottom);
draw_set_font(-1);
draw_set_color(palette.prompt_color);

var advance_text = "Continue: Click / E / Enter / Space";
if (array_length(pages) > 1)
{
    advance_text += "    " + string(page_index + 1) + "/" + string(array_length(pages));
}

draw_text(layout.text_right, layout.prompt_y, advance_text);

draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(c_white);
draw_set_font(-1);
