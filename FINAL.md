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
