# King opening, forbidden gate and darker endings

Current game: `project.godot` in this directory. Parent `RUN_MAP.bat` launches it.

## Integrated changes

- Restored the supplied ZIP's native seven-panel animated King/abbey/harbour/voyage opening and island-arrival film. Contact-sheet inspection of `Videos/start.mp4` confirmed the matching King, chart, journal, abbey and harbour visuals. The video and ZIP remain untouched. The ZIP is a partial source package, not a complete replacement project.
- God names are now encountered at sea beacons, ordered jungle landmarks and cave paintings. Interludes are short connections rather than deity lecture cards. Lore wraps within the playable viewport. Original map drawing is retained at higher bake resolution (sea 1.7x; jungle 2x).
- Cave exit requires reading the bones, spiral and cave-chart warnings. The door stays physically closed until these are read, encouraging two side-chamber detours.
- Two physical maze ward stones, west crypt and south-east archive, must be broken before collecting the Black Key. The original three-key puzzle, portals, changing walls, ink barriers and sound-sensitive chase remain. Hunter speed remains 0.9x walking speed; door-bash delay becomes 1 second.
- Optional red gate is explicitly marked AZATHOTH / NO EYE MAY CROSS. E/Space swings its thick door; walking across its Area3D freezes the player immediately and leads to a distinct witnessed-death loss. Closed gate is safe. Fixed a real collision bug by moving the AnimatableBody3D itself, not its parent pivot.
- Escape retains waking at the camp and the approaching-figure sting, with an indirect flute/dreamer doubt. This game's abbey believes Azathoth is the dreamer behind the world; it is not presented as a verified Lovecraft canon statement.
- Loss animates the cartographer's human mark flattening into a permanent wall stroke in the chart. The narration identifies him as another wall for future dreamers, while his hand continues drawing. Witnessed death also uses this loss, never the victory route.

## Current reveal and materials

The forbidden reveal now renders a detailed **stone idol** live at 1920x1080 with moving camera, physical surface textures, lantern/cold rim light, and fog. It is not a photograph, an animated organic creature, or a literal complete model of Azathoth. The deity remains beyond the representation.

- [Gothic Statue by Benny Weimer, Poly Haven](https://polyhaven.com/a/gothic_statue), newly downloaded 4K glTF/dependent textures, checksum verified by `tools/download_idol.ps1`. The 2K cinematic model remains unchanged. Used as an ominous forbidden idol, not as an assertion of the god's anatomy. MD5: glTF `164da7d2587e618af36d9b441b8794eb`; diffuse `fd06f6c7067fb06efa2d66a64761996c`; normal `0ec02d44e000b538e7650304775d8d19`; packed ARM `9983b575e15ffb6b3af88a100d67835f`; mesh buffer `64ff6a07591c56042e01c780dce7685b`.
- [Rock Wall 07, Poly Haven](https://polyhaven.com/a/rock_wall_07), newly downloaded 2048px diffuse/normal/roughness maps. [CC0 asset license](https://polyhaven.com/license). Replaces regular brick material across the labyrinth and cave doorway.
- Verified MD5: diffuse `befd1e1ae48fd7b04a5a88e702ded6da`, normal `e48d7cf220ea05e29589b9b50d6ee059`, roughness `e2dbd41e4e914c1895612444e4b80a7a`.

An earlier painterly reference was made with the **imagegen skill**, built-in `image_gen` generation mode, saved as `assets/art/azathoth_reveal.png`. It remains reference artwork, **not the active gate reveal**. A requested photoreal edit was rate-limited, so no successful photoreal image generation is claimed. The live asset approach was chosen and disclosed instead.

Original generation prompt:

> Use case: stylized-concept. Asset type: landscape horror-game forbidden gate reveal, an original depiction inspired by Azathoth the blind nuclear chaos. Create a high-detail dark painterly cinematic image, wide 16:9 composition. Deep black cosmic abyss framed with crumbling ancient grey monolithic stone; an immense incomprehensible blind god, only fragments of a writhing mass of leathery folds and closed eye-like fissures visible, scale so immense the human view cannot encompass its form. A tiny abandoned cartographer's map at the lower edge supplies scale, delicate dirty ivory glimmer, ash motes and a faint dying amber-red light from within the abyss. Cosmic psychological dread, not a conventional dragon, not Cthulhu, no winged humanoid, no generic horned monster, no full-body creature silhouette, no gore. Extremely detailed tactile surfaces and restrained contrast, center portion discernible but edges swallowed by absolute dark. No lettering, no text, no watermark. This will be subtly animated in-engine with slow parallax and exposure, leave the lower quarter mostly dark for a caption. Resolution suitable for an HD game reveal.

## Verification and limits

- `tools/revision_test.gd`: 33 assertions passed headlessly and with the real renderer. The latest headless run exited 0; earliest headless run returned 1 after its assertions, recorded rather than treated as a clean run. Source/scene imports and playable chapter instantiation passed.
- `tools/gate_asset_test.gd`: verifies actual movement against the closed physical door, walking through the opened gate, the live HD model and connection to the losing story. Initial test caught a real parent-pivot collision bug; corrected run passed all seven assertions and exited 0.
- `tools/revision_endings_test.gd`: escape, caught and witnessed full sequences all reached their end cards; checked dream hint / wall assimilation respectively, exit 0. Uses 8x time scale for narrative verification.
- Real-renderer `tools/finale_test.gd` run mode: walked the extended route, broke both wards, collected all three keys, opened gates and escaped with hunter active. Timer 01:31.23, process exit 0. Bot time is not a promised human playtime.
- Actual engine captures in `qa/revision_*.png` were inspected. `revision_live_idol.png` is the current asset reveal; `revision_azathoth.png` is an older painterly-reveal capture.
- Final 4K-idol import exited 0, and the actual-movement/HD-reveal gate test passed all seven assertions again with the upgraded asset, exit 0. Final headless `tools/story_test.gd` passed 43 checks, exit 0, including opening controls, connective transitions, volume/mute/silence and chapter selection. Its earlier rerun exposed a removed-intro coroutine trying to restart gameplay; added exit-tree cancellation and post-await lifetime guards, then reran cleanly.
- Some test teardown runs retain ObjectDB/resource warnings. No guarantee of warning-free shutdown, photoreal organic god animation, human difficulty balance, universal hardware performance, or competition victory.
- No MASTER_NOTES PDF found; none created or modified. Root and merged project memory remain separate from the unchanged trailer project.
