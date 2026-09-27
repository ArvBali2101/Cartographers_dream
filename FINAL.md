# Cartographer's Dream / MAP — current build

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

The real Godot/OpenGL progression suite passes 88 checks (87 headless), including mouse-look, endurance, required extended objectives, sea alternatives, docking, flare stun, deadline failure, city interiors, cave sealing/readings, key pickup, physical doors, seal detours and surge, map-view movement lock, both endings and local scores. Test saves are isolated from player data. Renderer screenshots are in `qa/expanded/`. A separate live-steering sea test completes all soundings and reaches the wharf in 47.92 simulated seconds under seven active pursuers, using available flares; it does not teleport between objectives.

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
