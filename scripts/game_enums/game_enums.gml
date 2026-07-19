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

enum RockState
{
    WAITING,
    STRUGGLING,
    BREAKING
}

enum TutorialStage
{
    // Values 0-6 stay stable so existing save files remain compatible.
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
    ATTACH_CABLE_TO_LOG = 10
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
    FIELDSTONE,
    TIMBER_LOG,
    COUNT
}

enum ResourceCategory
{
    ROCK,
    LOG
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

