/// Stable quest definitions.

function quest_get_definition(_quest_id)
{
    switch (_quest_id)
    {
        case QuestId.FIRM_FOUNDATION:
        {
            return {
                title: "A Firm Foundation",
                summary: "Meet the homesteaders and gather the first stone and timber for the cabin foundation.",
                completion_summary: "You secured sixteen Fieldstones, a Timber Log, and Small Lumber; learned the skidsteer and winch; and received a cabin site plan.",
                rewards: [
                    "Cabin Site Plan",
                    "Cabin Placement Unlocked"
                ]
            };
        }

        case QuestId.PLACE_OF_YOUR_OWN:
        {
            return {
                title: "A Place of Your Own",
                summary: "Park the work vehicle, mark a bounded cabin plot with one gate, and build a place of your own.",
                completion_summary: "You parked the skidsteer, enclosed the cabin and front yard, and raised the finished cabin.",
                rewards: [
                    "Homestead Site Established",
                    "First Morning Unlocked"
                ]
            };
        }
    }

    return {
        title: "Unknown Quest",
        summary: "No quest details are available.",
        completion_summary: "No completion details are available.",
        rewards: []
    };
}
