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
    FIRM_FOUNDATION,
    COUNT
}

enum QuestStatus
{
    LOCKED,
    ACTIVE,
    COMPLETE
}

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
    COUNT
}

enum ResourceCategory
{
    STONE,
    LUMBER
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

