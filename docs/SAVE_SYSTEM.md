# Save System

The game currently uses one versioned JSON slot named `save_slot_1.json` in
GameMaker's local save area.

Saved data includes:

- tutorial stage and delivery progress;
- backpack, vehicle cargo, and Homebase inventories;
- player/on-foot state and player position;
- the current gameplay room (with `Room1` as a safe fallback);
- skidsteer position, direction, and driver state;
- removed small stones, large rocks, and the tutorial log;
- the log's current position;
- winch unlock/install state;
- cabin-placement unlock state and the placed cabin site's room and position;
- Quest 1 status and its completed reward history;
- an unfinished Farmer or Farmer's Wife dialogue and its current page;
- fullscreen and master-volume settings.

Home Delivery and installing the winch autosave. The Escape pause menu also has
a manual Save command. A cable actively attached during a manual save is safely
restored as stowed; the log keeps its saved location.

Short-lived hints, reward popups, rock-breaking animation frames, and an active
winch cable are deliberately not saved. They safely restart or disappear while
the durable resource and quest progress remains intact.
