# MAP project journal

## 2026-09-26 — Reset and final direction

- The previous DreamScape web prototype was intentionally cleared from the project folder at the user’s request.
- No `MASTER_NOTES*.pdf` was present when the new project was started.
- The final direction is `MAP`: a Godot 4, 2D top-down psychological/eldritch horror speedrunning game.
- The intended sequence is Menu → Jungle → Cutscene → Sea → Cutscene → Nightmare → Ending → post-ending sting.
- The first implementation is a procedural vertical slice with no external art dependency: all map art, expedition markers, figure, ship, tentacles, UI, and cutscene panels are drawn in `main.gd`.
- Core systems implemented: movement, sprinting, hidden horror escalation, unreliable minimap, recurring black figure, expedition marker progression, sea race, nightmare chase, scene transitions, ending, sting, and optional speedrun timer.

## Current state

- The project is source-complete for a playable prototype but Godot is not installed in the current environment, so runtime verification must be performed in Godot.
- Godot 4.7 stable Windows editor was downloaded and extracted directly into the project folder. The editor’s headless scan initially caught one strict type inference issue in the whisper system; that was fixed and the second headless scan completed without errors.
- Full progression pass: fixed the opening cutscene-to-jungle transition, added E-based expedition marker interactions, made the survey gate require the first two records, added the changed fourth-marker note, added death notices for `DROWNED` and `SEEN`, and verified the project again with Godot 4.7 headless mode.
