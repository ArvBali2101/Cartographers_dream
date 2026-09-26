# MAP

MAP is a complete Godot 4 top-down psychological / eldritch horror speedrunning game prototype.

Run `Main.tscn` in Godot 4. The project folder includes Godot 4.7 stable under `Godot_v4.7-stable/`.

For one-click launching, double-click `RUN_MAP.bat`. To open the editor, double-click `OPEN_MAP_EDITOR.bat`.

Controls:

- `WASD` or arrow keys: move
- `Shift`: sprint
- `E`, `Space`, or `Enter`: advance cutscenes, interact, and close dialogue
- `R`: restart the current level
- `F2`: show/hide the speedrun timer
- `Escape`: return to the title screen

The game follows the full structure: opening cutscene, jungle investigation, connected cutscene, sea escape, connected cutscene, nightmare maze, ending, and post-ending sting. The three levels are drawn and simulated in code, with movement, collision, objectives, dialogue, hazards, pursuit, failure states, and level transitions.
