# Correct merged build

Current handoff: the **Latest game revision — 27 September 2026** section below supersedes older cinematic/lore descriptions. See `merged_game/REVISION_NOTES.md` (or `REVISION_NOTES.md` within the merged project) for the restored King opening, in-level lore, longer ward route, physical lethal gate and asset-based reveal. Older sections are retained as history.

## Current named-god / cinematic update

- Explicit Nyarlathotep, Yog-Sothoth, Azathoth and Shub-Niggurath lore; Cthulhu is separately identified. Sources and original adaptation boundaries are in RESEARCH.md.
- Animated chart inserts, progressive text with responsive continue, staged camera cuts, a live 1080p detailed gothic figure and an approaching-figure escape-ending sting. The imported figure is a stone model with camera/breathing motion, not a rigged photoreal human.
- Choose Chapter now offers every one of the four stages from a fresh save. Chapter practice remains separate from a full-story run.
- Two new original stereo horror layers are mixed through the existing music volume. Original ten soundtrack OGGs are unchanged. Music mute and silence transitions are tested.
- Final headless story verification: 43 checks, exit 0. Updated complete ending reached its end card through the visitor sequence headlessly, exit 0. Renderer reruns and inspected captures are recorded in JOURNAL.md. Earlier teardown issues below remain historical limitations, not silently erased results.
- Final isolated real-renderer story verification also passed 43 checks and exited 0. Detailed figure, god-name story card and chapter panel screenshots were inspected.
- Full updated ending passed both visitor/end-card assertions with the real renderer, exit 0. Its actual approaching-figure frame was inspected. Human audio tuning and playthrough balance remain separate QA tasks.

Older verification statements below describe preceding iterations.

## Current HD/lore update

Eight verified 2K Poly Haven texture maps now provide cave rock and labyrinth masonry/floor surfaces. Performance/HD/High render presets, a 1600x900 default window and actual 1080p captures are available. The friend's four-stage gameplay, adaptive audio, map art, physical doors and hunter remain intact. Original lore inspired by primary Lovecraft, Blackwood and Chambers texts is integrated into transitions, cave observations and readable page blocks. Details and licensing: HD_UPDATE.md and RESEARCH.md.

Verified: 25 smoke checks in headless and real-renderer modes; cave route through its door and interlude; monster-active finale route through three keys/gates to an escape ending (bot time 01:09.51). An additional extended-page bounds check was subsequently added. Smoke cleanup warnings remain. This is not a completed human balance/performance certification.

## Base and previous verification

Final HD renderer rerun: 26 checks passed, including extended lore layout. Hash comparisons confirm the friend's music, jungle gameplay, monster and door scripts remain unchanged.
The final rerun returned exit code 1 after reporting its checks; shutdown remains unresolved. Prior 25-check runs and both progression bots exited 0.

Base: friend/main at 66af3c3480f7472095a26509ef7c95e48902696a, confirmed against the remote on 27 September 2026.

This is the teammate's four-stage game: The Drowned Chart, The Survey, The Hollow and Waking. It uses the actual merged visuals, fonts, textures, music, cave meshes, physical doors and monster. The separate older five-chapter project remains in the parent folder but is not this project's base.

Lore additions use existing lost-ship encounters, three torn pages and connecting interludes. They deepen the expedition and mapping rules without changing the friend's visual rendering or adding incompatible objectives.

The parent RUN_MAP.bat and OPEN_MAP_EDITOR.bat now target this project. Headless and actual-renderer smoke runs each pass 18 checks for save isolation, imports, menu and four chapter instantiations. Renderer captures in qa/ were inspected. Critical visual files were hash-checked against friend/main and remain unchanged. The smoke suite does not establish a completed human run or guarantee a competition result. Test exit retains an ObjectDB/resource cleanup warning; no scene-loading assertions failed.



## Latest game revision — 27 September 2026

Use `merged_game/project.godot` or parent `RUN_MAP.bat`. The supplied animated King opening and island-arrival film are restored. God lore is encountered inside the sea/jungle/cave. Higher-resolution cartographic rendering, ancient stone walls, required cave warning detours, two maze ward stones and a warned lethal Azathoth gate are integrated. The gate uses a live HD detailed stone-idol asset, not the rejected painterly backdrop or a literal complete depiction of Azathoth.

Escape retains the camp waking and final figure, adding an indirect dreamer/flute doubt. Loss animates the cartographer into a wall of the map; the forbidden-gate death also uses this losing story. The friend's original four stages, controls, adaptive soundtrack, keys, ink and chase remain.

Latest verification: 33 revision checks passed; physical gate movement test passed seven checks; all three complete ending sequences reached end cards; extended active-hunter finale bot escaped at 01:31.23. Corrected gate test, latest headless revision, endings and gameplay bot exited 0. Some harness shutdown warnings remain; human balance/performance testing is not certified. See `merged_game/REVISION_NOTES.md` for sources and exact limitations. Earlier sections describe previous states; trailer masters/email copy remain unchanged.

- Final refinement: the active forbidden-idol reveal uses a newly downloaded, verified 4K-textured model with a live 1080p render. Its seven actual-movement gate checks passed again. Intro coroutine scene-removal cancellation is fixed; final story regression passed 43 checks, exit 0. Generated artwork remains an unused reference; no successful photoreal organic-creature edit is claimed.
## Submission-ready reader and folder layout - 27 September 2026

The only active project is `merged_game/project.godot`; local launch is `RUN_MAP.bat`. Level 4 papers now have a Finish reading button, Next/Previous controls and E/Space/Esc dismissal. Gameplay and the timer pause while reading. Final reader regression: 19/19, exit 0; story regression: 43/43, exit 0.

Obsolete game files and original video/trailer deliverables are preserved in the sibling `CS Hackathon Archive 2026-09-27` folder, not permanently deleted. See root CLEANUP.md for recovery and Resolve relinking. Research and revision documents now live in `merged_game/docs` (older historical references reflect their previous locations). The repository is a source submission requiring Godot 4.7, not an exported installer. Git upload status is recorded below once verified.
- Submission upload verified: game commit `ac72467` successfully pushed to `origin/main` at https://github.com/ArvBali2101/Cartographers_dream. Final checks: reader 19/19, story 43/43, four-chapter smoke 26/26; all exit 0. Smoke still reports known resource warnings during teardown. Original media/legacy files remain recoverable in the sibling archive. This note is included in the follow-up handoff commit.
