# DreamScape — current final state

DreamScape is a dark, dreamlike cartography prototype for mapping the persistent world a person visits while sleeping.

## Current experience

- Left panel: write a dream, mark the date/lucid state, and map it.
- Center: an explorable fantasy map with named locations, routes, fog, a “you” marker, timeline, and replay animation.
- Right panel: selected-location history, recurring dream signs, world statistics, and the product principle.
- Interactive states: map update feedback, landmark selection, World/Lucid/Emotion view toggles, dream-sign highlighting, timeline movement, and replay.

## Product decisions

- The prototype uses the fictional demo user Maya and interconnected synthetic dream data.
- It presents recurring concepts as places, landmarks, and routes rather than as a generic graph.
- It does not interpret dreams or make psychological diagnoses.

## Technical state

- React/Vinext site scaffold in `app/`.
- Main experience in `app/page.tsx`.
- Visual system and responsive behavior in `app/globals.css`.
- No external credentials or backend required for the current demo.
