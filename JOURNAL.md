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
- Visual overhaul: generated and integrated three illustrated top-down level backgrounds for Jungle, Sea, and Nightmare. Reworked the title screen, chapter HUD, cutscene panels, and overlays so the game reads as a coherent illustrated horror experience instead of debug geometry.
- Runtime fix from playtest: the menu was drawing the settings list even while settings were closed, and cutscenes could appear frozen when the game window did not own keyboard focus. Moved input handling to `_input`, added mouse-click advancement, visible click/E/Space instructions, and an eight-second fallback auto-advance.
- Gameplay depth pass: added real marker dialogue, a gated survey objective, changed Expedition IV text, lighthouse interaction, sea island/wreck interactions, river collision, nightmare wall collision, and a dialogue lock that pauses movement while reading.

## 2026-09-26 — Rebuilt as a real game

- Replaced the image-led implementation with a fresh single-scene Godot game implementation whose core levels are authored as navigable spaces in code.
- Jungle is now an investigation level with collision walls, two required records, an optional fourth expedition record, an objective arrow, a moving black figure, and a survey exit.
- Sea is now a distinct ship level with hazards, islands, wreckage, lighthouse interaction, tentacle escalation, and a story-consistent whisper pressure meter.
- Nightmare is now a distinct maze level with collision walls, route checkpoints for the figure, a delayed Witness pursuit, a reachable exit, and restart-on-seen failure.
- Connected cutscenes now use different illustrated compositions for jungle, transition, and eldritch reveal instead of reusing one merged background image.
- Added redundant input paths: click, E, Space, Enter, and physical-key fallback for progression; R restarts a level; dialogue renders line-by-line.
- Godot 4.7 headless editor validation and headless runtime validation completed without parse or runtime errors after the rebuild.
