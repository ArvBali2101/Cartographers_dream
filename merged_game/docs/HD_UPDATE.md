# HD and horror update — 27 September 2026

Launch the parent RUN_MAP.bat. It opens this merged_game project, not the older root prototype. Settings > Rendering chooses Performance, HD / 2x AA, or High / 4x AA. Fullscreen renders at the display's native resolution. The default window is 1600x900; the UI retains its 1280x720 design grid.

Eight real 2K surface maps were downloaded and checksum-verified: castle wall and cobblestone floor diffuse/normal/roughness, cave rock diffuse/normal. Materials now use them, with anisotropic filtering on labyrinth stone. The cave keeps its sculpted mesh, ochre paintings and earth floor; both illustrated chapters retain the friend's drawing pipeline. No AI background replaces gameplay.

The story connects shared sea dreams, unclassifiable foliage, deliberately unfinished cave paintings and the risk of publishing the chart. Extra evidence appears in existing torn pages and chapter transitions. Longer pages appear in separate readable blocks with a reading-length hold; repeated interactions cancel the previous page tween. Movement, collision, keys, doors, flares, ink and the sound-sensitive monster remain the friend's systems. Original adaptive audio remains.

See RESEARCH.md for primary literary sources and asset licensing. These are original adaptations, not a literal shared Lovecraft/Blackwood/Chambers canon.

## Verification

- Asset import completed successfully in Godot 4.7 Compatibility.
- Renderer smoke at 1920x1080 and headless smoke each passed 25 checks before adding the separate extended-page check.
- Final 1920x1080 renderer run passed all 26 checks, including the extended evidence block fitting the viewport. Music, jungle gameplay, beast and physical door scripts were additionally hash-checked against friend/main and remain unchanged.
- That final renderer process returned exit code 1 after reporting 26/26 checks, without further diagnostic output. Earlier 25-check renderer/headless runs and both gameplay bots returned 0. The final shutdown therefore remains unresolved; assertion success is not a clean-exit claim.
- Real-renderer cave route bot walked from entrance to exit, opened the door and transitioned through the interlude into Waking.
- Finale bot in run mode (monster active) collected Iron, Stone and Black, opened all gates, completed the chase and escaped into the ending. Reported game time 01:09.51. This is a bot route, not a representative first-playthrough time.
- Engine screenshots in qa/ include settings, chapter starts, field-note layout, cave route, monster wake/chase and ending. These are actual renders, not mockups.
- Smoke teardown still reports two ObjectDB instances and one resource held at exit. No claim of a warning-free harness, balanced human run, guaranteed FPS or a competition win.
