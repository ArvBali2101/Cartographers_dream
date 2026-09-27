# Merged-build review

## Correction — actual teammate merge located

The previous comparison used the wrong ref. The teammate's actual project is **friend/main at 66af3c3, merged**, and the remote confirms it is current. Local main at 3a7584a is a separate older project, not the teammate's visual integration. The four-chapter friend source has now been imported into merged_game/ intact; primary launchers point there. Its own fonts, theme, nautical/jungle renderers, cave meshes, textures and music replace the mistaken prototype as the primary game. Earlier review sections below are historical and do not describe the active friend build.

## Latest visual decision

The user subsequently confirmed that the latest merged version is the desired visual source. Commit 3a7584a is therefore the authoritative visual base. The city-room composition/camera experiment described below was removed; merged room drawing, palette, camera scale and presentation are restored. Existing world artwork, shaders and all 3D visual files remain unchanged from that commit. The personal lore and evidence-browser changes are retained. The sections below also document the superseded experiment; they are not a claim that those new room visuals remain active.

## What was actually reviewed

The latest committed integration is `3a7584a`. Compared with its parent, it adds the modular five-chapter implementation and changes Main.tscn from the old main.gd entry point to scripts/game.gd. The working tree was clean before this review except for the journal entry from the preceding inspection. There is no reliable per-person attribution in this combined commit: this review assesses the merged game, not which teammate deserves credit for a particular file.

The previous inspection incorrectly treated a separate teammate directory as necessary. The current scenes, scripts, committed diff, chapter transitions, tests and actual renderer captures have now been reviewed directly.

## Strongest existing elements retained

- The merged architecture is materially stronger than the earlier three-stage prototype: five distinct chapters, actual first-person cave/maze geometry, reusable hinged doors, persistent records and separate endings.
- The map changes from a document into navigable space. Terrain, sea bearings and the finale's two signatures/key support that idea through mechanics.
- Stable geography, hidden timer, limited endurance and flares support replayable route choices without making the first run a permanent dashboard.
- The unnamed figure, the camp returning in impossible places and the apparently ordinary morning are the strongest recurring narrative images. Explaining the figure's identity would weaken them.

## Weaknesses addressed in this pass

1. City interiors used almost the same floor/table composition. They now have distinct layouts and evidence: twelve bed places and a route to home, censored charts, thirteen cups, projection seats and an occupied seat after examination, and protective threshold marks. The room camera frames the composition rather than tightly cropping a generic table.
2. Evidence was a long concatenated journal. F1 now opens an indexed record browser, with discovered connections above the recovered documents. A selected record returns to the index when closed.
3. F3 previously supplied chapter summaries and full adaptation context before discoveries justified that knowledge. It now presents earned working hypotheses, while out-of-world source information remains in the menu archive.
4. Expedition members lacked a human stake. Morrow's optional letter to Nell mentions Ada, the extra place at supper and the little house on the departure map. Later bells, the wreck log and the city connect those details without settling who the figure is.
5. Sea evidence lacked clear affordances. The wreck log now has an interaction prompt; passing bells automatically records observations without opening a modal during pursuit.
6. Archive/guide screens could add themselves to the field journal. These views and inferred connections no longer create fake recovered evidence or recursively duplicate records.

## Lore structure

The player can connect five hypotheses only after recovering their prerequisites:

- Morrow's letter + Survey I: an extra place rather than a conventional missing traveller.
- Survey II + the archive: deliberate omission as defence.
- Morrow's letter + the house: the expedition's home is being added as a destination.
- Bell III + the wreck log: charting may choose a reachable shore, not simply predict it.
- Murals III + IV: the physical lock and supernatural witnessing signatures are separate obstacles.

These are original fictional deductions, not new factual claims about Lovecraft canon. RESEARCH.md remains the source/adaptation reference. The figure's identity and whether the final escape is truly safe remain unanswered.

## Verification and honest limits

The updated suite passes 100 headless checks and 101 with the real renderer. Screenshots include the new journal and five room compositions. A separate continuous-input sea test still reaches the wharf under seven pursuers in approximately 48 simulated seconds; it does not teleport between bearings.

Some headless teardown runs report an ObjectDB cleanup warning, as prior runs did. No failed assertions or gameplay runtime errors were observed in these suites. This is not a fresh-player full-run test. The decorative furniture is non-colliding, the art remains procedural/stylized, and the sound is synthesized. Recorded performances, a production art pass and a competition win are not established by these tests.
