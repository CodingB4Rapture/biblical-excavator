/// obj_skills_menu - Draw GUI Event

var layout = player_menu_get_skills_layout();
var game_state = game_state_read();
var row_height = min(
    72,
    (layout.content_bottom - layout.content_top)
        / max(1, SkillId.COUNT)
);

draw_set_font(-1);
draw_set_alpha(0.72);
draw_set_color(make_color_rgb(14, 13, 11));
draw_rectangle(0, 0, layout.gui_w, layout.gui_h, false);

draw_set_alpha(0.98);
draw_set_color(make_color_rgb(70, 50, 27));
draw_roundrect(
    layout.panel_left,
    layout.panel_top,
    layout.panel_right,
    layout.panel_bottom,
    false
);
draw_set_color(make_color_rgb(213, 164, 67));
draw_roundrect(
    layout.panel_left + 2,
    layout.panel_top + 2,
    layout.panel_right - 2,
    layout.panel_bottom - 2,
    true
);
draw_set_color(make_color_rgb(31, 28, 23));
draw_roundrect(
    layout.panel_left + 5,
    layout.panel_top + 5,
    layout.panel_right - 5,
    layout.panel_bottom - 5,
    false
);

draw_set_alpha(1);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(make_color_rgb(255, 220, 92));
draw_text(
    layout.panel_left + 14,
    layout.panel_top + 12,
    "SKILLS"
);

for (var skill_id = 0; skill_id < SkillId.COUNT; skill_id++)
{
    var model = skill_get_read_model(skill_id, game_state);
    var row_top = layout.content_top + skill_id * row_height;
    var selected = skill_id == selected_skill;
    draw_set_color(selected
        ? make_color_rgb(76, 66, 49)
        : make_color_rgb(50, 45, 37));
    draw_roundrect(
        layout.list_left,
        row_top,
        layout.list_right,
        row_top + row_height - 6,
        false
    );
    draw_set_color(selected
        ? make_color_rgb(255, 220, 92)
        : make_color_rgb(238, 225, 195));
    draw_text(layout.list_left + 12, row_top + 9, model.name);
    draw_set_color(make_color_rgb(178, 166, 139));
    draw_text(
        layout.list_left + 12,
        row_top + 30,
        "Level " + string(model.level)
            + "    XP " + string(model.xp)
    );
    draw_set_color(make_color_rgb(40, 36, 30));
    draw_rectangle(
        layout.list_left + 12,
        row_top + 52,
        layout.list_right - 12,
        row_top + 59,
        false
    );
    draw_set_color(make_color_rgb(212, 164, 67));
    draw_rectangle(
        layout.list_left + 12,
        row_top + 52,
        lerp(
            layout.list_left + 12,
            layout.list_right - 12,
            model.progress
        ),
        row_top + 59,
        false
    );
}

var selected_model = skill_get_read_model(
    selected_skill,
    game_state
);
draw_set_color(make_color_rgb(255, 220, 92));
draw_text(
    layout.detail_left,
    layout.content_top,
    selected_model.name
);
draw_set_color(make_color_rgb(238, 225, 195));
draw_text(
    layout.detail_left,
    layout.content_top + 30,
    "Level " + string(selected_model.level)
);
draw_set_color(make_color_rgb(178, 166, 139));
draw_text_ext(
    layout.detail_left,
    layout.content_top + 62,
    selected_model.description,
    18,
    max(1, layout.detail_right - layout.detail_left)
);
draw_text(
    layout.detail_left,
    layout.content_top + 118,
    "Total XP: " + string(selected_model.xp)
);
if (selected_model.level < selected_model.max_level)
{
    draw_text(
        layout.detail_left,
        layout.content_top + 140,
        "Next level: "
            + string(selected_model.next_level_xp)
            + " XP"
    );
}
else
{
    draw_text(
        layout.detail_left,
        layout.content_top + 140,
        "Maximum level reached"
    );
}

if (!is_undefined(selected_model.next_unlock))
{
    draw_set_color(make_color_rgb(255, 220, 92));
    draw_text(
        layout.detail_left,
        layout.content_top + 180,
        "NEXT UNLOCK - LEVEL "
            + string(selected_model.next_unlock.level)
    );
    draw_set_color(make_color_rgb(238, 225, 195));
    draw_text(
        layout.detail_left,
        layout.content_top + 208,
        selected_model.next_unlock.title
    );
    draw_set_color(make_color_rgb(178, 166, 139));
    draw_text_ext(
        layout.detail_left,
        layout.content_top + 236,
        selected_model.next_unlock.description,
        18,
        max(1, layout.detail_right - layout.detail_left)
    );
}

draw_set_halign(fa_center);
draw_set_valign(fa_bottom);
draw_set_color(make_color_rgb(232, 209, 158));
draw_text(
    (layout.panel_left + layout.panel_right) * 0.5,
    layout.panel_bottom - 8,
    "Click a skill or use Up/Down    Shift+S or Escape to close"
);

draw_set_alpha(1);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(c_white);
draw_set_font(-1);
