# Cartographer's Dream / MAP

A playable Godot horror game with five connected chapters:
Jungle investigation → nautical escape → dream city → 3D ochre cave → first-person labyrinth.

Double-click **RUN_MAP.bat** in this folder to play. The bundled Godot 4.7 engine is used automatically. **OPEN_MAP_EDITOR.bat** opens the project editor; press F6 or F5 to play, not just the Game tab.

## Controls

- WASD / arrows: move; Shift: sprint or row faster. Endurance is limited; the BREATH meter shows recovery.
- E / Space: examine, open doors, dock, close a record.
- Mouse: look around in the cave and labyrinth.
- F: use a flare at sea (three charges; stuns nearby tentacles).
- Hold Tab: survey the map. Movement and enemies stop; the run clock continues.
- F1: field journal. F2: toggle the timer, hidden by default. F3: WHAT I KNOW, chapter explanation and Mythos field guide.
- Escape: pause, restart a chapter, or save and return to menu.
- Cutscenes: release Space / Enter to continue; hold to skip. The final approaching-figure scene cannot be skipped.

## Chapters and story

The cartographer falls asleep drawing beside the expedition campfire. His jungle chart becomes a place to walk, then an impossible ocean, then a city whose inhabitants know his expedition. An ochre cave records the same journey thousands of years earlier. The final ruin turns observation into pursuit.

The enlarged jungle requires all three surviving expedition records (I, II and IV) and the eastern observatory bearing before the survey exit. The sea requires three bell soundings in any order, then docking on either side of the wharf. Its expanded voyage has a ninety-second deadline: each sounding replenishes one flare, up to three. Burning flares stun new arrivals as well as the initial nearby threats. Investigate four distinct city accounts, including the tower exhibition, to reach the cave. Read all four ochre warnings to descend. In the labyrinth, erase your name at both red witnessing seals, find the brass key, unlock the final wooden door and reach the light. The key alone cannot free you.

Five optional ruin inscriptions and the expanded journal connect missing people, erased maps, names as addresses and the danger of taking a remembered place home. The black figure gives intermittent guidance toward your next unfinished objective; it is not always visible.

The beast normally follows physical corridors at 90% of walking speed. Breaking a seal triggers a seven-second hunt surge slightly faster than walking; save endurance for that escape. Escape leads to morning, an ordinary-life epilogue and the returning figure. Capture leads to a different ending, with a close-up, screech, blood and fade.

## Saves and timing

Settings, chapter-start checkpoints, journal and completed escape times are saved locally in Godot's user-data directory. Resume restarts the saved chapter, not the exact room or position. The leaderboard is local, not online.

The timer measures active gameplay across chapters, includes survey view and failed attempts, and excludes pauses, reading and cinematics. Chapter split times are stored with each successful run.

## Verification

Run in PowerShell from this folder:

```powershell
& '.\Godot_v4.7-stable\Godot_v4.7-stable_win64_console.exe' --headless --path . --script res://tests/full_game.gd -- --test
& '.\Godot_v4.7-stable\Godot_v4.7-stable_win64_console.exe' --path . --script res://tests/full_game.gd -- --test --screenshots
& '.\Godot_v4.7-stable\Godot_v4.7-stable_win64_console.exe' --path . --script res://tests/performance.gd -- --test
& '.\Godot_v4.7-stable\Godot_v4.7-stable_win64_console.exe' --headless --path . --script res://tests/voyage.gd -- --test
```

The `--test` flag uses separate save data, never your real journal or leaderboard. Renderer captures go to `qa/expanded/`. Headless verification skips captured mouse input, which requires a window.

## Source and scope

Read `RESEARCH.md` for linked original Lovecraft texts, folklore sources and explicit distinctions between adaptation and canon. `SUBMISSION.md` provides a demonstration plan and submission checklist. The menu's LORE & SOURCES archive and F3 guide explain the story without requiring prior Mythos knowledge.

`Main.tscn` starts `scripts/game.gd`. The chapter implementations are `scripts/level_2d.gd` and `scripts/level_3d.gd`; doors, maze layout, presentation and save data are separate modules. `world_art.gd`, `ambient.gd` and `shaders/cartography.gdshader` provide original runtime visuals, synthesized ambience and chart discovery.

This is a stylized playable build, not photorealistic production art. Cinematics are animated in-engine tableaux with text, not prerecorded film. Whispers are written subtitles over synthesized sound, not recorded voice performances. The earlier generated background images and old `main.gd` prototype are retained but unused. Automated progression and rendering checks do not establish a measured human playthrough length.
