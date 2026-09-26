# DreamScape project journal

## 2026-09-26 — Project started

- The CS Hackathon folder was empty, so the DreamScape prototype was started as a new web project.
- No `MASTER_NOTES*.pdf` file was present in the project folder. The supplied DreamScape brief is therefore the source brief for this iteration.
- The product direction was narrowed to the core judging moment: a persistent dream world, recurring-place recognition, recurring dream signs, and a live map/replay interaction.
- A Sites-compatible React/Vinext scaffold was initialized with the shadcn add-on.
- The first interface slice was implemented with a dark dreamy cartography visual system and a responsive three-panel layout.
- The prototype currently includes a synthetic Maya demo world, interactive dream text, map update state, map node selection, World/Lucid/Emotion view toggles, dream-sign selection, timeline slider, and replay animation.
- `npm run build` completed successfully and the local route returned HTTP 200 from the dev server.
- The scaffold lint command still reports issues in generated shadcn starter components; the new page’s missing control labels were corrected, but the unused generated component warnings remain outside the prototype scope.
- The validated source was committed and published as a private Sites deployment at `https://dreamscape-cs-hackathon.baliarv21.chatgpt.site`.
- Feedback identified that the first version felt like a dashboard rather than a game. A dedicated Enter Dream mode was added: full-screen world view, keyboard movement, player avatar, HUD instructions, Escape exit, and replay-compatible world navigation.
- The upgraded build completed successfully and the local route returned HTTP 200.

## Current state

- No external AI, database, embeddings, or authentication are wired yet; the current experience is a playable local prototype with deterministic demo data.
- Next likely work: replace demo actions with an extraction API, persist dreams, and add a real world engine while preserving the visual interaction model.

## 2026-09-26 — Final gameplay pass

- Added a cinematic “Last night” entry sequence when the player enters the dream.
- Added player movement trail rendering, proximity detection, discovered-place tracking, and landmark-specific memory prompts.
- Added reactive atmosphere for nearby doors, water, and flight zones, plus a working zoom state and emotion-map background shift.
- The experience now has a complete demo loop: enter dream → move → discover a place → read the memory → leave with a changed world state.
- Build passed and the local route returned HTTP 200 after the gameplay pass.

## 2026-09-26 — Memory interaction fix

- Fixed a gameplay bug where “Open memory” only updated the hidden sidebar while the player was in full-screen mode.
- Added an in-world memory modal with the selected place, visit count, first-seen date, mood, and a continue-exploring action.
- Landmark clicks in game mode now open the same memory modal directly.
- Build passed and the local route returned HTTP 200 after the fix.

## 2026-09-26 — Three-scene product model

- Reframed the product around three explicit views: Tonight’s Dream Scene, Maya’s Lifetime Dreamscape, and The Most Recurring Dream.
- Tonight’s scene now shows the complete route from the current dream as its own contained world.
- Lifetime World remains the continuously growing geography that connects every saved dream.
- Most Recurring Dream is a separate composite scene that gathers the repeated school/corridor/roof/flight pattern into one playable loop.
- Added clear scene navigation, scene-specific landmarks, copy, routes, stats, and gameplay entry points so the product no longer treats all dreams as one undifferentiated map.
- Build passed and the local route returned HTTP 200 after the restructure.
