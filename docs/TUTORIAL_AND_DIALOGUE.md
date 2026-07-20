# Tutorial and Dialogue

## Current first-play order

1. The farmhand starts on foot beside the parked work vehicle.
2. A two-page message from the Homestead Owner explains the role and says to approach the vehicle.
3. The player clicks or presses `E` through the message. Enter and Space work too. The player and skidsteer do not move while dialogue is open.
4. The vehicle prompt appears when the player is close enough: press `E` to enter.

## Conversation UI

`notification_show_dialogue` accepts either one string or an array of pages. It
uses one bottom-screen panel, queues new pages if a conversation is already
open, and draws an intentionally temporary face card.

Dialogue layout is standardized in `scripts/dialogue_helpers`:

- `dialogue_get_layout` owns panel size, margins, text bounds, and vertical
  centering.
- `dialogue_get_palette` owns shared colors and temporary speaker tinting.
- `dialogue_draw_panel` owns the frame.
- `dialogue_draw_portrait_placeholder` is the only temporary portrait drawing
  that should be replaced when character art exists.

Body dialogue uses `description_font` with deliberate line spacing. Speaker
labels use the larger UI font as a small gold nameplate. Keep pages to one or
two readable sentences; split longer monologues into more pages instead of
shrinking the text.

Advancing dialogue accepts click, `E`, Enter, or Space. When a dialogue closes,
world interaction is briefly locked so ending a conversation with `E` does not
immediately reopen the same NPC.

Use a named speaker when the dialogue is not tied to an existing character instance:

```gml
notification_show_dialogue(["First page.", "Second page."], noone, 0, NotificationStyle.PROMPT, "HOMESTEAD OWNER");
```
