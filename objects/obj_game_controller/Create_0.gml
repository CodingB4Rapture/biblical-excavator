/// obj_game_controller - Create Event
/// Durable player, household, and progression state lives outside obj_player.

if (instance_number(obj_game_controller) > 1)
{
    instance_destroy();
    exit;
}

game_state_ensure();
