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

## 2026-09-26 — World presentation and runtime verification

- The user rejected the flat geometry presentation. Added original runtime artwork in `world_art.gd`: textured ground and water, detailed palm fronds, rocks, curved soil paths, campfire and tent, ruins, shipwreck, bone island, lighthouse beam, tiled masonry and an organic eye reveal. The earlier generated panoramic assets remain on disk but are not used by the current game.
- Added a following camera at 1.45x scale, animated cartographer with lantern, boat rotation and wake, fog and edge shading. Kept the requested 2D top-down perspective.
- Corrected actual gameplay defects: key release could close dialogue, sea horror reached maximum without drowning, the nightmare figure started beside the exit, F2 was inaccessible inside gameplay branches, menu clicks ignored the selected option, and the post-ending clock never advanced.
- Added original synthesized wind, water and drone sound layers in `ambient.gd`. These are ambience, not recorded dialogue or whispers.
- Added a six-second Blind God reveal at the fourth nightmare guide checkpoint, followed by resumed escape. Collision now permits sliding along barriers, the ship accelerates and slows, and nightmare sprint works.
- Added `tests/progression.gd`. Nineteen automated checks pass, including injected WASD input, dialogue press/release, chapter transitions, sea timeout, finale, and grid-based reachability of the required jungle objectives and every nightmare checkpoint.
- Ran the tests with the real OpenGL renderer and inspected captured screenshots in `qa/`. Reduced intrusive sign labels, fixed lingering death overlays, softened paths and improved eye artwork based on those captures.
- Verification is automated progression and scene rendering, not a measured 20–30-minute human playthrough. The project remains a short stylized 2D prototype; earlier claims of a finished production game overstated its state.

## 2026-09-26 — Cartographer's Dream: five-chapter expansion

- Read the permanent project memories and checked for MASTER_NOTES; no matching PDF was present. No PDF was created or changed.
- Interpreted the latest narrative as Jungle → Sea → Dream City → 3D Cave → 3D Labyrinth, explicitly keeping jungle first rather than the earlier optional sea-first proposal.
- Replaced the active entry script with a modular implementation under scripts/. Preserved the old prototype and unused generated assets rather than deleting project history.
- Added field-journal lore, city interiors and observations, impossible doors, connected cinematic sequences, ochre cave warnings, a sealed cave entrance, the Blind God reveal, and separate capture/escape endings with the approaching-figure epilogue.
- Expanded the nautical chart, added physically obstructing shore rocks, north/south routes, both-side docking, three destination tents, a sixty-second deadline, delayed pursuing tentacles and three flare charges that stun nearby threats.
- Added the actual first-person 3D cave and 255-cell labyrinth: stone walls, black overhead void, distance fog, grouped floating wisps, long galleries, dead ends, wooden hinged doors, a visible exit lock, collectible brass key and light beyond the final corridor.
- Implemented an animal-like physical pursuer at 90% of normal player walking speed, original synthesized proximity sound, screech, cinematic capture close-up, blood splatter and fade. Renderer review caught a door occluding the capture; the capture now hides scenery for an unobstructed beast close-up.
- Added actual menu buttons, sliders and toggles, mouse sensitivity, hidden-by-default speedrun clock, stored split times, chapter checkpoints, persisted journal and local top-ten completed escape records. Save-and-return now preserves observations made during the chapter.
- Added cartographic exploration masking with fully undiscovered outer edges. Tab survey stops movement, mouse-look and threats while still counting run time.
- Runtime verification exposed two important defects: rotating a door's parent changed its image but not the physics body, and a full-screen Control intercepted mouse motion. Fixed these by tweening the AnimatableBody3D hinge in physics and removing the UI input interception.
- Verified 58 headless checks and 59 real-renderer checks, with captured mouse input tested only in a real window. Tests cover required reachability, alternate sea routes, docking, stuns, drowning, chapter progression, cave sealing, key collection, physical doors, both endings and records. Test saves are separate from player saves.
- Inspected real rendered chapter and ending screenshots in qa/expanded/. A 120-frame benchmark measured approximately 60 FPS in the cave and 55 FPS in the labyrinth on Intel Iris Xe at 1280×720.
- Updated README and FINAL to describe the current build accurately. Cinematics are animated in-engine tableaux and text, not prerecorded film; sound is synthesized rather than recorded voice acting. A timed human full playthrough remains unverified.

## 2026-09-27 — Deeper lore, harder routes, stronger scenery

- Read the three project memories before continuing; checked again for MASTER_NOTES and found none. No PDF was created or modified.
- Expanded narrative evidence into scripts/lore.gd: missing expedition members, impossible dates, deliberate omissions, names acting as addresses, an atlas of absences, the inn's ledger, the copying cartographer, a future wreck log, four ochre warnings and five optional labyrinth inscriptions. Preserved ambiguity about the small figure and the entities.
- Made all three surviving expedition records necessary to complete the jungle, with required-route reachability checks.
- Added limited sprint endurance and recovery hysteresis across all chapters. A small breath meter appears during expenditure/recovery rather than permanently cluttering the screen.
- Raised sea pressure with earlier and more frequent tentacle spawning, a higher seven-tentacle cap and shorter/range-limited flare stuns; retained the sixty-second deadline and both viable routes.
- Added two red witnessing seals on distant reachable maze detours. Both signatures must be erased before the brass key can unlock the final exit; interaction records associated lore. Increased pursuer wake pressure and made the route guide intermittent rather than permanently revealing the answer.
- Added a player marker in the frozen 3D survey view so harder navigation remains readable.
- Upgraded stonework with world-scaled triplanar brick textures, normal relief, varied courses and more detailed floors. Batched cornices, base trim and pillars into a MultiMesh to limit draw-call overhead. Added paper evidence plinths, faceted cave surfaces and hanging formations without new route-blocking collision.
- Replaced repeated cave line patterns with distinct river/camp/procession, animal/closed-eye, labyrinth/key/two-seal and palm/house/eye drawings. Added irregular pigment transparency for a worn ochre surface.
- Added city roof courses, eaves, windows and ivy, plus discovered survey grids, compass roses, shoreline depth contours, soundings and animated fireflies to the 2D world.
- Godot validation caught an inferred-type error in the new detail builder; supplied an explicit material type and reran progression.
- Verified 69 headless and 70 real-renderer checks. New tests exercise endurance, the third record, both seal detours/interactions and the key-only unlock refusal. Inspected actual renderer captures. A 120-frame benchmark measured 60.5 FPS in the cave and 57.6 FPS in the maze on Intel Iris Xe at 1280×720.
- The larger/harder finale has not been timed in a full human playthrough. The benchmark is a short rendering sample, not a guarantee for all views or devices.

## 2026-09-27 — Current story and gameplay explanation

- Reviewed the active narrative, lore records and current implementation to explain the complete five-chapter story, both endings, optional evidence, controls and progression rules.
- Distinguished the lore's suggested interpretation from confirmed events and preserved the unnamed figure's ambiguity. Clarified that the current build uses illustrated in-engine story sequences and textual dialogue rather than filmed cinematics or recorded actors. No gameplay code changed during this explanation.

## 2026-09-27 — Primary-source research and expanded submission build

- Read project memories and checked for MASTER_NOTES; none was found. No PDF was created or changed.
- Researched five original Lovecraft texts, Historic England protective-mark interpretations and the National Library of Wales ghost-light account. Added RESEARCH.md with linked sources, adaptation boundaries and precautions against treating folklore as universal ancient jungle belief.
- Added observatory, chapel and exhibition evidence; chapter conclusions and F3 WHAT I KNOW explain how maps become connections and signatures become addresses. The menu archive makes research/context accessible without prior Mythos knowledge. Kept the small figure and exact identity of the Blind God ambiguous.
- Expanded jungle to 2,230 by 1,450 with a required observatory detour, sea to 4,200 by 1,900 with three navigable soundings, city to 2,180 by 1,450 with four required accounts including the exhibition, cave to 63 cells/all four murals, and finale to 323 cells.
- Changed the longer sea deadline from sixty to ninety seconds. Added a submerged-eye event and bell cues, cave answering knocks/intermittent guide, and seven-second post-seal hunt surges. Added restrained responsive screen atmosphere, soft wisp halos, CPU dust and grain-textured wooden doors with distinct protective rosettes. Kept actual meshes/collision rather than image plates.
- Navigation review added camera bounds, larger local reveal and explicit objective annotations in frozen survey view. Moved the breath display away from interaction text.
- Live-steering verification initially failed despite graph reachability. Improved the test pilot's waypoint tolerance and pursuit-aware sounding order, then found a real resource gap in the longer voyage. Burning flares now stun incoming pursuers; each sounding replenishes one charge, capped at three. The live boat test completed all bearings and reached the wharf in 47.92 simulated seconds with seven pursuers active and no remaining flares, without teleportation.
- Expanded regression coverage to 87 headless/88 renderer checks. A short 120-frame renderer sample measured cave 60.5 FPS and maze 53.3 FPS on this machine. This is not a human pacing test or a performance guarantee.
- Updated current summary, controls, research notes and submission/demo checklist. Preserved old history and assets. No external submission was made, and no competition outcome was promised.
