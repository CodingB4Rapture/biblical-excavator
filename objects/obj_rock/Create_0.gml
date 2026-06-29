/// obj_rock - Create Event

// 0 = waiting
// 1 = playing crush animation
// 2 = holding final frame
rock_state = 0;

// Counts down while the final frame is displayed.
hold_timer = 0;

// Begin as an unmoving rock.
image_index = 0;
image_speed = 0;