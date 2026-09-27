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

## 2026-09-27 — Requested comparison with teammate's work

- Read the project memories and inventoried the workspace, including nested files, archives and recent Git history. No MASTER_NOTES file was found inside this project.
- The visible workspace contains the existing five-chapter build, its old prototype and the Godot engine archive. No separately identifiable teammate project, new source archive or second Godot project was found. The worktree was clean before this review.
- Requested the exact location or upload of the new work before making comparative judgments or changing the game. No gameplay files were modified; the comparison and lore integration remain pending those materials.

## 2026-09-27 — Reviewing and improving the merged game

- Corrected the previous assumption that teammate work must occupy a separate folder. Reviewed commit 3a7584a against its parent and followed Main.tscn into scripts/game.gd, the modular five-chapter integration. The merged commit does not reliably attribute individual changes to a person; no claim was made that a specific mechanic belongs to either teammate.
- Kept the combined architecture, first-person geometry, physical doors, stable routes and existing progression. Identified repetitive room composition, long unindexed lore and premature F3 explanations as focused improvement targets.
- Added Morrow's optional letter to Nell, Ada's presence in expedition evidence, three automatic bell observations and a fuller wreck log. Added a missing wreck interaction prompt. These evidence discoveries do not introduce new mandatory collection gates.
- Added five prerequisite-based evidence connections. Replaced the concatenated F1 journal with an indexed browser; records can be reread and return to the index. F3 now summarizes recovered evidence rather than spoiling later objectives. Source archives and guide screens no longer become bogus journal entries.
- Gave the five readable city interiors distinct evidence-bearing compositions, materials, candles, maps and an exhibition seat occupied after examination. Adjusted the room camera to reveal their composition and suppressed the unrelated outside minimap indoors. Added no furniture collisions that could break established routes.
- Checked rendered journal/home/inn captures, then corrected excessive table-only cropping with a wider room view. Added renderer captures for all five interiors and regression checks for evidence prerequisites, guide pollution, index interaction and back-navigation.
- Updated verification: 100 headless and 101 renderer checks pass. Live-steering sea verification still completes with seven pursuers in approximately 48 seconds. Some headless exits retain the pre-existing ObjectDB cleanup warning; no failed assertions or gameplay runtime errors were observed. Human full-run pacing remains unverified.
- Added MERGED_REVIEW.md with source evidence, concrete improvements and limits. Updated FINAL, README and LEARNINGS without removing earlier history. No project files or teammate assets were deleted.

## 2026-09-27 — Teammate visuals as the primary direction

- User clarified that the teammate's visual work should supply the main presentation, with the existing gameplay/lore retained underneath.
- Inspected active visual references, all non-cache project assets and the image commit history. The three art/*.png plates originate in the earlier visual-presentation commit; the active procedural renderer does not load them. This does not establish which merged visual files are the teammate's new work.
- Paused further visual replacements pending identification of a representative teammate screenshot, scene or asset filename. Did not assume the older rejected image plates were the intended new art and did not overwrite merged source.

## 2026-09-27 — Latest merged visuals confirmed as authoritative

- User explicitly identified the latest merged version as the desired visual source. Adopted commit 3a7584a as the visual baseline without further demands for a separate teammate project.
- Removed only the assistant's subsequent city-room redesign and fixed wide-room camera. Restored the merged interior drawing, palette, camera scale and presentation layer using targeted patches, not a destructive Git reset.
- Kept the original merged world renderer, shaders, 3D cave/maze/doors, menus and cinematics. Retained the new personal lore, automatic bell evidence, indexed journal and earned deductions. A small camp-letter marker remains as an interaction affordance rather than a new art direction.
- Reran the real-renderer regression suite with refreshed screenshots. Current source summary and review distinguish the superseded room experiment from the retained merged visuals.

## 2026-09-27 — Root cause: wrong Git ref, actual teammate merge imported

- After another stale-build report, followed the investigation skill's evidence-first approach. Checked launch scripts and all branches, not just local HEAD. Found friend/main at 66af3c3 (merged), while local main is 3a7584a. Earlier assertions that local main was the teammate merge were incorrect.
- git ls-remote confirmed remote main is exactly 66af3c3480f7472095a26509ef7c95e48902696a. The friend tree contains a different four-chapter project, actual fonts/theme/textures/music/cave meshes and sea-first progression; these files were absent from the checked-out local tree.
- Archived and extracted that complete ref into merged_game/, preserving the older local source and all pending lore work. No reset, checkout overwrite or deletion was used. Checked the imported tree for MASTER_NOTES; none was found.
- Initial editor import produced missing-cache errors and quit before finishing; a subsequent --import run completed asset generation. Added isolated --test settings/record paths and a smoke suite for the correct project rather than reusing the unrelated older tests.
- Added lore in existing ship logs, torn pages and interludes without changing the friend's visual renderers or importing the old city's objectives. Kept the existing Harrow/Vane story thread and added personal expedition details.
- Updated RUN_MAP.bat and OPEN_MAP_EDITOR.bat to target merged_game/. Added an explicitly named legacy launcher. Root README/FINAL/review/submission now distinguish the actual active build from historical prototype results.
- Corrected-project smoke runs pass 18 checks headlessly and with the real OpenGL renderer. Inspected actual menu/jungle/finale captures. Representative critical visual source and asset hashes match friend/main exactly. Test teardown retains ObjectDB/resource cleanup warnings, so this is reported as scene-loading verification rather than clean full-game completion.

## 2026-09-27 — HD/lore upgrade on the correct friend base

- Downloaded eight checksum-verified 2K CC0 Poly Haven maps and integrated real cave rock and labyrinth stone materials. Retained friend gameplay, map art, geometry and audio. Added saved rendering presets and inspected native HD engine captures.
- Researched primary Lovecraft, Blackwood and Chambers sources; added original dream evidence, environmental wrongness and unfinished-map warnings through existing story channels. Added readable page blocks and synchronized cave generator lore.
- Correct-project smoke passed 25 checks both headlessly and at 1080p. Cave bot reached the finale through its interlude; monster-active finale bot collected all keys and escaped. Resource cleanup warnings and human pacing/performance limitations are documented in merged_game/HD_UPDATE.md. This does not validate the archived root prototype.
- Final HD renderer rerun passed 26 checks, including extended lore bounds. Friend music, jungle gameplay, beast and doors remain byte-identical by git blob comparisons.
- Final renderer exited 1 after its 26-check success report, without further diagnostics; documented as unresolved shutdown rather than a clean run. Earlier smoke and progression bots exited 0.

## 2026-09-27 — Explicit Outer God lore and cinematic/audio update

- Expanded the correct merged_game with directly named Nyarlathotep, Yog-Sothoth, Azathoth and Shub-Niggurath lore, keeping Cthulhu separate. Added primary-source research links and distinctions between lore sources and invented map rituals.
- Added animated chart inserts, responsive progressive text, varied figure framing, live HD 3D gothic figure and final approach sting. Downloaded and verified a detailed CC0 model rather than claiming a primitive stand-in was realistic. Model animation is camera/breathing motion, not skeletal walking.
- Unlocked all chapters and exercised selection into the actual labyrinth. Kept full-story speedrun and chapter practice distinct.
- Added two original stereo horror layers to the existing mixer without rewriting the ten original soundtrack OGG files. Tested loading, fades, mute and silence.
- Final headless story verification passed 43 checks, exit 0; updated full ending passed headlessly. Fixed test reveal timing and isolated physical keyboard input during renderer narrative automation. See merged_game/JOURNAL.md for final renderer results and all scope limitations.
- Isolated real-renderer story rerun passed 43 checks and exited 0; inspected actual detailed figure, named-god cutscene and chapter picker renders. All original soundtrack OGG files remain unchanged.
- Full updated escape ending passed with the real renderer: visitor approach and subsequent end card, exit 0; inspected its captured frame.

## 2026-09-27 — Cinematic trailer from supplied footage

- Reviewed all five new Videos clips and built a separate Trailer project: real-world player/laptop opening, jungle chart, cave descent, labyrinth chase and brief reveal.
- Prepared a roughly 80-second cut with widescreen framing, custom title cards, color treatment, original horror soundtrack and selected gameplay sound effects. Originals and game code are untouched.
- Used local Resolve 21.1 as requested. External scripting was unavailable; internal console scripting successfully imported the media and created an editable native cut timeline and DRP export. Integration/render details and final QA are maintained in Trailer/JOURNAL.md.
- Checked again for MASTER_NOTES; no matching PDF was located. No PDF was created or changed.
- Completed the native Resolve master and project export. Corrected an exclusive-end-frame API issue that initially left one-frame cut gaps. The final 79.8-second HD master fully decodes; native XML verifies 31 picture shots, 2,394 frames and no gaps. Measured audio about -14.7 LUFS / -1.5 dBTP. Final artifacts are in Trailer/; use MAP_Trailer_Master.mp4.

## 2026-09-27 — Email-sized trailer

- Produced `Trailer/MAP_Trailer_Outlook.mp4`, a 12.96MB 720p derivative suitable for common Outlook attachment budgets, retaining the full trailer and stereo audio. Complete decode passed; sampled visuals checked. Verified the 114.93MB master remained unchanged by SHA-256. No email was sent.



## 2026-09-27 — Authored King opening and playable horror revision

- Reviewed the supplied partial ZIP and start.mp4 reference. Restored the native animated King/abbey/harbour/voyage sequence and arrival film without replacing the preferred merged game's levels, controls or soundtrack.
- Moved named-god evidence into beacons, survey landmarks and cave murals; shortened connecting interludes, improved wrapped lore and map bake resolution. Added required cave warning detours and two maze ward stones before the Black Key. Kept three keys, ink walls, portals and the 0.9-speed hunter; shortened its door-bash delay.
- Replaced regular bricks with checksum-verified 2K CC0 Rock Wall 07. Added an optional warned Azathoth gate, immediate death and a live 1080p detailed stone-idol reveal. Generated painterly artwork was inspected but user rejected its artificial appearance; photoreal edit hit a service usage limit. Switched to the disclosed asset-based in-engine render; reference image retained, no claim of a photoreal organic god.
- Actual movement testing exposed a gate hinge/collision bug missed by direct callback tests; fixed by animating the physics body itself. Corrected physical-gate test passed seven checks, exit 0. General revision: 33 checks passed in renderer and headless, final headless exit 0. All three complete ending sequences reached their end cards. Active-hunter traversal of the extended maze escaped at bot time 01:31.23, exit 0.
- Escape adds an indirect doubt about the abbey's dreamer belief. Loss visibly flattens the cartographer mark into a maze wall, serving the power beyond the chart. Witnessed death correctly selects loss rather than waking victory. See merged_game/REVISION_NOTES.md for sources, exact scope and remaining teardown/human-QA limitations. No MASTER_NOTES PDF found or changed. Existing trailer files are untouched.

- Final asset refinement: downloaded a separate 4K Gothic Statue glTF/texture set, verified every API MD5 and imported successfully, leaving the existing 2K cinematic model unchanged. The refined live-idol frame was inspected; final physical-gate test passed seven checks, exit 0. A story regression rerun caught an intro coroutine continuing after scene removal; fixed exit-tree cancellation and post-await guards. Final story regression passed 43 checks, exit 0.
## 2026-09-27 - Submission cleanup and paper-reader fix

- Replaced the blocking timed paper overlay with a paused, scrollable reader, Next/Previous controls and an explicit Finish reading button. E/Space/Esc also closes it; cursor, controls and timer resume correctly. Reader uses a separate UI layer above the HUD.
- Final headless reader regression passed 19 checks, exit 0; story regression passed 43 checks, exit 0. Earlier native reader regression also passed 19 checks, exit 0.
- Archived the obsolete root game, original video/trailer files, redundant downloads, unused reference art/textures and generated QA files outside the repository. Preserved original files rather than permanently erasing them. Current project remains merged_game/project.godot; bundled engine remains locally available.
- Moved research/revision documents into merged_game/docs; rewrote root launch/submission guidance and added CLEANUP.md. No MASTER_NOTES PDF was found or changed. Preparing the tested active source and assets for origin/main; push status is recorded separately after upload.
- Submission upload verified: game commit `ac72467` successfully pushed to `origin/main` at https://github.com/ArvBali2101/Cartographers_dream. Final checks: reader 19/19, story 43/43, four-chapter smoke 26/26; all exit 0. Smoke still reports known resource warnings during teardown. Original media/legacy files remain recoverable in the sibling archive. This note is included in the follow-up handoff commit.
