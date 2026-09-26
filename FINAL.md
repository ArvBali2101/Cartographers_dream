# MAP — current final state

MAP is a Godot 4 procedural vertical slice for a 2D top-down psychological / eldritch horror speedrunning game.

## Playable structure

Menu → Opening panels → The Map (jungle) → cutscene → The Drowned Map (sea) → cutscene → The Last Map (nightmare) → ending → post-ending sting.

## Current implementation

- WASD / arrow movement, Shift sprint, E interaction, Escape to menu, F2 speedrun timer.
- Jungle expedition markers I, II, and IV; marker III is intentionally absent.
- Memory minimap diverges from the actual jungle route.
- Silent recurring figure that retreats when approached.
- Sea level with hidden horror timer, obstacles, islands, wreckage, lighthouse, tentacles, whispers, and restart-on-drown.
- Nightmare level with scripted figure checkpoints, Witness pursuit, maze-like geometry, and final exit.
- Still-panel cutscenes, ending, and the “YOU SHOULDN’T HAVE LOOKED AT A GOD.” post-ending sting.

## Technical state

- `project.godot` — Godot project settings and controls.
- `Main.tscn` — single entry scene.
- `main.gd` — procedural renderer, state machine, level logic, interactions, cutscenes, and UI.
- External art and audio can be layered in later without changing the game flow.
- Godot 4.7 stable is available directly in the project folder under `Godot_v4.7-stable/`; the downloaded archive is `Godot_v4.7-stable_win64.exe.zip`.
- The complete playable progression is wired: opening panels advance into Jungle, Jungle advances into Cutscene 1 after the required records, Sea advances into Cutscene 2 at the lighthouse, Nightmare advances into Ending at the exit, and Ending advances into the post-ending sting.
- Visual pass: `art/jungle.png`, `art/sea.png`, and `art/nightmare.png` provide the illustrated world plates. The menu, cutscenes, HUD, map markers, and horror overlays were restyled around them.
