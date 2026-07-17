# Main Menu

`rm_main_menu` is now the first room in the game. Its `obj_main_menu` reuses the background, panels, buttons, and fonts from the local `2D-Extraction-Menu` project.

- **New Game** resets the single save slot and enters `Room1`.
- **Continue** loads the existing `save_slot_1.json` snapshot.
- **Settings** controls fullscreen and master volume.
- **Quit** closes the game.

Press Escape during gameplay to open the pause menu. Escape closes it again.
The homestead remains visible but frozen beneath the same panels and buttons
used by the title screen. The pause menu provides Continue, Save, Settings, and
Main Menu. Returning to Main Menu writes the current snapshot first so Continue
can return to it.
