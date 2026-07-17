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
    TALK_TO_FARMER,
    TALK_TO_FARMERS_WIFE,
    TRIP_ONE_HAND_FIELDSTONE,
    TRIP_TWO_VEHICLE_FIELDSTONE,
    WINCH_READY,
    HAUL_FIRST_LOG,
    COMPLETE
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

