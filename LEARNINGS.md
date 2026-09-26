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
