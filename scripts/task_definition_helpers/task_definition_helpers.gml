/// Stable task definitions, story ordering, and reward descriptors.

function task_get_definition(_task_id)
{
    switch (_task_id)
    {
        case TaskId.FIELDSTONE_BY_HAND:
            return {
                quest_id: QuestId.FIRM_FOUNDATION,
                title: "Fieldstone by Hand",
                summary: "Gather the first six loose Fieldstones without the work vehicle.",
                completion_summary: "Six loose Fieldstones were gathered and the axe became available.",
                reward_labels: ["Axe"],
                rewards: []
            };

        case TaskId.FALLEN_TREE:
            return {
                quest_id: QuestId.FIRM_FOUNDATION,
                title: "A Fallen Tree",
                summary: "Use the axe on a standing tree, then inspect the trunk and stump.",
                completion_summary: "The tree was felled and its heavy trunk and stump were inspected.",
                reward_labels: ["Access to Skidsteer"],
                rewards: []
            };

        case TaskId.STONE_HAUL:
            return {
                quest_id: QuestId.FIRM_FOUNDATION,
                title: "Stone Haul",
                summary: "Crush ten Fieldrocks with the skidsteer and deliver all sixteen Fieldstones.",
                completion_summary: "All sixteen foundation stones reached Home Delivery.",
                reward_labels: ["Winch attachment delivery"],
                rewards: []
            };

        case TaskId.FIT_THE_WINCH:
            return {
                quest_id: QuestId.FIRM_FOUNDATION,
                title: "Fit the Winch",
                summary: "Collect the delivered attachment and install it on the skidsteer.",
                completion_summary: "The skidsteer was fitted with a working winch.",
                reward_labels: ["Access to Skidsteer"],
                rewards: []
            };

        case TaskId.TIMBER_DELIVERY:
            return {
                quest_id: QuestId.FIRM_FOUNDATION,
                title: "Timber Delivery",
                summary: "Use the winch to bring both the log and stump to Home Delivery.",
                completion_summary: "The log and stump were recovered as Timber Log and Small Lumber.",
                reward_labels: ["Cabin Site Plan"],
                rewards: []
            };

        case TaskId.PLACE_CABIN:
            return {
                quest_id: QuestId.PLACE_OF_YOUR_OWN,
                title: "Build the Cabin",
                summary: "Retrieve four finished Timber Planks, then raise the cabin on the enclosed site.",
                completion_summary: "Four finished planks became a cabin and a place of your own.",
                reward_labels: ["Homestead Cabin", "First Morning Unlocked"],
                rewards: []
            };

        case TaskId.PARK_SKIDSTEER:
            return {
                quest_id: QuestId.PLACE_OF_YOUR_OWN,
                title: "Park the Skidsteer",
                summary: "Return the skidsteer to the marked pad beside the Farmer, stop, and hop out.",
                completion_summary: "The skidsteer was returned safely to its place beside the Farmer.",
                reward_labels: ["Cabin Site Survey"],
                rewards: []
            };

        case TaskId.MARK_CABIN_SITE:
            return {
                quest_id: QuestId.PLACE_OF_YOUR_OWN,
                title: "Mark the Cabin Site",
                summary: "Choose the cabin stakes, then enclose the assigned plot with one front gate.",
                completion_summary: "A bounded cabin plot and front yard were enclosed with one gate.",
                reward_labels: ["Cabin Construction"],
                rewards: []
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
