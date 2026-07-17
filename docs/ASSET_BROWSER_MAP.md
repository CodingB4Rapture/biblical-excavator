# Asset Browser Map

Use the folder that answers, "What part of the game is this for?" rather than
only, "What type of GameMaker resource is this?"

```text
Game Systems
  Controllers                 Persistent setup and world controllers
  Shared Definitions          Enums and reusable parent objects
  Inventory and Progression   Resources, storage, rewards, and Homebase progress

Characters
  Player                      Player object and on-foot interaction helpers
  Homestead NPCs              Wife and future older-couple characters

Vehicle and Equipment
  Work Vehicle                Vehicle object, sprites, and driving helpers
  Attachments and Winch       Winch, future attachments, and their helpers

World
  Rooms                       Playable rooms
  Homestead                   Delivery zones and future buildings or stations
  Resources                   Rocks, logs, and their art
  Environment Art             Ground, trees, terrain, fences, and map dressing

Interface and Feedback
  HUD and Dialogue            HUD, hints, dialogue bubbles, and their scripts
  Effects                     Smoke, XP drops, contact effects, and similar feedback

Reference Art                 Older, experimental, or unused art kept for comparison
```

## Adding something new

- A new person who lives or works on the homestead: `Characters/Homestead NPCs`.
- A player-only helper: `Characters/Player`.
- A vehicle part, trailer, bucket, or winch upgrade: `Vehicle and Equipment`.
- A physical resource such as cedar logs, limestone, or artifacts:
  `World/Resources`.
- A house, barn, material yard, gate, or workbench: `World/Homestead`.
- Trees, grass, paths, cliffs, and tiles: `World/Environment Art`.
- A UI panel, notification, or dialogue presentation helper:
  `Interface and Feedback/HUD and Dialogue`.

Keep an object's scripts and primary art near the system that uses them. For
example, a new vehicle object, its driving script, and its main sprite belong
under `Work Vehicle`, not in three unrelated top-level folders.
