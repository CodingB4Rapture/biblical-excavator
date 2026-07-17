# Tutorial and Dialogue

## Current first-play order

1. The farmhand starts on foot beside the parked work vehicle.
2. A two-page message from the Homestead Owner explains the role and says to approach the vehicle.
3. The player clicks or presses `E` through the message. Enter and Space work too. The player and skidsteer do not move while dialogue is open.
4. The vehicle prompt appears when the player is close enough: press `E` to enter.

## Conversation UI

`notification_show_dialogue` accepts either one string or an array of pages. It uses one bottom-screen panel, queues new pages if a conversation is already open, and draws an intentionally temporary face card. Replace only the face-card drawing in `obj_dialogue_bubble / Draw GUI` when you make portrait art.

Use a named speaker when the dialogue is not tied to an existing character instance:

```gml
notification_show_dialogue(["First page.", "Second page."], noone, 0, NotificationStyle.PROMPT, "HOMESTEAD OWNER");
```
