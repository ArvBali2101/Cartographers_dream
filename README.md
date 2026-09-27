# Cartographer's Dream

A playable Godot horror adventure: a cartographer's maps become a nightmare that begins to observe him back.

## Play

On this computer, double-click `RUN_MAP.bat`; use `OPEN_MAP_EDITOR.bat` for editing.
On another computer, install Godot 4.7, import `merged_game/project.godot`, let assets import, and press F5. This is a source submission, not an exported standalone executable.

## Chapters

1. The Drowned Chart: sail a shifting nautical map, light three beacons and dock while tentacles close in.
2. The Survey: survey jungle landmarks and discover the cave replacing camp.
3. The Hollow: explore a sealed first-person cave and read its three required warnings.
4. Waking: collect keys and ward stones in an ancient stone labyrinth, evade the hunter and find the light. A warned forbidden gate leads to a separate witnessed death.

Includes the animated King/abbey/voyage introduction, connecting scenes, adaptive soundtrack, escape and losing endings. Named-god lore is encountered in the world; abbey beliefs are fictional, not claims about Lovecraft canon. Timer display is off by default. The menu includes chapter selection and settings.

## Controls

- WASD / arrows: move; Shift: sprint; mouse: first-person look.
- E / Space: interact; Tab: map; Esc: pause.
- 1 / 2 / 3 or mouse wheel: select a maze key.
- Papers: Next/Previous page; **Finish reading** or E/Space/Esc closes. Gameplay and the timer pause while reading.

See `merged_game/docs/REVISION_NOTES.md` for sources and revision scope, and `CLEANUP.md` for folder organization and recovery of original media. Credits remain with the game.

## Verification

```powershell
& '.\Godot_v4.7-stable\Godot_v4.7-stable_win64_console.exe' --headless --path merged_game --script res://tools/reader_test.gd -- --test
& '.\Godot_v4.7-stable\Godot_v4.7-stable_win64_console.exe' --headless --path merged_game --script res://tools/story_test.gd -- --test
```

Development checks are not a certification of human balance or performance on every machine. Some older harnesses emit teardown resource warnings.
