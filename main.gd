extends Node2D

## MAP - a compact, complete 2D top-down horror game.
## Three distinct playable levels: jungle investigation, sea escape, nightmare maze.

enum State { MENU, INTRO, JUNGLE, CUT_ONE, SEA, CUT_TWO, NIGHTMARE, ENDING, STING }

const SIZE := Vector2(1280.0, 720.0)
const PLAY_RECT := Rect2(54.0, 96.0, 1172.0, 560.0)
const INK := Color("#16151a")
const PAPER := Color("#d9c7a1")
const GOLD := Color("#d9a75e")
const RED := Color("#9b3b43")

var state: State = State.MENU
var menu_index := 0
var timer_visible := false
var settings_open := false
var cut_index := 0
var cut_elapsed := 0.0
var run_time := 0.0
var level_time := 0.0
var screen_time := 0.0
var flash := 0.0
var death_label := ""
var death_timer := 0.0
var dialogue_title := ""
var dialogue_text := ""
var dialogue_open := false

var player := Vector2(130, 570)
var ship := Vector2(130, 560)
var nightmare_player := Vector2(130, 570)
var figure := Vector2(1040, 160)
var witness := Vector2(-500, -500)
var figure_step := 0
var jungle_records := 0
var jungle_record_iv_seen := false
var sea_horror := 0.0
var sea_hazard_clock := 0.0

func _ready() -> void:
	queue_redraw()

func _process(delta: float) -> void:
	screen_time += delta
	flash = maxf(0.0, flash - delta * 2.0)
	death_timer = maxf(0.0, death_timer - delta)
	if state in [State.INTRO, State.CUT_ONE, State.CUT_TWO]:
		cut_elapsed += delta
		if cut_elapsed > 18.0:
			advance_cutscene()
	if state in [State.JUNGLE, State.SEA, State.NIGHTMARE] and not dialogue_open:
		run_time += delta
		level_time += delta
		if state == State.JUNGLE: update_jungle(delta)
		elif state == State.SEA: update_sea(delta)
		else: update_nightmare(delta)
	queue_redraw()

func _input(event: InputEvent) -> void:
	if dialogue_open:
		if is_confirm(event): close_dialogue()
		return
	if event is InputEventMouseButton and event.pressed:
		if state == State.MENU and not settings_open: start_expedition()
		elif state in [State.INTRO, State.CUT_ONE, State.CUT_TWO]: advance_cutscene()
		elif state == State.JUNGLE: interact_jungle()
		elif state == State.SEA: interact_sea()
		elif state == State.ENDING:
			state = State.STING
			cut_elapsed = 0.0
		return
	if event is not InputEventKey or not event.pressed or event.echo: return
	if event.keycode == KEY_ESCAPE:
		state = State.MENU
		settings_open = false
		dialogue_open = false
		return
	if state == State.MENU: handle_menu(event)
	elif state in [State.INTRO, State.CUT_ONE, State.CUT_TWO] and is_confirm(event): advance_cutscene()
	elif state == State.JUNGLE:
		if is_confirm(event): interact_jungle()
		elif event.keycode == KEY_R: start_jungle()
	elif state == State.SEA:
		if is_confirm(event): interact_sea()
		elif event.keycode == KEY_R: start_sea()
	elif state == State.NIGHTMARE and event.keycode == KEY_R: start_nightmare()
	elif state == State.ENDING and is_confirm(event):
		state = State.STING
		cut_elapsed = 0.0
	elif state == State.STING and is_confirm(event): state = State.MENU
	elif event.keycode == KEY_F2: timer_visible = not timer_visible

func is_confirm(event: InputEvent) -> bool:
	if event is InputEventMouseButton: return event.pressed
	if event is InputEventKey: return event.keycode in [KEY_E, KEY_SPACE, KEY_ENTER] or event.physical_keycode in [KEY_E, KEY_SPACE, KEY_ENTER]
	return false

func handle_menu(event: InputEventKey) -> void:
	if settings_open:
		if event.keycode in [KEY_ESCAPE, KEY_BACKSPACE]: settings_open = false
		elif event.keycode == KEY_ENTER: timer_visible = not timer_visible
		return
	if event.keycode in [KEY_UP, KEY_W]: menu_index = max(0, menu_index - 1)
	elif event.keycode in [KEY_DOWN, KEY_S]: menu_index = min(2, menu_index + 1)
	elif is_confirm(event):
		if menu_index == 0: start_expedition()
		elif menu_index == 1: settings_open = true
		else: get_tree().quit()

func start_expedition() -> void:
	state = State.INTRO
	cut_index = 0
	cut_elapsed = 0.0
	run_time = 0.0

func advance_cutscene() -> void:
	cut_index += 1
	cut_elapsed = 0.0
	if state == State.INTRO and cut_index >= 7: start_jungle()
	elif state == State.CUT_ONE and cut_index >= 3: start_sea()
	elif state == State.CUT_TWO and cut_index >= 3: start_nightmare()

func start_jungle() -> void:
	state = State.JUNGLE
	player = Vector2(130, 570)
	level_time = 0.0
	jungle_records = 0
	jungle_record_iv_seen = false
	dialogue_open = false

func start_sea() -> void:
	state = State.SEA
	ship = Vector2(130, 560)
	level_time = 0.0
	sea_horror = 0.0
	sea_hazard_clock = 0.0
	dialogue_open = false

func start_nightmare() -> void:
	state = State.NIGHTMARE
	nightmare_player = Vector2(130, 570)
	figure = Vector2(1040, 160)
	witness = Vector2(-500, -500)
	figure_step = 0
	level_time = 0.0
	dialogue_open = false

func direction_input() -> Vector2:
	var d := Vector2.ZERO
	if Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT): d.x -= 1.0
	if Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT): d.x += 1.0
	if Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP): d.y -= 1.0
	if Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN): d.y += 1.0
	return d.normalized()

func move_with_walls(pos: Vector2, direction: Vector2, speed: float, walls: Array[Rect2], delta: float) -> Vector2:
	var next := pos + direction * speed * delta
	next.x = clampf(next.x, PLAY_RECT.position.x + 14.0, PLAY_RECT.end.x - 14.0)
	next.y = clampf(next.y, PLAY_RECT.position.y + 14.0, PLAY_RECT.end.y - 14.0)
	for wall in walls:
		if wall.grow(13.0).has_point(next): return pos
	return next

func jungle_walls() -> Array[Rect2]:
	return [Rect2(370, 96, 32, 170), Rect2(370, 390, 32, 266), Rect2(690, 96, 32, 170), Rect2(690, 390, 32, 266)]

func update_jungle(delta: float) -> void:
	var speed := 155.0 if not Input.is_key_pressed(KEY_SHIFT) else 235.0
	player = move_with_walls(player, direction_input(), speed, jungle_walls(), delta)
	if player.distance_to(figure) < 90.0:
		figure += Vector2(115, sin(screen_time * 2.0) * 20.0) * delta
		if figure.x > 1140: figure = Vector2(980, 210)
	if level_time > 32.0: figure = Vector2(835, 355)

func interact_jungle() -> void:
	if player.distance_to(Vector2(250, 485)) < 70.0:
		jungle_records = max(jungle_records, 1)
		show_dialogue("EXPEDITION I", "NORTH SURVEY\nThe paper is dry. The ink is fresh.\n\nThere should be no expedition before ours.")
	elif player.distance_to(Vector2(545, 230)) < 70.0:
		jungle_records = max(jungle_records, 2)
		show_dialogue("EXPEDITION II", "NO RECORD\nA second marker, older than the camp.\n\nThe route on your map is wrong by thirty paces.")
	elif player.distance_to(Vector2(840, 420)) < 70.0:
		jungle_record_iv_seen = true
		show_dialogue("EXPEDITION IV", "DON'T FOLLOW IT\nThe words were not there when you first looked.\n\nWhere is Expedition III?")
	elif player.distance_to(Vector2(1090, 160)) < 78.0 and jungle_records >= 2:
		show_dialogue("SURVEY COMPLETE", "The normal level-complete sound begins.\nIt stops halfway.\n\nA second player marker appears on the remembered map.")

func update_sea(delta: float) -> void:
	var speed := 210.0 if not Input.is_key_pressed(KEY_SHIFT) else 285.0
	ship = move_with_walls(ship, direction_input(), speed, [], delta)
	sea_horror = clampf(level_time / 115.0, 0.0, 1.0)
	sea_hazard_clock += delta
	if sea_hazard_clock > 2.4:
		sea_hazard_clock = 0.0
		if ship.distance_to(Vector2(720, 220)) < 90.0 or ship.distance_to(Vector2(530, 500)) < 78.0:
			register_death("DROWNED")
			start_sea()

func interact_sea() -> void:
	if ship.distance_to(Vector2(340, 230)) < 90.0: show_dialogue("BONE ISLAND", "The bones are too large for any animal you know.\n\nSomething has been walking on this island.")
	elif ship.distance_to(Vector2(690, 480)) < 95.0: show_dialogue("WRECK", "The expedition symbol is carved into the mast.\n\nThe wood is older than the expedition.")
	elif ship.distance_to(Vector2(1100, 175)) < 95.0: show_dialogue("LIGHTHOUSE", "The water becomes completely still.\nThe whispers stop.\n\nA voice beneath the lighthouse asks: do you want to leave?")

func nightmare_walls() -> Array[Rect2]:
	return [Rect2(270, 120, 35, 210), Rect2(270, 420, 35, 220), Rect2(470, 270, 270, 35), Rect2(470, 270, 35, 150), Rect2(825, 100, 35, 235), Rect2(825, 440, 35, 210), Rect2(1030, 270, 35, 230), Rect2(590, 520, 270, 35)]

func update_nightmare(delta: float) -> void:
	nightmare_player = move_with_walls(nightmare_player, direction_input(), 185.0, nightmare_walls(), delta)
	var route := [Vector2(420, 170), Vector2(650, 175), Vector2(930, 390), Vector2(1100, 175)]
	if nightmare_player.distance_to(figure) < 72.0 and figure_step < route.size():
		figure_step += 1
		figure = route[min(figure_step, route.size() - 1)]
	if figure_step >= 1 and witness.x < -100.0: witness = Vector2(1110, 610)
	if witness.x > -100.0:
		witness = witness.move_toward(nightmare_player, delta * 105.0)
		if witness.distance_to(nightmare_player) < 28.0:
			register_death("SEEN")
			start_nightmare()
	if nightmare_player.distance_to(Vector2(1110, 160)) < 60.0 and figure_step >= 2:
		state = State.ENDING
		cut_elapsed = 0.0

func show_dialogue(title: String, text: String) -> void:
	dialogue_title = title
	dialogue_text = text
	dialogue_open = true

func close_dialogue() -> void:
	var title := dialogue_title
	dialogue_open = false
	if title == "SURVEY COMPLETE": start_cut_one()
	elif title == "LIGHTHOUSE": start_cut_two()

func start_cut_one() -> void:
	state = State.CUT_ONE
	cut_index = 0
	cut_elapsed = 0.0

func start_cut_two() -> void:
	state = State.CUT_TWO
	cut_index = 0
	cut_elapsed = 0.0

func register_death(label: String) -> void:
	death_label = label
	death_timer = 1.5
	flash = 0.9

func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, SIZE), Color("#09090b"))
	match state:
		State.MENU: draw_menu()
		State.INTRO: draw_cutscene(["For centuries, this region remained blank.", "No reliable map existed.", "That was why I came.", "On the second night, we stopped.", "The others slept.", "I continued drawing.", "I don't remember falling asleep."])
		State.JUNGLE: draw_jungle()
		State.CUT_ONE: draw_cutscene(["The line was not mine.", "Something had noticed the map.", "The ink ran toward the sea."])
		State.SEA: draw_sea()
		State.CUT_TWO: draw_cutscene(["Do you want to leave?", "Then wake up.", "You can't. He has seen you."])
		State.NIGHTMARE: draw_nightmare()
		State.ENDING: draw_ending()
		State.STING: draw_sting()
	if dialogue_open: draw_dialogue()
	if death_timer > 0.0:
		draw_rect(Rect2(Vector2.ZERO, SIZE), Color(0.08, 0.0, 0.0, 0.34))
		draw_center(death_label, Vector2(640, 370), 34, PAPER)
	if flash > 0.0: draw_rect(Rect2(Vector2.ZERO, SIZE), Color(1, 1, 1, flash * 0.16))

func draw_menu() -> void:
	draw_rect(Rect2(Vector2.ZERO, SIZE), Color("#111318"))
	for x in range(0, 1280, 64): draw_line(Vector2(x, 90), Vector2(x - 90, 720), Color(0.24, 0.28, 0.28, 0.18), 1.0)
	for y in range(110, 720, 48): draw_line(Vector2(0, y), Vector2(1280, y - 150), Color(0.24, 0.28, 0.28, 0.15), 1.0)
	draw_circle(Vector2(930, 220), 150, Color(0.10, 0.20, 0.20, 0.55))
	draw_circle(Vector2(930, 220), 100, Color(0.08, 0.12, 0.15, 0.7))
	draw_center("MAP", Vector2(640, 235), 96, Color("#ead7ac"))
	draw_center("AN EXPEDITION INTO THE UNKNOWN", Vector2(640, 286), 14, Color("#9f927a"))
	draw_line(Vector2(430, 314), Vector2(850, 314), Color(0.8, 0.65, 0.38, 0.55), 1.0)
	var options := ["BEGIN EXPEDITION", "SETTINGS", "QUIT"]
	for i in options.size():
		var c := PAPER if i == menu_index else Color("#655f58")
		draw_string(ThemeDB.fallback_font, Vector2(520, 405 + i * 50), ("> " if i == menu_index else "  ") + options[i], HORIZONTAL_ALIGNMENT_LEFT, -1, 18, c)
	draw_center("WASD / ARROWS SELECT     ENTER OR CLICK CONFIRM", Vector2(640, 640), 11, Color("#b9aa8b"))
	if settings_open:
		draw_rect(Rect2(350, 145, 580, 380), Color("#17191e"), true)
		draw_rect(Rect2(350, 145, 580, 380), Color("#a98d5e"), false, 2.0)
		draw_center("SETTINGS", Vector2(640, 215), 28, PAPER)
		draw_string(ThemeDB.fallback_font, Vector2(430, 290), "SHOW SPEEDRUN TIMER     " + ("ON" if timer_visible else "OFF"), HORIZONTAL_ALIGNMENT_LEFT, -1, 16, PAPER)
		draw_string(ThemeDB.fallback_font, Vector2(430, 340), "ENTER toggles timer", HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color("#9c917e"))
		draw_string(ThemeDB.fallback_font, Vector2(430, 470), "ESC closes settings", HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color("#9c917e"))

func draw_cutscene(lines: Array[String]) -> void:
	draw_rect(Rect2(Vector2.ZERO, SIZE), Color("#0b0d10"))
	var frame := Rect2(150, 75, 980, 455)
	draw_rect(frame, Color("#191d22"), true)
	draw_rect(frame, Color("#8e7753"), false, 2.0)
	var panel := cut_index if state == State.INTRO else cut_index + 7
	if panel % 3 == 0: draw_cut_jungle(frame)
	elif panel % 3 == 1: draw_cut_transition(frame)
	else: draw_cut_reveal(frame)
	draw_center(lines[min(cut_index, lines.size() - 1)], Vector2(640, 585), 22, PAPER)
	draw_center("CLICK ANYWHERE  /  E  /  SPACE  CONTINUE", Vector2(640, 640), 11, Color("#bbaa87"))

func draw_cut_jungle(frame: Rect2) -> void:
	draw_rect(frame, Color("#25362a"), true)
	for i in range(18):
		var p := Vector2(190 + (i * 97) % 900, 110 + (i * 61) % 360)
		draw_circle(p, 34, Color("#15251d"))
		draw_circle(p + Vector2(10, -8), 20, Color("#47604a"))
		draw_line(p, p + Vector2(0, 35), Color("#8b6546"), 4)
	draw_line(Vector2(180, 445), Vector2(1070, 125), Color("#cfad72"), 5)
	draw_circle(Vector2(640, 290), 35, Color("#e19b59"))

func draw_cut_transition(frame: Rect2) -> void:
	draw_rect(frame, Color("#172a33"), true)
	for i in range(9): draw_circle(Vector2(200 + i * 105, 230 + sin(i) * 80), 55 + i * 3, Color(0.1, 0.25, 0.3, 0.62))
	draw_line(Vector2(180, 420), Vector2(1080, 160), Color("#bea16d"), 2)
	draw_circle(Vector2(830, 270), 18, Color("#dfb35f"))
	draw_string(ThemeDB.fallback_font, Vector2(770, 325), "THE LINE CONTINUES", HORIZONTAL_ALIGNMENT_LEFT, -1, 14, PAPER)

func draw_cut_reveal(frame: Rect2) -> void:
	draw_rect(frame, Color("#190f1c"), true)
	for i in range(7):
		draw_circle(Vector2(300 + i * 110, 270 + sin(i * 2.0) * 50), 44, Color(0.18, 0.04, 0.17, 0.8))
		draw_circle(Vector2(300 + i * 110, 270 + sin(i * 2.0) * 50), 12, Color("#ba394a"))
	draw_center("THE MAP IS OPEN", Vector2(640, 435), 16, Color("#d37b76"))

func draw_jungle() -> void:
	draw_rect(PLAY_RECT, Color("#27402e"), true)
	draw_rect(Rect2(54, 340, 1172, 100), Color("#354d55"), true)
	draw_line(Vector2(54, 340), Vector2(1226, 340), Color("#7d9b95"), 3)
	draw_line(Vector2(54, 440), Vector2(1226, 440), Color("#7d9b95"), 3)
	for wall in jungle_walls(): draw_rect(wall, Color("#18241b"), true)
	for i in range(30):
		var p := Vector2(70 + (i * 113) % 1120, 115 + (i * 73) % 520)
		draw_circle(p, 12, Color("#192c21"))
		draw_circle(p + Vector2(7, -5), 7, Color("#597251"))
	draw_marker(Vector2(250, 485), "EXPEDITION I", "NORTH SURVEY")
	draw_marker(Vector2(545, 230), "EXPEDITION II", "NO RECORD")
	draw_marker(Vector2(840, 420), "EXPEDITION IV", "DON'T FOLLOW IT" if jungle_record_iv_seen else "DO NOT CONTINUE")
	draw_marker(Vector2(1090, 160), "SURVEY", "EXIT")
	draw_figure(figure)
	draw_player(player, Color("#c79f6c"))
	var objective := Vector2(250, 485) if jungle_records < 1 else Vector2(545, 230) if jungle_records < 2 else Vector2(1090, 160)
	draw_arrow(player, objective)
	draw_hud("THE MAP / JUNGLE", "Investigate the expedition records. Complete the survey.")
	if near(player, Vector2(250, 485), 70): draw_prompt("E / SPACE  EXAMINE EXPEDITION I")
	elif near(player, Vector2(545, 230), 70): draw_prompt("E / SPACE  EXAMINE EXPEDITION II")
	elif near(player, Vector2(840, 420), 70): draw_prompt("E / SPACE  EXAMINE EXPEDITION IV")
	elif near(player, Vector2(1090, 160), 78) and jungle_records >= 2: draw_prompt("E / SPACE  COMPLETE SURVEY")
	draw_center("R RESTART LEVEL", Vector2(1080, 684), 10, Color("#998d79"))

func draw_sea() -> void:
	draw_rect(PLAY_RECT, Color("#0d3340"), true)
	for i in range(18): draw_line(Vector2(70 + (i % 3) * 22, 120 + i * 29), Vector2(1210 - (i % 4) * 22, 130 + i * 29), Color(0.3, 0.56, 0.59, 0.3), 2)
	draw_island(Vector2(340, 230), 74, "BONE ISLAND")
	draw_island(Vector2(690, 480), 82, "WRECK")
	draw_island(Vector2(1100, 175), 62, "LIGHTHOUSE")
	draw_circle(Vector2(720, 220), 34 + sin(screen_time * 3.0) * 5.0, Color(0.02, 0.02, 0.04, 0.85))
	draw_circle(Vector2(530, 500), 24 + sin(screen_time * 4.0) * 4.0, Color(0.02, 0.02, 0.04, 0.8))
	for i in range(int(sea_horror * 7.0)): draw_arc(Vector2(160 + i * 150, 620 - (i % 3) * 160), 65, 3.2, 5.9, 24, Color(0.04, 0.02, 0.05, 0.9), 10)
	draw_ship(ship)
	draw_arrow(ship, Vector2(1100, 175))
	draw_hud("THE DROWNED MAP / SEA", "Reach the lighthouse before the water notices you.")
	if near(ship, Vector2(340, 230), 90): draw_prompt("E / SPACE  EXAMINE BONE ISLAND")
	elif near(ship, Vector2(690, 480), 95): draw_prompt("E / SPACE  EXAMINE WRECK")
	elif near(ship, Vector2(1100, 175), 95): draw_prompt("E / SPACE  ENTER LIGHTHOUSE")
	draw_string(ThemeDB.fallback_font, Vector2(1050, 108), "WHISPERS", HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color("#a8d0c4"))
	draw_rect(Rect2(1050, 120, 130, 8), Color("#09171d"), true)
	draw_rect(Rect2(1050, 120, 130 * sea_horror, 8), Color("#a64952"), true)
	draw_center("R RESTART", Vector2(1080, 684), 10, Color("#998d79"))

func draw_nightmare() -> void:
	draw_rect(PLAY_RECT, Color("#260f25"), true)
	for wall in nightmare_walls():
		draw_rect(wall, Color("#09070c"), true)
		draw_rect(wall.grow(5), Color(0.42, 0.05, 0.17, 0.5), false, 2)
	for i in range(9):
		draw_circle(Vector2(130 + i * 130, 145 + (i % 3) * 170), 14, Color("#822d55"))
		draw_circle(Vector2(130 + i * 130, 145 + (i % 3) * 170), 5, Color("#e6b264"))
	draw_figure(figure)
	if witness.x > -100: draw_circle(witness, 30 + sin(screen_time * 5.0) * 8.0, Color(0.02, 0.0, 0.03, 0.95))
	draw_player(nightmare_player, Color("#ead09b"))
	draw_arrow(nightmare_player, Vector2(1110, 160))
	draw_marker(Vector2(1110, 160), "WAKE", "EXIT")
	draw_hud("THE LAST MAP / NIGHTMARE", "Follow the figure. Reach the door. Do not look back.")
	draw_center("R RESTART", Vector2(1080, 684), 10, Color("#998d79"))

func draw_hud(title: String, subtitle: String) -> void:
	draw_rect(Rect2(0, 0, 1280, 78), Color(0.035, 0.035, 0.05, 0.96), true)
	draw_line(Vector2(24, 66), Vector2(1256, 66), Color(0.75, 0.56, 0.3, 0.5), 1)
	draw_string(ThemeDB.fallback_font, Vector2(28, 30), "MAP", HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color("#a9956d"))
	draw_string(ThemeDB.fallback_font, Vector2(28, 54), title, HORIZONTAL_ALIGNMENT_LEFT, -1, 19, PAPER)
	draw_string(ThemeDB.fallback_font, Vector2(320, 52), subtitle, HORIZONTAL_ALIGNMENT_LEFT, 610, 12, Color("#aaa08d"))
	if timer_visible: draw_string(ThemeDB.fallback_font, Vector2(1100, 44), format_time(run_time), HORIZONTAL_ALIGNMENT_LEFT, -1, 16, GOLD)
	draw_rect(Rect2(24, 612, 315, 36), Color(0.04, 0.035, 0.04, 0.9), true)
	draw_string(ThemeDB.fallback_font, Vector2(39, 635), "WASD MOVE   SHIFT RUN   E / SPACE INTERACT", HORIZONTAL_ALIGNMENT_LEFT, -1, 10, PAPER)

func draw_prompt(text: String) -> void:
	draw_rect(Rect2(355, 612, 570, 36), Color(0.04, 0.035, 0.04, 0.95), true)
	draw_rect(Rect2(355, 612, 570, 36), Color(0.82, 0.62, 0.33, 0.55), false, 1)
	draw_center(text, Vector2(640, 636), 12, PAPER)

func draw_dialogue() -> void:
	draw_rect(Rect2(Vector2.ZERO, SIZE), Color(0.01, 0.01, 0.02, 0.5))
	draw_rect(Rect2(180, 405, 920, 220), Color("#141319"), true)
	draw_rect(Rect2(180, 405, 920, 220), Color("#d0a760"), false, 2)
	draw_string(ThemeDB.fallback_font, Vector2(220, 448), dialogue_title, HORIZONTAL_ALIGNMENT_LEFT, -1, 23, PAPER)
	draw_line(Vector2(220, 468), Vector2(1060, 468), Color(0.8, 0.6, 0.3, 0.45), 1)
	var y := 505.0
	for line in dialogue_text.split("\n"):
		draw_string(ThemeDB.fallback_font, Vector2(220, y), line, HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color("#c9bea9"))
		y += 23
	draw_string(ThemeDB.fallback_font, Vector2(820, 595), "CLICK / E / SPACE  CLOSE", HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color("#a89673"))

func draw_ending() -> void:
	draw_rect(Rect2(Vector2.ZERO, SIZE), Color("#c7b78d"), true)
	draw_circle(Vector2(1040, 145), 50, Color("#f3d796"))
	for i in range(25): draw_circle(Vector2(40 + (i * 83) % 1200, 280 + (i * 41) % 330), 22, Color("#405c42"))
	draw_circle(Vector2(640, 430), 30, Color("#4a382d"))
	draw_center("You look terrible.", Vector2(640, 620), 22, Color("#443c31"))
	draw_center("E / SPACE / CLICK  CONTINUE", Vector2(640, 670), 11, Color("#716653"))

func draw_sting() -> void:
	draw_rect(Rect2(Vector2.ZERO, SIZE), Color("#040306"), true)
	if cut_elapsed > 1.8:
		draw_circle(Vector2(640, 350), 12 + cut_elapsed * 5.0, Color(0.35, 0.02, 0.08, 0.8))
		draw_center("YOU SHOULDN'T HAVE LOOKED AT A GOD.", Vector2(640, 520), 23, Color("#d2c09b"))
	if cut_elapsed > 8.0: draw_center("MAP", Vector2(640, 620), 30, PAPER)

func draw_marker(pos: Vector2, title: String, subtitle: String) -> void:
	draw_line(pos + Vector2(0, -20), pos + Vector2(0, 24), Color("#684632"), 7)
	draw_rect(Rect2(pos + Vector2(5, -22), Vector2(142, 34)), Color("#dfcda5"), true)
	draw_string(ThemeDB.fallback_font, pos + Vector2(14, -4), title, HORIZONTAL_ALIGNMENT_LEFT, -1, 10, INK)
	draw_string(ThemeDB.fallback_font, pos + Vector2(14, 10), subtitle, HORIZONTAL_ALIGNMENT_LEFT, -1, 8, Color("#665746"))

func draw_player(pos: Vector2, color: Color) -> void:
	draw_circle(pos, 22, Color(0.95, 0.67, 0.28, 0.13))
	draw_circle(pos, 14, Color("#0c0a0d"))
	draw_circle(pos, 9, color)
	draw_circle(pos + Vector2(0, -3), 4, Color("#f6d48b"))
	draw_string(ThemeDB.fallback_font, pos + Vector2(17, -15), "YOU", HORIZONTAL_ALIGNMENT_LEFT, -1, 9, PAPER)

func draw_ship(pos: Vector2) -> void:
	draw_colored_polygon(PackedVector2Array([pos + Vector2(-25, -13), pos + Vector2(25, 0), pos + Vector2(-25, 13)]), Color("#d1a36a"))
	draw_line(pos + Vector2(-4, -11), pos + Vector2(-4, 11), Color("#2c2021"), 3)
	draw_circle(pos, 5, Color("#f0d08b"))

func draw_figure(pos: Vector2) -> void:
	draw_circle(pos, 10, Color("#060508"))
	draw_line(pos + Vector2(0, 8), pos + Vector2(0, 34), Color("#060508"), 6)
	draw_line(pos + Vector2(0, 17), pos + Vector2(-13, 30), Color("#060508"), 3)
	draw_line(pos + Vector2(0, 17), pos + Vector2(13, 30), Color("#060508"), 3)

func draw_island(pos: Vector2, radius: float, label: String) -> void:
	draw_circle(pos, radius, Color("#746b4b"))
	draw_circle(pos - Vector2(0, 8), radius * 0.78, Color("#4b6144"))
	draw_center(label, pos + Vector2(0, radius + 25), 10, PAPER)

func draw_arrow(from: Vector2, to: Vector2) -> void:
	var d := (to - from).normalized()
	if d.length() < 0.1: return
	var start := from + d * 34
	draw_line(start, start + d * 25, GOLD, 2)
	var side := Vector2(-d.y, d.x) * 6
	draw_colored_polygon(PackedVector2Array([start + d * 31, start + d * 18 + side, start + d * 18 - side]), GOLD)

func draw_center(text: String, pos: Vector2, size: int, color: Color) -> void:
	var width := ThemeDB.fallback_font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, size).x
	draw_string(ThemeDB.fallback_font, Vector2(pos.x - width * 0.5, pos.y), text, HORIZONTAL_ALIGNMENT_LEFT, -1, size, color)

func near(a: Vector2, b: Vector2, radius: float) -> bool: return a.distance_to(b) <= radius

func format_time(value: float) -> String: return "%02d:%05.2f" % [int(value) / 60, fmod(value, 60.0)]
