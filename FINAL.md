# Cartographer's Dream / MAP — current build

Current handoff: the **Latest game revision — 27 September 2026** section below supersedes older cinematic/lore descriptions. See `merged_game/REVISION_NOTES.md` (or `REVISION_NOTES.md` within the merged project) for the restored King opening, in-level lore, longer ward route, physical lethal gate and asset-based reveal. Older sections are retained as history.

## Active handoff correction

Email-ready trailer: `Trailer/MAP_Trailer_Outlook.mp4` is a verified **12.96 MB** 720p copy retaining the complete trailer and stereo audio. Use it for an Outlook attachment. The 1080p master and native Resolve project are unchanged.

Completed trailer: `Trailer/MAP_Trailer_Master.mp4` is the 79.8-second 1080p cinematic edit from all five supplied `Videos/` clips, with original horror score and gameplay effects. Assembled and rendered in DaVinci Resolve; editable project `Trailer/MAP_Trailer.drp` and native XML backup included. Full decode, audio levels and 31-shot / 2,394-frame / zero-gap timeline verified. Source videos and game files are preserved. See `Trailer/FINAL.md` for opening and editability details.

Current additions in merged_game: directly named Outer God lore; animated cuts and a detailed CC0 3D figure rendered at 1080p; unrestricted chapter selection; two new original stereo horror music layers. All ten original soundtrack OGGs remain unchanged. Headless story checks pass 43 assertions and the updated complete ending reaches its end card. See merged_game/FINAL.md for current status and source/animation limitations.
The final real-renderer story run also passes 43 checks and exits 0; inspected actual chapter, lore and figure captures.
The complete updated ending also passes its visitor/end-card checks in the real renderer, exit 0.

Latest improvement: the correct friend build now has eight verified 2K CC0 texture maps, saved quality presets, richer original horror lore and readable page blocks. Its four stages and adaptive audio are preserved. The HD renderer/headless smoke each passed 25 checks; cave progression and a monster-active three-key finale escape were exercised by bots. See merged_game/HD_UPDATE.md and RESEARCH.md for exact scope, sources and limitations. Run RUN_MAP.bat, not the archived root project.godot.

**The primary game is now `merged_game/project.godot`, imported from friend/main at 66af3c3 (merged).** The remote was checked and confirms that exact latest commit. RUN_MAP.bat and OPEN_MAP_EDITOR.bat target it. The earlier assumption that local main at 3a7584a contained the desired teammate work was wrong.

This correct project retains the friend's four-chapter sea/jungle/cave/labyrinth visuals and systems. Lore additions are made in its ship logs, torn pages and interludes, not by imposing the older project's city or seal objectives. Its own memories are in merged_game/. Source and assets of the older build are preserved; RUN_LEGACY_MAP.bat can open it deliberately.

The corrected build's smoke suite checks save isolation, its fonts/theme, menu and all four chapter scenes. Older 101-check results and 53 FPS samples below do not certify this different codebase. Full end-to-end player testing remains required.

## Archived five-chapter state

Final updated-build HD renderer verification: 26 checks passed. See merged_game/HD_UPDATE.md; the archived material below is historical, not the active project.

The project is now a playable five-chapter Godot horror game: Jungle → Sea → Dream City → 3D Cave → 3D First-person Labyrinth. The latest jungle-first narrative takes precedence over the earlier optional sea-first suggestion.

## Play

Double-click `RUN_MAP.bat`. The engine is bundled in this exact project folder. Controls and verification commands are in `README.md`.

## Implemented

- Original navigable jungle cartography: terrain speeds, rivers, bridges, elevation barriers, two camp tents, skull motifs, three required expedition records, elusive figure and a deliberately imperfect memory minimap.
- A 4,200-by-1,900 nautical chart with three mandatory soundings, open-water route choices, shore rocks, three destination tents, both-side docking, escalating pursuit and a ninety-second drowning deadline. Three starting flares stun threats; soundings replenish one charge up to three and burning lights affect incoming pursuers.
- An enlarged dream city with six readable interiors, four required distinct observations including the tower exhibition, an optional protective chapel, a marked lethal doorway and impossible-door displacement.
- A 63-cell first-person cave with all four ochre murals required, brown rock, floating dust, soft wisps, a disappearing guide and an entrance that seals with physical stone.
- A 323-cell first-person labyrinth with long galleries, dead ends, empty rooms, stone-brick walls, darkness, distance fog, halo-lit wisps, grained hinged wooden doors and protective rosettes, a brass key and two distant witnessing seals. Both seals must be broken before the key can open the exit. Breaking one triggers a seven-second pursuit surge.
- A dark animal-like pursuer with red eyes, legs, horns, fangs, movement animation, physical corridor pursuit and synthesized proximity audio. Walking speed is 90% of the player's normal speed.
- Connected story sequences, the Blind God reveal, a capture close-up/blood/losing ending, morning escape, ordinary-life epilogue, the approaching figure and credits.
- Real menu widgets, grayscale settings, mouse sensitivity, optional timer hidden by default, pause/restart, chapter-start resume, journal, local top-ten escape records and stored split times.
- Chart-discovery shader that starts hidden outside the initial brush. Holding Tab freezes movement and threats while the run clock continues.
- No generated image plates used in the active game. Runtime artwork and synthesized audio remain intentionally stylized.

## Architecture

`Main.tscn` → `scripts/game.gd`, with separate 2D chapter, 3D chapter, maze-layout, physical-door, presentation and save-data modules. `world_art.gd` and `ambient.gd` provide original scenery and ambience. Previous files and project history were preserved.

The Compatibility renderer supports this machine's Intel Iris Xe. Depth fog is used rather than Forward+-only volumetric fog; see [Godot environment documentation](https://docs.godotengine.org/en/4.7/tutorials/3d/environment_and_post_processing.html).

## Verification and limits

The real Godot/OpenGL progression suite now passes 101 checks (100 headless), including evidence prerequisites, guide/journal isolation, indexed-record back-navigation, mouse-look, endurance, required extended objectives, sea alternatives, docking, flare stun, deadline failure, city interiors, cave sealing/readings, key pickup, physical doors, seal detours and surge, map-view movement lock, both endings and local scores. Test saves are isolated from player data. Renderer screenshots are in `qa/expanded/`. A separate live-steering sea test completes all soundings and reaches the wharf in approximately 48 simulated seconds under seven active pursuers, using available flares; it does not teleport between objectives. Some headless test exits report the pre-existing ObjectDB cleanup warning.

A 120-frame benchmark of the latest visual upgrade measured 60.5 FPS in the cave and 53.3 FPS in the labyrinth at 1280×720 on this machine. This is not a guarantee for other devices or every camera position.

## 27 September — lore, difficulty and visual pass

The deeper narrative links missing expedition members, impossible dates, an atlas of deliberately omitted places, names as addresses, and maps as routes back to their makers. Expanded evidence lives in `scripts/lore.gd`: three expedition records, four city accounts, a wreck log, four cave warnings and five optional ruin inscriptions. The small figure remains unexplained.

Sprinting lasts about 3.8 seconds from full endurance, recovers over 6.5 seconds, and cannot restart after exhaustion until 35% recovered. A subtle BREATH meter appears only when needed. Sea pursuit begins after six seconds, can grow to seven tentacles and flares stun for 4.5 seconds within 360 chart units. The maze pursuer wakes at fourteen seconds or when key/seals are disturbed; the guide is visible for three seconds in each nine-second cycle. Its route points toward unfinished seals, then the key, then the exit. Survey view includes a player marker.

Visual improvements include world-scaled stone textures with surface normals, varied brick tones, floor courses, batched cornices/base trim/pillars, paper evidence on plinths, faceted cave rocks and hanging formations, distinctive grainy ochre scenes, city roof courses/windows/ivy, survey grids, compass roses, shoreline contours, soundings and fireflies. Decorative additions do not narrow collision routes.

Cinematics are in-engine animated tableaux with text, not prerecorded movies. Audio is synthesized, without recorded actors or spoken whispers. There is no online leaderboard. Resume starts the saved chapter. A timed human end-to-end playthrough and production-art/audio polish remain outside the verified state; do not describe the build as perfect or photorealistic.

## Research-backed submission pass

`RESEARCH.md` links five original Lovecraft stories and institutional folklore sources. New observatory, exhibition and chapel records distinguish shared dreams, impossible geometry and protective marks from original cartographic-invitation lore. Chapter conclusions, the menu archive and F3 WHAT I KNOW clarify the causal story without naming the small figure or claiming the Blind God is a canonical Azathoth depiction.

Jungle geography is now 2,230 by 1,450 with an additional required observatory detour; the city is 2,180 by 1,450. All five chapters have expanded routes or objectives, not only enlarged backgrounds. New effects include a submerged-eye event, bell/knock/pulse cues, responsive atmosphere grading below the UI, soft wisp halos, drifting dust and textured wooden thresholds. Camera bounds and map-view objective annotations keep the harder navigation readable. The breath indicator avoids the interaction panel.

The sea deadline intentionally changed from sixty to ninety seconds to accommodate three required bearings. Human difficulty and complete-run pacing still need a fresh-player test. Competition rules and judging criteria have not been supplied, so eligibility and a win cannot be guaranteed.

## Merged-work refinement

The combined source was reviewed through its entry scene and integration commit, not by requiring separate teammate folders. `MERGED_REVIEW.md` records the comparison and its attribution limits. Existing teammate/project work was retained.

Morrow's optional camp letter, three automatically recorded bell observations and a fuller wreck log add a personal thread across chapters. Five evidence connections unlock only when their source records have been recovered. F1 is now an indexed journal with selectable records and deductions; F3 presents earned working notes rather than unearned future answers. The menu retains out-of-world Mythos/source context separately.

The attempted new room compositions and wider camera framing were superseded at the user's request. City-room rendering, palette, camera scale and the presentation layer now use the latest merged commit as their visual base. The original merged world artwork, shaders, 3D scenery and doors were retained. A small letter marker supports the new optional camp interaction; lore and journal improvements remain additive.

The user identified the latest merged commit, 3a7584a, as the intended visual source. That version is now authoritative; no separate teammate folder or per-person attribution is required. The later procedural room redesign was removed without resetting gameplay, lore or other project files.



## Latest game revision — 27 September 2026

Use `merged_game/project.godot` or parent `RUN_MAP.bat`. The supplied animated King opening and island-arrival film are restored. God lore is encountered inside the sea/jungle/cave. Higher-resolution cartographic rendering, ancient stone walls, required cave warning detours, two maze ward stones and a warned lethal Azathoth gate are integrated. The gate uses a live HD detailed stone-idol asset, not the rejected painterly backdrop or a literal complete depiction of Azathoth.

Escape retains the camp waking and final figure, adding an indirect dreamer/flute doubt. Loss animates the cartographer into a wall of the map; the forbidden-gate death also uses this losing story. The friend's original four stages, controls, adaptive soundtrack, keys, ink and chase remain.

Latest verification: 33 revision checks passed; physical gate movement test passed seven checks; all three complete ending sequences reached end cards; extended active-hunter finale bot escaped at 01:31.23. Corrected gate test, latest headless revision, endings and gameplay bot exited 0. Some harness shutdown warnings remain; human balance/performance testing is not certified. See `merged_game/REVISION_NOTES.md` for sources and exact limitations. Earlier sections describe previous states; trailer masters/email copy remain unchanged.

- Final refinement: the active forbidden-idol reveal uses a newly downloaded, verified 4K-textured model with a live 1080p render. Its seven actual-movement gate checks passed again. Intro coroutine scene-removal cancellation is fixed; final story regression passed 43 checks, exit 0. Generated artwork remains an unused reference; no successful photoreal organic-creature edit is claimed.
## Submission-ready reader and folder layout - 27 September 2026

The only active project is `merged_game/project.godot`; local launch is `RUN_MAP.bat`. Level 4 papers now have a Finish reading button, Next/Previous controls and E/Space/Esc dismissal. Gameplay and the timer pause while reading. Final reader regression: 19/19, exit 0; story regression: 43/43, exit 0.

Obsolete game files and original video/trailer deliverables are preserved in the sibling `CS Hackathon Archive 2026-09-27` folder, not permanently deleted. See root CLEANUP.md for recovery and Resolve relinking. Research and revision documents now live in `merged_game/docs` (older historical references reflect their previous locations). The repository is a source submission requiring Godot 4.7, not an exported installer. Git upload status is recorded below once verified.
