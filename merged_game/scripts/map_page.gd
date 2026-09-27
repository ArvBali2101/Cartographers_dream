@tool
extends Node3D
## A torn page lying on the floor. Look at it and interact to read it.

const TEXTS := [
	"A page from your own journal — but the hand is not yours:\n\n“The light is to the north. It always was.”\n\nBelow it, E. Vane has written: I drew these corridors to remember the way out. The ink learned the way back to me. Leave the centre blank. Never add the street where you live.",
	"A scrap of map. The corridors drawn on it do not match these ones.\nAs you watch, one of the ink lines moves.\n\nThree sketches: iron, stone, black. The first opens a route; the second lends a guide; the last wakes what guards the exit. The little lights are not all going the same way. Follow the one that waits.",
	"Your handwriting, shaking badly:\n\n“Do not let it see you stop.”\n\nWhen the hunter loses a trail, it listens. Running and doors tell it more than footsteps. A map has no sound, but my name on its margin does.\n\nA final line: the Door of Light keeps it inside. That does not mean the drawing is safe to take home.",
]

## Original field notes: evidence, not an authoritative explanation of the gods.
const POSTSCRIPTS := [
	"\n\nSurvey ledger, 17 October:\nThree sailors in separate cabins dreamed the same drowned staircase. Each drew the same missing step. None had seen the other's sheet. Harrow ordered the drawings burned. In the morning the ash lay in the shape of a coastline.\n\nI no longer believe we discovered the island. Something supplied the bearings.",
	"\n\nPressed beneath the scrap is a leaf, grey on one side, purple on the other. No pigment in my case matches it. The trees above the cave have leaves like this. The guide refused to name their colour.\n\nThe old painters left every path unfinished at the circle. We filled the gap. A map connects two places in both directions.",
	"\n\nVane's final entry:\nThe little figure is on the oldest painting. It is also in the margin of my childhood atlas. I cannot remember drawing it.\n\nI crossed the threshold and heard the birds at home. Then I heard the sea behind them. Escape is a distance. It is not forgetting.\n\nDo not publish this sheet. Do not give it an address.",
]

signal was_read(page: Node)

const GOD_NOTES := [
	"VANE'S INDEX: NYARLATHOTEP\nThe Crawling Chaos; messenger of the Outer Gods. He speaks, persuades, and gives a terrible choice the appearance of a free one. I cannot prove the small figure is his. I cannot prove it is not.\n\nCTHULHU lies beneath the drowned chart. A Great Old One, not an Outer God. Do not mistake the sleeper for the hand arranging our route.",
	"VANE'S INDEX: YOG-SOTHOTH\nThe gate and the key. The oldest notes speak of a presence outside our divisions of time and place. My theory: the chart is a threshold, not a record. Completing a route may let the other end reach us.\n\nSHUB-NIGGURATH appears in another margin, beside branching roots and impossible births. That name does not identify every strange leaf. I refuse to turn guesses into bearings.",
	"VANE'S INDEX: AZATHOTH\nThe blind centre of ultimate chaos. I have drawn only the edge of a shape; even that is too much. The hunter in these halls is not Azathoth. Killing a body could not undo what the chart connects.\n\nNyarlathotep gave us directions. Yog-Sothoth made distance meaningless. The name at the centre must never become a destination. Find the light. Leave the last line unfinished.",
]

var index := 0
var read := false


func _ready() -> void:
	var mi := MeshInstance3D.new()
	var pm := PlaneMesh.new()
	pm.size = Vector2(0.32, 0.42)
	mi.mesh = pm
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.86, 0.8, 0.64)
	mat.emission_enabled = true
	mat.emission = Color(0.35, 0.32, 0.25)
	mat.roughness = 1.0
	mi.material_override = mat
	mi.rotation.y = randf() * TAU
	mi.position.y = 0.012
	add_child(mi)
	var body := StaticBody3D.new()
	body.collision_layer = 2          # the look-ray sees it; feet don't
	body.collision_mask = 0
	body.set_meta("interact_target", self)
	var cs := CollisionShape3D.new()
	var bs := BoxShape3D.new()
	bs.size = Vector3(0.6, 0.3, 0.6)
	cs.shape = bs
	cs.position.y = 0.15
	body.add_child(cs)
	add_child(body)


func prompt() -> String:
	return "read the page"


func interact(_from: Vector3) -> void:
	if not read:
		read = true
		was_read.emit(self)
	var music := get_node_or_null("/root/Music")   # (tool script: no autoload names)
	if music:
		music.sfx("page", 0.9)
	for o in get_tree().get_nodes_in_group("fps_overlay"):
		o.show_page(TEXTS[index % TEXTS.size()] + "\n\n---\n\n" + POSTSCRIPTS[index % POSTSCRIPTS.size()] + "\n\n---\n\n" + GOD_NOTES[index % GOD_NOTES.size()])
