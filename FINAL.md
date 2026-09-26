# DreamScape — current final state

DreamScape is a dark, dreamlike cartography prototype for saving dreams as scenes, connecting them into a lifetime world, and isolating the dream that returns most often.

## Current experience

- Left panel: write a dream, mark the date/lucid state, and map it.
- Center: an explorable fantasy map with named locations, routes, fog, a “you” marker, timeline, replay animation, and a full-screen playable mode.
- Right panel: selected-location history, recurring dream signs, world statistics, and the product principle.
- Interactive states: map update feedback, landmark selection, World/Lucid/Emotion view toggles, dream-sign highlighting, timeline movement, and replay.
- Play mode: select “Enter dream,” move Maya with WASD/arrow keys, hold Shift to move faster, click landmarks, and press Esc to exit.
- Gameplay pass: entering the dream opens a short cinematic intro, movement leaves a glowing trail, nearby landmarks trigger memory cards, and the world atmosphere reacts to doors, water, and flight zones.
- Memory interaction: “Open memory” and in-world landmark clicks open a focused memory modal without leaving the playable world.
- Three-scene model: Tonight’s Dream Scene, Lifetime World, and Most Recurring Dream are separate views with distinct map data and narrative purpose.

## Product decisions

- The prototype uses the fictional demo user Maya and interconnected synthetic dream data.
- It presents recurring concepts as places, landmarks, and routes rather than as a generic graph.
- It does not interpret dreams or make psychological diagnoses.

## Technical state

- React/Vinext site scaffold in `app/`.
- Main experience in `app/page.tsx`.
- Visual system and responsive behavior in `app/globals.css`.
- No external credentials or backend required for the current demo.
- The current demo is intentionally deterministic and self-contained; it is ready for a live hackathon presentation without credentials.

## Published demo

Private live demo: https://dreamscape-cs-hackathon.baliarv21.chatgpt.site
- Cinematic scene layer: each view now has its own full-screen dream artwork. Tonight shows a complete journey, Lifetime shows the expanding world, and Most Recurring shows the repeating school/corridor/flight sequence.
- Scene artwork lives in `public/scenes/daily.png`, `public/scenes/lifetime.png`, and `public/scenes/recurring.png`.
