/// Stable task definitions, story ordering, work-section presentation, and
/// reward descriptors.

#macro WORK_SECTION_KNOW_LAND 0
#macro WORK_SECTION_FOUNDATION 1
#macro WORK_SECTION_HOME 2
#macro WORK_SECTION_COUNT 3

function task_get_work_section_definition(_section_id)
{
    switch (_section_id)
    {
        case WORK_SECTION_KNOW_LAND:
            return {
                id: _section_id,
                number: "I",
                title: "Know the Land",
                short_purpose: "Learn what the land can provide",
                purpose: "Before building, learn what this ground can provide safely: loose foundation stone, usable timber, and the limits of what can be carried by hand."
            };

        case WORK_SECTION_FOUNDATION:
            return {
                id: _section_id,
                number: "II",
                title: "Lay the Foundation",
                short_purpose: "Recover the heavy materials",
                purpose: "A lasting cabin needs more than loose material. Gather the heavy stone and timber that make a sound foundation possible."
            };

        case WORK_SECTION_HOME:
            return {
                id: _section_id,
                number: "III",
                title: "Make a Home",
                short_purpose: "Choose a site and build",
                purpose: "The gathered supplies now have a purpose: choose where to settle, establish a safe boundary, and raise the first cabin."
            };
    }

    return {
        id: -1,
        number: "",
        title: "Homestead Work",
        short_purpose: "",
        purpose: "Each piece of work helps restore the homestead."
    };
}

function task_get_work_section_id(_task_id)
{
    switch (_task_id)
    {
        case TaskId.FIELDSTONE_BY_HAND:
        case TaskId.FALLEN_TREE:
            return WORK_SECTION_KNOW_LAND;

        case TaskId.STONE_HAUL:
        case TaskId.FIT_THE_WINCH:
        case TaskId.TIMBER_DELIVERY:
            return WORK_SECTION_FOUNDATION;

        case TaskId.PARK_SKIDSTEER:
        case TaskId.MARK_CABIN_SITE:
        case TaskId.BUILD_CABIN_FENCE:
        case TaskId.PLACE_CABIN:
            return WORK_SECTION_HOME;
    }

    return -1;
}

function task_get_work_section_tasks(_section_id)
{
    var tasks = [];
    var order = task_get_story_order();

    for (var order_index = 0;
        order_index < array_length(order);
        order_index++)
    {
        var task_id = order[order_index];
        if (task_get_work_section_id(task_id) == _section_id)
            array_push(tasks, task_id);
    }

    return tasks;
}

function task_get_work_sections_for_quest(_quest_id)
{
    var sections = [];

    for (var section_id = 0;
        section_id < WORK_SECTION_COUNT;
        section_id++)
    {
        var tasks = task_get_work_section_tasks(section_id);
        for (var task_index = 0;
            task_index < array_length(tasks);
            task_index++)
        {
            if (task_get_definition(tasks[task_index]).quest_id
                == _quest_id)
            {
                array_push(sections, section_id);
                break;
            }
        }
    }

    return sections;
}

function task_work_section_is_first_task(_task_id)
{
    var tasks = task_get_work_section_tasks(
        task_get_work_section_id(_task_id)
    );
    return array_length(tasks) > 0 && tasks[0] == _task_id;
}

function task_work_section_is_last_task(_task_id)
{
    var tasks = task_get_work_section_tasks(
        task_get_work_section_id(_task_id)
    );
    return array_length(tasks) > 0
        && tasks[array_length(tasks) - 1] == _task_id;
}

function task_get_board_rows()
{
    var rows = [];

    for (var section_id = 0;
        section_id < WORK_SECTION_COUNT;
        section_id++)
    {
        array_push(rows, {
            kind: "section",
            section_id: section_id,
            task_id: -1
        });

        var tasks = task_get_work_section_tasks(section_id);
        for (var task_index = 0;
            task_index < array_length(tasks);
            task_index++)
        {
            array_push(rows, {
                kind: "task",
                section_id: section_id,
                task_id: tasks[task_index]
            });
        }
    }

    return rows;
}

function task_board_row_index_of_task(_task_id, _rows = undefined)
{
    var rows = is_undefined(_rows) ? task_get_board_rows() : _rows;

    for (var row_index = 0;
        row_index < array_length(rows);
        row_index++)
    {
        if (rows[row_index].kind == "task"
        && rows[row_index].task_id == _task_id)
        {
            return row_index;
        }
    }

    return 1;
}

function task_get_current_work_section(_game_state = undefined)
{
    var game_state = is_undefined(_game_state)
        ? game_state_read()
        : _game_state;
    var task_id = task_get_active_id(game_state);
    if (task_id < 0) task_id = task_get_attention_id(game_state);

    if (task_id < 0)
    {
        var order = task_get_story_order();
        for (var order_index = array_length(order) - 1;
            order_index >= 0;
            order_index--)
        {
            if (task_get_status(order[order_index], game_state)
                == TaskStatus.CLAIMED)
            {
                task_id = order[order_index];
                break;
            }
        }
    }

    return task_get_work_section_definition(
        task_get_work_section_id(task_id)
    );
}

function task_get_definition(_task_id)
{
    switch (_task_id)
    {
        case TaskId.FIELDSTONE_BY_HAND:
            return {
                quest_id: QuestId.FIRM_FOUNDATION,
                title: "Fieldstone by Hand",
                summary: "Explore the nearby ground and gather six loose Fieldstones by hand. Their size and location reveal what the land can offer without machinery.",
                completion_summary: "Six loose Fieldstones were gathered and the axe became available.",
                reward_labels: ["Axe"],
                rewards: []
            };

        case TaskId.FALLEN_TREE:
            return {
                quest_id: QuestId.FIRM_FOUNDATION,
                title: "A Fallen Tree",
                summary: "Choose a standing tree, fell it safely, and inspect what remains. Both the trunk and stump can become useful once heavier recovery is possible.",
                completion_summary: "The tree was felled and its heavy trunk and stump were inspected.",
                reward_labels: ["Access to Skidsteer"],
                rewards: []
            };

        case TaskId.STONE_HAUL:
            return {
                quest_id: QuestId.FIRM_FOUNDATION,
                title: "Stone Haul",
                summary: "Use the skidsteer to recover the heavier stone needed for a stable cabin foundation, then bring the full supply home.",
                completion_summary: "All sixteen foundation stones reached Home Delivery.",
                reward_labels: ["Winch attachment delivery"],
                rewards: []
            };

        case TaskId.FIT_THE_WINCH:
            return {
                quest_id: QuestId.FIRM_FOUNDATION,
                title: "Fit the Winch",
                summary: "Install the mailed winch attachment so the skidsteer can recover materials that cannot be lifted or carried.",
                completion_summary: "The skidsteer was fitted with a working winch.",
                reward_labels: ["Access to Skidsteer"],
                rewards: []
            };

        case TaskId.TIMBER_DELIVERY:
            return {
                quest_id: QuestId.FIRM_FOUNDATION,
                title: "Timber Delivery",
                summary: "Return to the felled tree and use the winch to recover both pieces. The trunk provides timber; the stump provides smaller lumber.",
                completion_summary: "The log and stump were recovered as Timber Log and Small Lumber.",
                reward_labels: ["Cabin Site Plan"],
                rewards: []
            };

        case TaskId.PLACE_CABIN:
            return {
                quest_id: QuestId.PLACE_OF_YOUR_OWN,
                title: "Build the Cabin",
                summary: "Raise the cabin inside the completed boundary and give the gathered work a visible purpose.",
                completion_summary: "The cabin was raised inside the completed boundary.",
                reward_labels: ["Homestead Cabin", "First Morning Unlocked"],
                rewards: []
            };

        case TaskId.PARK_SKIDSTEER:
            return {
                quest_id: QuestId.PLACE_OF_YOUR_OWN,
                title: "Park the Skidsteer",
                summary: "Settle the heavy equipment before surveying a permanent home site. Return it safely to the pad beside the Farmer.",
                completion_summary: "The skidsteer was returned safely to its place beside the Farmer.",
                reward_labels: ["Cabin Site Survey"],
                rewards: []
            };

        case TaskId.MARK_CABIN_SITE:
            return {
                quest_id: QuestId.PLACE_OF_YOUR_OWN,
                title: "Mark the Cabin Site",
                summary: "Explore the two surveyed locations and choose where this homestead should take root. Taking a flag commits the site.",
                completion_summary: "A cabin site was selected and marked for construction.",
                reward_labels: ["Cabin Construction"],
                rewards: []
            };

        case TaskId.BUILD_CABIN_FENCE:
            return {
                quest_id: QuestId.PLACE_OF_YOUR_OWN,
                title: "Build the Cabin Boundary",
                summary: "Turn the recovered timber into a complete boundary. The fence defines a safe yard and prepares the selected site for building.",
                completion_summary: "The selected cabin site now has its complete boundary and front gate.",
                reward_labels: [
                    "Cabin Construction",
                    "50 Woodwork XP"
                ],
                rewards: [
                    task_reward_skill_xp(
                        SkillId.WOODWORK,
                        50,
                        "50 Woodwork XP"
                    )
                ]
            };
    }

    return {
        quest_id: QuestId.FIRM_FOUNDATION,
        title: "Unknown Task",
        summary: "No task details are available.",
        completion_summary: "No completion details are available.",
        reward_labels: [],
        rewards: []
    };
}

function task_get_story_order()
{
    // Persisted TaskId values are append-only, so presentation order is an
    // explicit read model rather than numeric enum order.
    return [
        TaskId.FIELDSTONE_BY_HAND,
        TaskId.FALLEN_TREE,
        TaskId.STONE_HAUL,
        TaskId.FIT_THE_WINCH,
        TaskId.TIMBER_DELIVERY,
        TaskId.PARK_SKIDSTEER,
        TaskId.MARK_CABIN_SITE,
        TaskId.BUILD_CABIN_FENCE,
        TaskId.PLACE_CABIN
    ];
}

function task_order_index_of(_task_id, _order = undefined)
{
    var order = is_undefined(_order) ? task_get_story_order() : _order;

    for (var index = 0; index < array_length(order); index++)
    {
        if (order[index] == _task_id) return index;
    }

    return -1;
}

function task_get_ids_for_quest(_quest_id)
{
    var result = [];
    var order = task_get_story_order();

    for (var order_index = 0;
        order_index < array_length(order);
        order_index++)
    {
        var task_id = order[order_index];
        if (task_get_definition(task_id).quest_id == _quest_id)
            array_push(result, task_id);
    }

    return result;
}

function task_reward_equipment_xp(_amount, _label)
{
    return {
        type: TaskRewardType.EQUIPMENT_XP,
        amount: max(0, floor(_amount)),
        label: _label
    };
}

function task_reward_home_resource(_resource_id, _amount, _label)
{
    return {
        type: TaskRewardType.HOME_RESOURCE,
        resource_id: _resource_id,
        amount: max(0, floor(_amount)),
        label: _label
    };
}

function task_reward_skill_xp(
    _skill_id,
    _amount,
    _label
)
{
    return {
        type: TaskRewardType.SKILL_XP,
        skill_id: _skill_id,
        amount: max(0, floor(_amount)),
        label: _label
    };
}
