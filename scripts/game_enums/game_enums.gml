/// Shared game state names.

enum SkidsteerState
{
    DRIVING,
    EMPTY,
    CONTACT_BLOCKED,
    CRUSHING
}

enum PlayerState
{
    WALKING,
    ENTERING_VEHICLE
}

enum NotificationStyle
{
    MEMORY,
    XP,
    PROMPT
}

enum FieldrockState
{
    WAITING,
    STRUGGLING,
    BREAKING
}

enum TreeState
{
    STANDING,
    CHOPPING,
    FALLING,
    FELLED
}

enum TutorialStage
{
    // Values 0-10 stay stable so existing save files remain compatible.
    TALK_TO_FARMER = 0,
    TALK_TO_FARMERS_WIFE = 1,
    TRIP_ONE_HAND_FIELDSTONE = 2,
    TRIP_TWO_VEHICLE_FIELDSTONE = 3,
    WINCH_PACKAGE_READY = 4,
    HAUL_FIRST_LOG = 5,
    COMPLETE = 6,
    WINCH_INSTALL_REQUIRED = 7,
    INSPECT_FIRST_LOG = 8,
    TAKE_WINCH_CABLE = 9,
    ATTACH_CABLE_TO_LOG = 10,
    // New tutorial beats append values so legacy saves keep their meaning.
    CHOP_TREE = 11,
    INSPECT_FALLEN_TREE = 12,
    PULL_STUMP = 13
}

enum QuestId
{
    FIRM_FOUNDATION = 0,
    // Append-only: version-one saves persist quest arrays by numeric ID.
    PLACE_OF_YOUR_OWN = 1,
    COUNT = 2
}

enum QuestStatus
{
    LOCKED,
    ACTIVE,
    COMPLETE
}

enum TaskId
{
    // Append future tasks so saved array indices remain stable.
    FIELDSTONE_BY_HAND = 0,
    FALLEN_TREE = 1,
    STONE_HAUL = 2,
    FIT_THE_WINCH = 3,
    TIMBER_DELIVERY = 4,
    PLACE_CABIN = 5,
    PARK_SKIDSTEER = 6,
    MARK_CABIN_SITE = 7,
    // Appended in format v4: the selected site is fenced piece by piece
    // before the short cabin-raising interaction becomes available.
    BUILD_CABIN_FENCE = 8,
    COUNT
}

enum TaskStatus
{
    LOCKED = 0,
    AVAILABLE = 1,
    ACTIVE = 2,
    COMPLETE = 3,
    CLAIMED = 4
}

enum TaskRewardType
{
    EQUIPMENT_XP = 0,
    HOME_RESOURCE = 1
}

/// Stable string IDs are persisted when a dialogue is saved mid-conversation.
/// Keep the legacy aliases in dialogue_action_normalize when these evolve.
#macro DIALOGUE_ACTION_FINISH_FARMER_INTRO "tutorial.finish_farmer_intro.v1"
#macro DIALOGUE_ACTION_POST_FIRST_TASK "tutorial.post_first_task.v1"
#macro DIALOGUE_ACTION_UNLOCK_CABIN "tutorial.unlock_cabin.v1"
#macro DIALOGUE_ACTION_BEGIN_CABIN "tutorial.begin_cabin.v1"
#macro DIALOGUE_ACTION_MOVE_CABIN "tutorial.move_cabin.v1"

enum CameraMode
{
    FOLLOW_GAMEPLAY,
    CUTSCENE
}

enum ResourceId
{
    // Keep existing numeric IDs stable for format-version-one saves.
    FIELDSTONE = 0,
    TIMBER_LOG = 1,
    FIELDROCK = 2,
    SMALL_LUMBER = 3,
    // Append-only: inventory arrays are persisted by numeric resource ID.
    TIMBER_PLANK = 4,
    FENCE_STRAIGHT = 5,
    FENCE_CORNER = 6,
    FENCE_GATE = 7,
    EMPTY_BUCKET = 8,
    COUNT
}

enum ResourceCategory
{
    STONE,
    LUMBER,
    CRAFTED
}

enum ResourceSize
{
    SMALL,
    LARGE
}

enum AttachmentState
{
    LOCKED,
    MAIL_READY,
    STORED_AT_HOME,
    INSTALLED
}

enum WinchState
{
    UNAVAILABLE,
    STOWED,
    CABLE_IN_HAND,
    ATTACHED
}

enum PullableState
{
    FREE,
    ATTACHED,
    DELIVERED
}

enum HomesteadStage
{
    TUTORIAL,
    FIRST_REST_REQUIRED,
    HUB_OPEN
}

enum FenceNeighbor
{
    NORTH = 1,
    EAST = 2,
    SOUTH = 4,
    WEST = 8
}

enum FenceGatePart
{
    NONE = 0,
    LEFT = 1,
    RIGHT = 2
}

enum FencePieceType
{
    LEGACY = 0,
    STRAIGHT = 1,
    CORNER = 2,
    GATE = 3
}

enum FenceRotation
{
    FRONT = 0,
    RIGHT = 1,
    BACK = 2,
    LEFT = 3
}

enum ProductionMachineType
{
    SAWMILL = 0,
    LATHE = 1
}

enum ProductionRecipeId
{
    SAW_TIMBER_PLANKS = 0,
    CUT_STRAIGHT_FENCE = 1,
    CUT_FENCE_CORNERS = 2,
    CUT_FENCE_GATE = 3,
    TURN_EMPTY_BUCKET = 4,
    COUNT
}

enum ProductionOutputDestination
{
    HOME = 0,
    FINISHED_CRAFTS = 1
}

#macro FENCE_PURPOSE_CABIN_SITE "cabin_site"
#macro FENCE_PURPOSE_FREE_BUILD "free_build"

#macro PRODUCTION_MACHINE_SAWMILL "room1.sawmill"
#macro PRODUCTION_MACHINE_LATHE "room1.lathe"

#macro PLAYER_FIELDSTONE_CAPACITY 6
#macro PLAYER_TIMBER_PLANK_CAPACITY 8
#macro PLAYER_FENCE_STRAIGHT_CAPACITY 20
#macro PLAYER_FENCE_CORNER_CAPACITY 8
#macro PLAYER_FENCE_GATE_CAPACITY 4
#macro PLAYER_BUCKET_CAPACITY 4
#macro VEHICLE_FIELDSTONE_CAPACITY 10

