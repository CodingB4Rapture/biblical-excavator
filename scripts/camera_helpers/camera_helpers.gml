/// Camera helpers. Dialogue, tutorials, and scripted scenes should use these
/// instead of changing view_object directly.

function camera_get_controller()
{
    return instance_find(obj_camera_controller, 0);
}

function camera_follow_gameplay()
{
    var controller = camera_get_controller();

    if (!instance_exists(controller)) return;

    controller.camera_mode = CameraMode.FOLLOW_GAMEPLAY;
    controller.camera_focus_instance = noone;
    controller.camera_target_zoom = 1;
    controller.camera_cutscene_timer = 0;
}

function camera_focus_on(_target, _zoom = 1.35, _duration = 0)
{
    var controller = camera_get_controller();

    if (!instance_exists(controller) || !instance_exists(_target)) return;

    controller.camera_mode = CameraMode.CUTSCENE;
    controller.camera_focus_instance = _target;
    controller.camera_focus_x = _target.x;
    controller.camera_focus_y = _target.y;
    controller.camera_target_zoom = max(1, _zoom);
    controller.camera_cutscene_timer = _duration;
}

function camera_focus_between(_first, _second, _zoom = 1.2, _duration = 0)
{
    var controller = camera_get_controller();

    if (!instance_exists(controller)
    || !instance_exists(_first)
    || !instance_exists(_second)) return;

    controller.camera_mode = CameraMode.CUTSCENE;
    controller.camera_focus_instance = noone;
    controller.camera_focus_x = (_first.x + _second.x) * 0.5;
    controller.camera_focus_y = (_first.y + _second.y) * 0.5;
    controller.camera_target_zoom = max(1, _zoom);
    controller.camera_cutscene_timer = _duration;
}
