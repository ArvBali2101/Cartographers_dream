# MAP — current final state

MAP is a Godot 4, 2D top-down psychological / eldritch horror speedrunning game prototype with a complete playable beginning-to-end flow.

## Playable structure

Menu → opening cutscene → Jungle investigation → connected cutscene → Sea escape → connected cutscene → Nightmare maze → ending → post-ending sting.

## Final implementation

- Jungle investigation with collision walls, two required expedition records, an optional fourth record, a moving black figure, objective routing, and a survey exit.
- Sea escape with ship movement, islands, wreckage, lighthouse interaction, hazards, tentacles, and a rising whisper-pressure meter.
- Nightmare maze with collision walls, figure checkpoints, delayed Witness pursuit, a final exit, and `SEEN` restart feedback.
- Connected cutscenes with different jungle, sea-transition, and eldritch-reveal compositions.
- Dialogue locks movement and closes with click, E, Space, or Enter.
- R restarts the current level. F2 toggles the speedrun timer. Escape returns to the menu.
- Ending and post-ending sting are fully playable states, not static screenshots.

## Technical state

- `project.godot` — Godot project settings.
- `Main.tscn` — single entry scene.
- `main.gd` — state machine, procedural level art, movement, collision, interaction, dialogue, hazards, pursuit, cutscenes, ending, and UI.
- `RUN_MAP.bat` — one-click game launcher.
- `OPEN_MAP_EDITOR.bat` — one-click editor launcher.
- Godot 4.7 headless editor scan and headless runtime launch both pass after the final rebuild.

The previous image-led implementation was discarded. The game now uses code-authored playable spaces rather than relying on a single merged background image.
