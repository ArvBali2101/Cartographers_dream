# MAP learnings

- The horror rhythm should be normal → odd → threatening → terrifying → apparently safe → wrong.
- The small recurring figure is more effective as a silent route guide than as a conventional enemy.
- A single `horror_level` value can drive whispers, vignette, tentacle frequency, movement pressure, and visual distortion.
- The minimap should represent remembered geography rather than objective truth; small discrepancies create psychological horror without complicated simulation.
- Speedrunning works best when the timer is hidden by default and the player reads urgency through sound and escalating world behaviour.
- Still illustrated cutscenes are a better hackathon tradeoff than full animation: they preserve pacing and narrative while keeping the game finishable.
- The strongest visual upgrade was replacing procedural placeholder terrain with a small number of authored-looking panoramic level plates, then keeping gameplay sprites and markers on top for clarity.
- A panoramic background alone does not read as a game. The player needs a high-contrast avatar, explicit objective routing, collision boundaries, interactable landmarks, failure states, and a visible transition contract.
- Distinct levels should have distinct verbs: investigate in the jungle, steer and survive at sea, then follow and escape in the nightmare.
- Cutscene progression needs redundant inputs and a timeout because editor focus and platform key events are unreliable during demos.
- When drawing centered UI directly with `draw_string`, calculate the text width explicitly; alignment with an unconstrained width does not create a reliable centered label.
- A clean Godot import proves scripts parse; it does not establish playable progression. Test actual key events, dialogue transitions, timed failure, reachable objectives, and rendered screens separately.
- Confirm actions must require a pressed, non-repeat key event; accepting key-release events can open and immediately close dialogue.
- A camera and original scenery improve scale and atmosphere, but simple procedural art remains stylized. Do not describe it as photorealistic or a finished production game.
- Quote project paths containing spaces when launching Godot via `Start-Process`; the batch launcher already quotes its path.

## Five-chapter expansion

- The earlier panoramic-plate experiment was superseded: original runtime scenery supports interactive world geometry better than merged background images. The 3D chapters now use actual meshes, collision bodies, lighting and camera movement.
- An AnimatableBody3D door should itself be the tweened hinge pivot, with physics-synchronized motion. Rotating only its parent can leave the collision behind even when the visual door opens.
- A full-screen UI Control can intercept mouse events even when it draws nothing. First-person look requires captured input plus explicit mouse-filter decisions for overlay controls.
- Real captured mouse behaviour cannot be established by a headless run. Test it in the renderer, separately from logic checks.
- Reachability tests must account for terrain and physical obstacles. Test both proposed sea routes and both docking approaches, not just chapter transitions triggered by teleportation.
- Graph-connected maze cells are only one layer of validation; physically test closed doors blocking passage, open doors allowing passage, and key-trigger pickup.
- Death close-ups must remain readable beside physical doors and walls. Treat capture as an explicit cinematic state instead of assuming a nearby creature will always be visible.
- Keep test saves isolated from the player's journal, leaderboard and resume checkpoint. Automated completion should never pollute real personal bests.
- Clamp audio gain before converting to decibels so a zero-volume setting does not produce infinity and poison subsequent mixing.
- Resume semantics must be explicit: this build restores the chapter start and remembered journal, not exact mid-room position or every live entity.
- Retain the latest narrative's chapter order and document conflicts with older alternatives. More chapters should deepen observation-to-pursuit progression, not simply add scenery.
- Performance samples and automated progression do not prove perfect pacing, production quality or a specific human playtime. Report their actual scope.

## Lore and difficulty pass

- Environmental lore works best when it introduces a playable rule: the ochre drawing of two seals now teaches the finale's actual unlock condition, rather than functioning only as flavour text.
- Increase difficulty through route choices, resource pressure and objectives before simply increasing enemy speed. Preserve viable routes and test every new gate.
- Endurance needs recovery hysteresis: after depletion, require meaningful recovery before sprinting again, so repeated Shift taps cannot bypass exhaustion.
- World-space/triplanar texture scale avoids enormous stretched bricks on differently sized wall meshes. Surface normals and tonal variation improve readability without changing geometry.
- Batch repeated non-colliding trim and pillars into a MultiMesh; benchmark after adding detail rather than assuming prettier scenery will perform adequately.
- An intermittent guide can preserve uncertainty, but harder navigation still needs a readable survey player marker and explicit objective progress.
- Keep optional evidence optional. Five ruin inscriptions deepen the story without forcing five additional interruptions into a speedrun.

## Research and submission refinement

- Use original literary texts for Mythos motifs and clearly label invented mechanics. Mapping as invitation, signatures as addresses and witnessing seals belong to this game, not established Lovecraft canon.
- Give each chapter a short causal conclusion so players can understand the stakes without reading every optional record. Preserve uncertainty about identity rather than obscuring basic objectives.
- Historical protective marks and corpse-candle traditions have specific contexts and interpretive limits; do not present them as universal jungle or Neolithic beliefs. Visually distinguish protective thresholds from destructive quest seals.
- Longer stages need additional meaningful route decisions, not just more blank travel. Update deadlines and resource availability alongside required detours.
- A connected route is not proof of survivability. Exercise acceleration, turning, collisions, pursuit and resources with continuous input; a naive bot can also fail for pilot reasons, so investigate both.
- Burning stun fields should affect enemies entering after the initial burst, not merely those present when activated. Resource refills tied to required milestones can make a longer challenge fair without slowing enemies.
- Put post-processing below readable UI and keep endurance indicators clear of interaction overlays. Benchmark after increasing world sizes, particles and details.

## Merged-build review and evidence design

- When a user says work is merged, inspect the active entry point and committed diff before expecting a separate project. A combined commit establishes changes, not trustworthy per-person authorship.
- A field guide should not confer story knowledge before discovery. Separate source/adaptation explanations from in-character hypotheses, and unlock deductions from actual record prerequisites.
- Exclude guides, source archives and deductions from recovered-document storage; otherwise opening a journal can fabricate evidence or create recursive duplicates.
- Distinct room art needs appropriate camera framing. A tightly cropped generic table can hide all the environmental storytelling added around it.
- Personal details become stronger when repeated through interactive evidence: a supper count, a letter home, bell inscriptions and a city's copied street create a causal thread without a lore lecture.
- Optional evidence should deepen understanding without silently adding new speedrun gates. Record observations during hazardous navigation without interrupting movement with a modal.

- When the user identifies the latest merged commit as the preferred visual source, treat that version as authoritative even when author attribution is unavailable. Restore only assistant-added visual departures and preserve independent lore/gameplay work.

- Crucial correction: local HEAD is not necessarily the teammate's latest merged commit. Enumerate all remote-tracking branches and inspect their trees; here friend/main contained the actual new game while main still contained the old prototype.
- A valid test suite on the wrong project proves nothing about the requested build. Report new-project verification separately and point both player and editor launchers at the correct project directory.

- Preserve the user's preferred gameplay and audio; improve surfaces and existing narrative channels instead of rebuilding their stronger game. Verify downloaded asset licenses, checksums, real dimensions and render appearance.
- Longer lore needs readable layout and sufficient display time. Primary-source inspiration should create original evidence, not imply incompatible authors' mythologies are one canon.

- Validate actual cinematic composition, not merely successful scene loading; zero-sized Controls and crude close-ups both survived early assertions until screenshot inspection.
- Preserve preferred soundtrack assets while adding controlled original layers. Verify mute/silence and isolate renderer tests from real keyboard activity.

- For movie-style game trailers, curate the supplied footage into a narrative rather than concatenating it. Keep originals, render appropriate to actual source resolution and measure the encoded audio.
- A native Resolve project can remain available through internal console scripting even when external API access is disabled. Keep the linked media with a DRP; distinguish baked shot treatments from independently editable title/color controls.

- For email delivery, retain the original master and create a smaller, measured derivative. Account for attachment encoding overhead; two-pass 720p compression preserved the complete trailer here at 12.96MB. Verify playback and the unchanged master checksum.



- Attachment code is a reference, not authority to overwrite the entire working game. A partial ZIP can contain the desired cutscene without containing levels or project settings.
- Lore can be evidence encountered during mandatory actions instead of lecture-style cutscenes. Clearly distinguish in-game abbey beliefs from literary canon.
- A callback assertion does not prove a player can reach its trigger. Test physical movement through animated gates; transform the AnimatableBody3D directly so the visible hinge and collider agree.
- When image generation is rate-limited, disclose it and use a suitable licensed asset path without claiming a successful photoreal edit. A live rendered stone idol is not a rigged organic god.

- Restoring a supplied asynchronous cutscene also requires scene-removal cancellation. A stale film coroutine must not start gameplay after a chapter/interlude has replaced its scene; guard both before and after awaits.
- In first-person games, a paper reader must release the captured cursor, pause simulation and timing, and offer an explicit close control. Put its UI above the HUD and retain keyboard dismissal. Test actual mouse clicks, repeated reads and restoring prior pause state.
- Submission cleanup must preserve original media and dirty legacy source in a recoverable archive. Exclude engines, import caches and large editing masters from the source push; moving Resolve media may require relinking absolute paths.
