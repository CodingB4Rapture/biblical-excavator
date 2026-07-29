/// Transient Farmer movement between authored story beats and his daily route.
/// Durable progression never depends on his exact in-room position.

#macro FARMER_ROUTE_IDLE "idle"
#macro FARMER_ROUTE_STORY_HOME "story_home"
#macro FARMER_ROUTE_POND_OUTBOUND "pond_outbound"
#macro FARMER_ROUTE_POND_RETURN "pond_return"
#macro FARMER_POND_DEPARTURE_MINUTE 900
#macro FARMER_POND_LAST_DEPARTURE_MINUTE CALENDAR_NIGHT_MINUTE
#macro FARMER_WALK_SPEED 0.65

function farmer_schedule_point(_x, _y)
{
    return {x: _x, y: _y};
}

function farmer_schedule_should_begin_pond_trip(
    _time_of_day,
    _day_number,
    _last_trip_day
)
{
    return _last_trip_day != _day_number
        && _time_of_day >= FARMER_POND_DEPARTURE_MINUTE
        && _time_of_day < FARMER_POND_LAST_DEPARTURE_MINUTE;
}

function farmer_schedule_start_route(_farmer, _mode, _points)
{
    if (!instance_exists(_farmer) || !is_array(_points))
        return false;

    _farmer.farmer_route_mode = _mode;
    _farmer.farmer_route_points = _points;
    _farmer.farmer_route_index = 0;
    return true;
}

function farmer_schedule_pond_route(_farmer)
{
    var pond = instance_find(obj_pond, 0);
    if (!instance_exists(_farmer) || !instance_exists(pond))
        return [];

    // The eastern lane keeps him clear of either cabin site and approaches
    // the authored pond beside its collision bounds instead of through it.
    return [
        farmer_schedule_point(960, _farmer.farmer_home_y),
        farmer_schedule_point(960, 384),
        farmer_schedule_point(320, 384),
        farmer_schedule_point(320, pond.y),
        farmer_schedule_point(pond.x + 80, pond.y)
    ];
}

function farmer_schedule_pond_return_route(_farmer)
{
    var pond = instance_find(obj_pond, 0);
    if (!instance_exists(_farmer) || !instance_exists(pond))
        return [];

    return [
        farmer_schedule_point(320, pond.y),
        farmer_schedule_point(320, 384),
        farmer_schedule_point(960, 384),
        farmer_schedule_point(960, _farmer.farmer_home_y),
        farmer_schedule_point(
            _farmer.farmer_home_x,
            _farmer.farmer_home_y
        )
    ];
}

function farmer_schedule_story_return_route(_farmer)
{
    if (!instance_exists(_farmer)) return [];

    var route = [];
    var cabin = instance_find(obj_cabin_site, 0);

    // When the cabin visit ends, clear its southern edge before turning east.
    // This prevents the return leg from cutting diagonally across the cabin.
    if (instance_exists(cabin)
    && point_distance(_farmer.x, _farmer.y, cabin.x, cabin.y) < 240)
    {
        var south_y = clamp(cabin.y + 80, 16, room_height - 16);
        var east_x = clamp(cabin.x + 96, 16, room_width - 16);
        array_push(
            route,
            farmer_schedule_point(_farmer.x, south_y)
        );
        array_push(
            route,
            farmer_schedule_point(east_x, south_y)
        );
    }

    if (_farmer.y > 400)
    {
        array_push(route, farmer_schedule_point(960, 384));
    }
    array_push(
        route,
        farmer_schedule_point(960, _farmer.farmer_home_y)
    );
    array_push(
        route,
        farmer_schedule_point(
            _farmer.farmer_home_x,
            _farmer.farmer_home_y
        )
    );
    return route;
}

function farmer_schedule_request_story_return(_farmer)
{
    if (!instance_exists(_farmer)) return false;
    _farmer.farmer_story_return_pending = true;
    return true;
}

function farmer_schedule_move_step(_farmer)
{
    if (!instance_exists(_farmer)
    || _farmer.farmer_route_index
        >= array_length(_farmer.farmer_route_points))
    {
        return true;
    }

    var target =
        _farmer.farmer_route_points[_farmer.farmer_route_index];
    var distance = point_distance(
        _farmer.x,
        _farmer.y,
        target.x,
        target.y
    );
    if (distance <= 2)
    {
        _farmer.x = target.x;
        _farmer.y = target.y;
        _farmer.farmer_route_index += 1;
        return _farmer.farmer_route_index
            >= array_length(_farmer.farmer_route_points);
    }

    var move_direction = point_direction(
        _farmer.x,
        _farmer.y,
        target.x,
        target.y
    );
    var amount = min(FARMER_WALK_SPEED, distance);
    _farmer.x += lengthdir_x(amount, move_direction);
    _farmer.y += lengthdir_y(amount, move_direction);
    _farmer.image_speed = 0.14;
    return false;
}

function farmer_schedule_finish_route(_farmer)
{
    var finished_mode = _farmer.farmer_route_mode;
    _farmer.image_speed = 0;
    _farmer.image_index = 0;

    if (finished_mode == FARMER_ROUTE_POND_OUTBOUND)
    {
        return farmer_schedule_start_route(
            _farmer,
            FARMER_ROUTE_POND_RETURN,
            farmer_schedule_pond_return_route(_farmer)
        );
    }

    _farmer.farmer_route_mode = FARMER_ROUTE_IDLE;
    _farmer.farmer_route_points = [];
    _farmer.farmer_route_index = 0;
    return true;
}

function farmer_schedule_update(_farmer)
{
    if (!instance_exists(_farmer)) return false;

    if (gameplay_is_paused()
    || cutscene_is_active()
    || dialogue_is_active())
    {
        _farmer.image_speed = 0;
        return false;
    }

    if (_farmer.farmer_story_return_pending)
    {
        _farmer.farmer_story_return_pending = false;
        farmer_schedule_start_route(
            _farmer,
            FARMER_ROUTE_STORY_HOME,
            farmer_schedule_story_return_route(_farmer)
        );
    }

    var game_state = game_state_ensure();
    if (calendar_should_run())
    {
        if (_farmer.farmer_schedule_day != game_state.day_number)
        {
            _farmer.farmer_schedule_day = game_state.day_number;
            _farmer.farmer_pond_trip_day = -1;
            farmer_schedule_start_route(
                _farmer,
                FARMER_ROUTE_STORY_HOME,
                farmer_schedule_story_return_route(_farmer)
            );
        }

        if (_farmer.farmer_route_mode == FARMER_ROUTE_IDLE
        && farmer_schedule_should_begin_pond_trip(
            game_state.time_of_day,
            game_state.day_number,
            _farmer.farmer_pond_trip_day
        ))
        {
            var pond_route = farmer_schedule_pond_route(_farmer);
            if (array_length(pond_route) > 0)
            {
                _farmer.farmer_pond_trip_day = game_state.day_number;
                farmer_schedule_start_route(
                    _farmer,
                    FARMER_ROUTE_POND_OUTBOUND,
                    pond_route
                );
            }
        }
    }

    if (_farmer.farmer_route_mode == FARMER_ROUTE_IDLE)
    {
        _farmer.image_speed = 0;
        _farmer.image_index = 0;
        return true;
    }

    if (farmer_schedule_move_step(_farmer))
        farmer_schedule_finish_route(_farmer);
    return true;
}
