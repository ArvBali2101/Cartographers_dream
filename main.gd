extends Node2D

## MAP: a compact, playable vertical slice of the expedition horror game.
## Everything is drawn procedurally so the game is immediately runnable without external assets.

enum GameState { MENU, INTRO, JUNGLE, CUT_ONE, SEA, CUT_TWO, NIGHTMARE, ENDING, STING }

const W := 1280.0
const H := 720.0
const WORLD := Rect2(80, 90, 1120, 560)
const INK := Color("#181414")
const PAPER := Color("#d3c3a4")
const BLOOD := Color("#7e2929")

var state: GameState = GameState.MENU
var player := Vector2(170, 550)
var ship := Vector2(150, 520)
var figure := Vector2(720, 360)
var witness := Vector2(-200, -200)
var checkpoint := 0
var horror_level := 0.0
var level_time := 0.0
var run_time := 0.0
var cut_index := 0
var cut_timer := 0.0
var ending_timer := 0.0
var note_changed := false
var marker_seen := 0
var minimap_wrong := false
var dead_message := ""
var timer_visible := false
var screen_shake := 0.0
var menu_choice := 0
var settings_open := false
var flash := 0.0
var whisper_phase := 0.0
var death_notice := ""
var death_notice_time := 0.0

func _ready() -> void:
	queue_redraw()

func _process(delta: float) -> void:
	whisper_phase += delta
	flash = maxf(0.0, flash - delta * 2.5)
	death_notice_time = maxf(0.0, death_notice_time - delta)
	if state in [GameState.ENDING, GameState.STING]:
		ending_timer += delta
	if state in [GameState.JUNGLE, GameState.SEA, GameState.NIGHTMARE]:
		run_time += delta
		level_time += delta
		_update_level(delta)
	queue_redraw()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_ESCAPE:
			if state != GameState.MENU:
				state = GameState.MENU
				settings_open = false
				queue_redraw()
				return
		if state == GameState.MENU:
			_handle_menu(event.keycode)
		elif state in [GameState.CUT_ONE, GameState.CUT_TWO]:
			if event.keycode in [KEY_E, KEY_SPACE, KEY_ENTER]:
				_advance_cutscene()
		elif state == GameState.JUNGLE and event.keycode == KEY_E:
			_interact_jungle()
		elif state == GameState.ENDING:
			if event.keycode in [KEY_E, KEY_SPACE, KEY_ENTER]:
				state = GameState.STING
				ending_timer = 0.0
		elif state == GameState.STING and event.keycode in [KEY_E, KEY_SPACE, KEY_ENTER]:
			state = GameState.MENU
		elif event.keycode == KEY_F2:
			timer_visible = not timer_visible

func _handle_menu(key: Key) -> void:
	if settings_open:
		if key in [KEY_ESCAPE, KEY_BACKSPACE]:
			settings_open = false
		elif key == KEY_ENTER:
			timer_visible = not timer_visible
		elif key == KEY_S:
			screen_shake = 1.0 if screen_shake < 0.5 else 0.0
		return
	if key in [KEY_UP, KEY_W]:
		menu_choice = max(0, menu_choice - 1)
	elif key in [KEY_DOWN, KEY_S]:
		menu_choice = min(2, menu_choice + 1)
	elif key in [KEY_ENTER, KEY_SPACE]:
		if menu_choice == 0:
			_start_expedition()
		elif menu_choice == 1:
			settings_open = true
		else:
			get_tree().quit()

func _start_expedition() -> void:
	state = GameState.INTRO
	cut_index = 0
	cut_timer = 0.0
	run_time = 0.0
	level_time = 0.0

func _advance_cutscene() -> void:
	cut_index += 1
	cut_timer = 0.0
	if state == GameState.INTRO and cut_index > 6:
		_start_jungle()
	elif state == GameState.CUT_ONE and cut_index > 2:
		_start_sea()
	elif state == GameState.CUT_TWO and cut_index > 2:
		_start_nightmare()

func _start_jungle() -> void:
	state = GameState.JUNGLE
	player = Vector2(170, 550)
	figure = Vector2(800, 330)
	level_time = 0.0
	marker_seen = 0
	note_changed = false
	minimap_wrong = false

func _start_sea() -> void:
	state = GameState.SEA
	ship = Vector2(150, 520)
	level_time = 0.0
	horror_level = 0.0
	dead_message = ""

func _start_nightmare() -> void:
	state = GameState.NIGHTMARE
	player = Vector2(155, 560)
	figure = Vector2(1010, 170)
	witness = Vector2(-200, -200)
	checkpoint = 0
	horror_level = 0.35
	level_time = 0.0
	minimap_wrong = true

func _update_level(delta: float) -> void:
	if state == GameState.JUNGLE:
		_update_jungle(delta)
	elif state == GameState.SEA:
		_update_sea(delta)
	else:
		_update_nightmare(delta)

func _input_vector() -> Vector2:
	var direction := Vector2.ZERO
	if Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT):
		direction.x -= 1.0
	if Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT):
		direction.x += 1.0
	if Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP):
		direction.y -= 1.0
	if Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN):
		direction.y += 1.0
	return direction.normalized()

func _update_jungle(delta: float) -> void:
	var direction := _input_vector()
	var speed := 150.0
	if Input.is_key_pressed(KEY_SHIFT):
		speed = 230.0
	if _in_forest(player):
		speed *= 0.65
	elif _on_path(player):
		speed *= 1.1
	player += direction * speed * delta
	player.x = clampf(player.x, WORLD.position.x + 18.0, WORLD.end.x - 18.0)
	player.y = clampf(player.y, WORLD.position.y + 18.0, WORLD.end.y - 18.0)
	if player.distance_to(figure) < 110.0:
		figure.x += 140.0 * delta
		figure.y += sin(level_time * 2.0) * 18.0 * delta
	if figure.x > WORLD.end.x + 60.0:
		figure = Vector2(835, 260)
	if player.distance_to(Vector2(1020, 155)) < 42.0 and marker_seen >= 2:
		_start_cut_one()
	if level_time > 42.0:
		minimap_wrong = true
	if player.distance_to(Vector2(440, 405)) < 45.0:
		marker_seen = max(marker_seen, 1)
	if player.distance_to(Vector2(685, 205)) < 45.0:
		marker_seen = max(marker_seen, 2)

func _update_sea(delta: float) -> void:
	var direction := _input_vector()
	var speed := 210.0 - horror_level * 30.0
	ship += direction * speed * delta
	ship.x = clampf(ship.x, WORLD.position.x + 20.0, WORLD.end.x - 20.0)
	ship.y = clampf(ship.y, WORLD.position.y + 20.0, WORLD.end.y - 20.0)
	horror_level = clampf(level_time / 145.0, 0.0, 1.0)
	if _in_water_obstacle(ship):
		ship -= direction * speed * delta * 1.5
	if ship.distance_to(Vector2(1080, 170)) < 52.0:
		_start_cut_two()
	if horror_level >= 1.0:
		_register_death("DROWNED")
		_start_sea()
		flash = 1.0

func _update_nightmare(delta: float) -> void:
	var direction := _input_vector()
	var speed := 175.0 + horror_level * 90.0
	if Input.is_key_pressed(KEY_SHIFT):
		speed *= 1.25
	player += direction * speed * delta
	player.x = clampf(player.x, WORLD.position.x + 14.0, WORLD.end.x - 14.0)
	player.y = clampf(player.y, WORLD.position.y + 14.0, WORLD.end.y - 14.0)
	horror_level = minf(1.0, horror_level + delta * 0.012)
	if player.distance_to(figure) < 100.0:
		checkpoint += 1
		figure = _next_figure_point()
	if checkpoint >= 2 and witness.x < 0:
		witness = player + Vector2(-260, 80)
	if witness.x > -100:
		witness = witness.move_toward(player, delta * (65.0 + horror_level * 50.0))
		if witness.distance_to(player) < 30.0:
			_register_death("SEEN")
			_start_nightmare()
			flash = 1.0
	if player.distance_to(Vector2(1080, 145)) < 50.0:
		state = GameState.ENDING
		ending_timer = 0.0

func _next_figure_point() -> Vector2:
	var points := [Vector2(440, 160), Vector2(700, 500), Vector2(930, 260), Vector2(1080, 145)]
	return points[min(checkpoint, points.size() - 1)]

func _start_cut_one() -> void:
	state = GameState.CUT_ONE
	cut_index = 0
	cut_timer = 0.0

func _start_cut_two() -> void:
	state = GameState.CUT_TWO
	cut_index = 0
	cut_timer = 0.0

func _interact_jungle() -> void:
	if player.distance_to(Vector2(440, 405)) < 65.0:
		marker_seen = max(marker_seen, 1)
	elif player.distance_to(Vector2(685, 205)) < 65.0:
		marker_seen = max(marker_seen, 2)
	elif player.distance_to(Vector2(830, 395)) < 65.0:
		marker_seen = max(marker_seen, 3)
		if not note_changed:
			note_changed = true
	elif player.distance_to(Vector2(1020, 155)) < 65.0 and marker_seen >= 2:
		_start_cut_one()

func _register_death(message: String) -> void:
	death_notice = message
	death_notice_time = 1.8

func _in_forest(point: Vector2) -> bool:
	return point.x > 250.0 and point.x < 580.0 and point.y > 180.0 and point.y < 570.0

func _on_path(point: Vector2) -> bool:
	return absf(point.y - (570.0 - point.x * 0.25)) < 28.0 or absf(point.x - 650.0) < 24.0

func _in_water_obstacle(point: Vector2) -> bool:
	return point.distance_to(Vector2(470, 250)) < 58.0 or point.distance_to(Vector2(770, 440)) < 75.0 or point.distance_to(Vector2(960, 260)) < 45.0

func _draw() -> void:
	draw_rect(Rect2(0, 0, W, H), Color("#0b0909"))
	if state == GameState.MENU:
		_draw_menu()
	elif state == GameState.INTRO:
		_draw_cutscene(["For centuries, this region remained blank.", "No reliable map existed.", "That was why I came.", "On the second night, we stopped.", "The others slept.", "I continued drawing.", "I don't remember falling asleep."])
	elif state == GameState.JUNGLE:
		_draw_jungle()
	elif state == GameState.CUT_ONE:
		_draw_cutscene(["...still drawing...", "The line was not mine.", "Something had noticed the map."])
	elif state == GameState.SEA:
		_draw_sea()
	elif state == GameState.CUT_TWO:
		_draw_cutscene(["Do you want to leave?", "Then wake up.", "You can't. He has seen you."])
	elif state == GameState.NIGHTMARE:
		_draw_nightmare()
	elif state == GameState.ENDING:
		_draw_ending()
	else:
		_draw_sting()
	if death_notice_time > 0.0:
		draw_rect(Rect2(0, 0, W, H), Color(0.02, 0.0, 0.0, 0.35), true)
		draw_string(ThemeDB.fallback_font, Vector2(520, 360), death_notice, HORIZONTAL_ALIGNMENT_LEFT, -1, 34, Color("#e0d0b0"))
	if flash > 0.0:
		draw_rect(Rect2(0, 0, W, H), Color(1, 1, 1, flash * 0.18))

func _draw_menu() -> void:
	draw_rect(Rect2(0, 0, W, H), Color("#11100d"))
	for i in range(16):
		var x := float((i * 137) % 1280)
		draw_circle(Vector2(x, 100 + sin(i * 2.1) * 70.0), 1.5, Color(0.65, 0.57, 0.42, 0.25))
	draw_string(ThemeDB.fallback_font, Vector2(545, 260), "MAP", HORIZONTAL_ALIGNMENT_LEFT, -1, 84, PAPER)
	draw_string(ThemeDB.fallback_font, Vector2(468, 310), "AN EXPEDITION INTO THE UNKNOWN", HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color("#766c5e"))
	var items := ["BEGIN EXPEDITION", "SETTINGS", "QUIT"]
	for i in items.size():
		var color := Color("#ede2c5") if i == menu_choice else Color("#6e6558")
		draw_string(ThemeDB.fallback_font, Vector2(520, 415 + i * 48), ("> " if i == menu_choice else "  ") + items[i], HORIZONTAL_ALIGNMENT_LEFT, -1, 17, color)
	draw_string(ThemeDB.fallback_font, Vector2(470, 640), "WASD / ARROWS  SELECT     ENTER  CONFIRM", HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color("#514a40"))
	if settings_open:
		draw_rect(Rect2(375, 170, 530, 370), Color("#191613"), true)
		draw_rect(Rect2(375, 170, 530, 370), Color("#7f7058"), false, 1.0)
		draw_string(ThemeDB.fallback_font, Vector2(420, 230), "SETTINGS", HORIZONTAL_ALIGNMENT_LEFT, -1, 28, PAPER)
	var settings := ["Master Volume     100%", "Music Volume      70%", "Whispers Volume   80%", "Screen Shake      " + ("ON" if screen_shake > 0.5 else "OFF"), "Show Speedrun Timer " + ("ON" if timer_visible else "OFF")]
	for i in settings.size():
		draw_string(ThemeDB.fallback_font, Vector2(430, 285 + i * 38), settings[i], HORIZONTAL_ALIGNMENT_LEFT, -1, 15, Color("#c8b99b"))
	draw_string(ThemeDB.fallback_font, Vector2(430, 490), "ENTER toggles timer   S toggles shake   ESC closes", HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color("#716657"))

func _draw_cutscene(lines: Array[String]) -> void:
	draw_rect(Rect2(0, 0, W, H), Color("#110f0c"))
	var panel := cut_index % 3
	if state == GameState.INTRO:
		panel = min(cut_index, 6)
	var panel_rect := Rect2(170, 90, 940, 430)
	draw_rect(panel_rect, Color("#3a3328"), true)
	if panel == 0:
		_draw_trees(panel_rect, 45)
	elif panel == 1:
		_draw_map_texture(panel_rect, Color("#9f906f"))
	elif panel == 2:
		_draw_cartographer(panel_rect.get_center(), false)
	elif panel == 3:
		_draw_trees(panel_rect, 20)
		draw_circle(Vector2(640, 385), 32, Color("#cb773c"))
	elif panel == 4:
		_draw_cartographer(Vector2(640, 355), true)
	else:
		_draw_map_texture(panel_rect, Color("#b9a57d"))
		if panel == 6:
			draw_line(Vector2(520, 350), Vector2(850, 220), BLOOD, 3.0)
	var text := lines[panel % lines.size()]
	draw_string(ThemeDB.fallback_font, Vector2(170, 590), text, HORIZONTAL_ALIGNMENT_CENTER, 940, 22, Color("#d6c6a3"))
	draw_string(ThemeDB.fallback_font, Vector2(535, 650), "E / SPACE  CONTINUE", HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color("#6d6354"))
	if state != GameState.INTRO:
		draw_string(ThemeDB.fallback_font, Vector2(32, 38), "MAP", HORIZONTAL_ALIGNMENT_LEFT, -1, 14, Color("#756958"))

func _draw_jungle() -> void:
	draw_rect(WORLD, Color("#bbaa86"), true)
	_draw_contours()
	_draw_trees(WORLD, 56)
	_draw_river()
	draw_line(Vector2(160, 560), Vector2(1020, 155), Color("#a97749"), 13.0)
	_draw_marker(Vector2(440, 405), "EXPEDITION I", "NORTH SURVEY")
	_draw_marker(Vector2(685, 205), "EXPEDITION II", "NO RECORD")
	_draw_marker(Vector2(830, 395), "EXPEDITION IV", "DON'T FOLLOW IT" if note_changed else "DO NOT CONTINUE")
	draw_string(ThemeDB.fallback_font, Vector2(1000, 125), "SURVEY COMPLETE", HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color("#5d4e3b"))
	_draw_figure()
	_draw_player(player, Color("#332b21"))
	_draw_minimap()
	_draw_hud("THE MAP", "Find the survey marker. E examines the expedition records.")
	if player.distance_to(Vector2(440, 405)) < 55.0:
		_draw_prompt("[E]  EXAMINE  ·  EXPEDITION I")
	if player.distance_to(Vector2(685, 205)) < 55.0:
		_draw_prompt("[E]  EXAMINE  ·  EXPEDITION II")
	if player.distance_to(Vector2(830, 395)) < 55.0:
		_draw_prompt("[E]  EXAMINE  ·  " + ("DON'T FOLLOW IT" if note_changed else "EXPEDITION IV"))
	if marker_seen < 2:
		draw_string(ThemeDB.fallback_font, Vector2(420, 105), "Find the first two records before the survey can be completed.", HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color("#5d4e3b"))

func _draw_sea() -> void:
	draw_rect(WORLD, Color("#213b43"), true)
	for y in range(110, 650, 34):
		draw_line(Vector2(90, y), Vector2(1190, y + sin(y) * 5), Color(0.35, 0.56, 0.57, 0.18), 1.0)
	_draw_island(Vector2(470, 250), 58, "BONES")
	_draw_island(Vector2(770, 440), 75, "WRECK")
	_draw_island(Vector2(960, 260), 45, "")
	_draw_lighthouse(Vector2(1080, 170))
	_draw_tentacles()
	_draw_ship(ship)
	_draw_hud("THE DROWNED MAP", "Reach the lighthouse. The whispers are the timer.")
	_draw_horror_overlay()
	if timer_visible:
		draw_string(ThemeDB.fallback_font, Vector2(1080, 42), _format_time(run_time), HORIZONTAL_ALIGNMENT_LEFT, -1, 17, Color("#c7b693"))

func _draw_nightmare() -> void:
	draw_rect(WORLD, Color("#20191b"), true)
	for i in range(13):
		var x := 115.0 + i * 85.0
		draw_line(Vector2(x, 100), Vector2(x + sin(i * 3.0) * 44.0, 640), Color(0.25, 0.15, 0.17, 0.75), 3.0)
	for i in range(10):
		var y := 130.0 + i * 52.0
		draw_line(Vector2(90, y), Vector2(1180, y + cos(i * 1.7) * 32.0), Color(0.18, 0.12, 0.14, 0.8), 3.0)
	_draw_figure()
	if witness.x > -100:
		draw_circle(witness, 34.0 + horror_level * 20.0, Color(0.01, 0.005, 0.008, 0.85))
		draw_circle(witness + Vector2(-12, -8), 4, BLOOD)
	_draw_player(player, Color("#c8a884"))
	draw_rect(Rect2(1030, 95, 90, 100), Color("#d6c8a6"), true)
	draw_string(ThemeDB.fallback_font, Vector2(1040, 150), "EXIT", HORIZONTAL_ALIGNMENT_LEFT, -1, 14, INK)
	draw_string(ThemeDB.fallback_font, Vector2(1040, 175), "WAKE", HORIZONTAL_ALIGNMENT_LEFT, -1, 12, INK)
	_draw_hud("THE LAST MAP", "Follow the figure. Do not look back.")
	_draw_horror_overlay()

func _draw_ending() -> void:
	draw_rect(Rect2(0, 0, W, H), Color("#c8b790"), true)
	draw_circle(Vector2(1050, 130), 48, Color("#f0d58f"))
	_draw_trees(Rect2(70, 250, 1140, 360), 20)
	draw_circle(Vector2(630, 460), 32, Color("#d47c3c"))
	_draw_cartographer(Vector2(630, 390), true)
	draw_string(ThemeDB.fallback_font, Vector2(390, 650), "You look terrible.", HORIZONTAL_ALIGNMENT_LEFT, -1, 22, Color("#403b32"))
	draw_string(ThemeDB.fallback_font, Vector2(495, 690), "E / SPACE  continue", HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color("#756b5c"))

func _draw_sting() -> void:
	draw_rect(Rect2(0, 0, W, H), Color("#050405"), true)
	var alpha := clampf((ending_timer - 2.0) / 2.0, 0.0, 1.0)
	if ending_timer < 5.0:
		draw_circle(Vector2(640, 350), 8 + ending_timer * 4.0, Color(0.02, 0.01, 0.02, alpha))
		draw_string(ThemeDB.fallback_font, Vector2(340, 520), "YOU SHOULDN'T HAVE LOOKED AT A GOD.", HORIZONTAL_ALIGNMENT_LEFT, -1, 22, Color(0.74, 0.67, 0.55, alpha))
	else:
		draw_string(ThemeDB.fallback_font, Vector2(535, 610), "MAP", HORIZONTAL_ALIGNMENT_LEFT, -1, 30, PAPER)

func _draw_hud(title: String, subtitle: String) -> void:
	draw_rect(Rect2(0, 0, W, 72), Color(0.05, 0.04, 0.035, 0.88), true)
	draw_string(ThemeDB.fallback_font, Vector2(28, 32), title, HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color("#d6c6a4"))
	draw_string(ThemeDB.fallback_font, Vector2(28, 54), subtitle, HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color("#847866"))
	if timer_visible:
		draw_string(ThemeDB.fallback_font, Vector2(1090, 39), _format_time(run_time), HORIZONTAL_ALIGNMENT_LEFT, -1, 17, Color("#d2c09e"))
	draw_string(ThemeDB.fallback_font, Vector2(1080, 665), "WASD move   SHIFT sprint   E interact   F2 timer", HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color("#776c5c"))

func _draw_prompt(text: String) -> void:
	draw_rect(Rect2(370, 610, 540, 35), Color(0.06, 0.04, 0.035, 0.9), true)
	draw_string(ThemeDB.fallback_font, Vector2(390, 634), text, HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color("#e0d0ad"))

func _draw_minimap() -> void:
	var mini := Rect2(1010, 90, 160, 120)
	draw_rect(mini, Color(0.1, 0.08, 0.06, 0.9), true)
	draw_rect(mini, Color("#847456"), false, 1)
	draw_string(ThemeDB.fallback_font, Vector2(1025, 112), "MEMORY MAP", HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color("#c7b893"))
	draw_line(Vector2(1040, 180), Vector2(1145 if not minimap_wrong else 1115, 130), Color("#9c8b68"), 2)
	draw_circle(Vector2(1040, 180), 4, Color("#d8a06b"))
	draw_circle(Vector2(1145 if not minimap_wrong else 1115, 130), 4, BLOOD if minimap_wrong else Color("#9c8b68"))
	if minimap_wrong:
		draw_string(ThemeDB.fallback_font, Vector2(1025, 200), "THIS LINE IS WRONG", HORIZONTAL_ALIGNMENT_LEFT, -1, 9, BLOOD)

func _draw_horror_overlay() -> void:
	var edge := clampf(horror_level * 0.55, 0.0, 0.55)
	draw_rect(Rect2(0, 0, W, 80), Color(0.15, 0.01, 0.02, edge), true)
	draw_rect(Rect2(0, 640, W, 80), Color(0.15, 0.01, 0.02, edge), true)
	if horror_level > 0.3:
		var whisper: String = ["keep going", "don't look", "he's awake", "wrong way", "closer", "we remember"][int(whisper_phase * 0.6) % 6]
		draw_string(ThemeDB.fallback_font, Vector2(580, 110), whisper, HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color(0.55, 0.44, 0.42, horror_level * 0.7))

func _draw_player(pos: Vector2, color: Color) -> void:
	draw_circle(pos, 10, color)
	draw_circle(pos, 5, Color("#d6b27b"))
	draw_line(pos + Vector2(-12, 12), pos + Vector2(12, 12), color, 2)

func _draw_ship(pos: Vector2) -> void:
	var points := PackedVector2Array([pos + Vector2(-20, -12), pos + Vector2(24, 0), pos + Vector2(-20, 12)])
	draw_colored_polygon(points, Color("#d1a56f"))
	draw_line(pos + Vector2(-7, -8), pos + Vector2(-7, 8), Color("#332521"), 2)

func _draw_figure() -> void:
	draw_circle(figure, 9, Color(0.01, 0.008, 0.009, 0.95))
	draw_line(figure + Vector2(0, 8), figure + Vector2(0, 32), Color(0.01, 0.008, 0.009, 0.95), 5)
	draw_line(figure + Vector2(0, 16), figure + Vector2(-12, 28), Color(0.01, 0.008, 0.009, 0.95), 3)
	draw_line(figure + Vector2(0, 16), figure + Vector2(12, 28), Color(0.01, 0.008, 0.009, 0.95), 3)

func _draw_marker(pos: Vector2, title: String, subtitle: String) -> void:
	draw_rect(Rect2(pos - Vector2(5, 20), Vector2(10, 40)), Color("#5e3926"), true)
	draw_rect(Rect2(pos + Vector2(5, -20), Vector2(120, 31)), Color("#d9c79f"), true)
	draw_string(ThemeDB.fallback_font, pos + Vector2(13, -3), title, HORIZONTAL_ALIGNMENT_LEFT, -1, 9, INK)
	draw_string(ThemeDB.fallback_font, pos + Vector2(13, 10), subtitle, HORIZONTAL_ALIGNMENT_LEFT, -1, 8, Color("#665744"))

func _draw_trees(area: Rect2, amount: int) -> void:
	for i in range(amount):
		var x := area.position.x + float((i * 83 + 31) % int(area.size.x))
		var y := area.position.y + float((i * 47 + 19) % int(area.size.y))
		draw_line(Vector2(x, y + 12), Vector2(x, y + 25), Color("#584a35"), 3)
		draw_colored_polygon(PackedVector2Array([Vector2(x, y - 18), Vector2(x - 14, y + 12), Vector2(x + 14, y + 12)]), Color("#4f6545"))

func _draw_contours() -> void:
	for i in range(7):
		draw_arc(Vector2(380 + i * 45, 360), 120 + i * 12, 0.2, 2.7, 40, Color(0.31, 0.25, 0.16, 0.3), 1.0)

func _draw_river() -> void:
	var points := PackedVector2Array([Vector2(590, 90), Vector2(560, 220), Vector2(610, 340), Vector2(550, 470), Vector2(610, 650), Vector2(700, 650), Vector2(640, 480), Vector2(700, 340), Vector2(650, 220), Vector2(680, 90)])
	draw_colored_polygon(points, Color("#496f70"))
	draw_line(Vector2(620, 100), Vector2(610, 620), Color(0.75, 0.83, 0.72, 0.35), 2)

func _draw_map_texture(area: Rect2, color: Color) -> void:
	draw_rect(area, color, true)
	for i in range(11):
		draw_line(area.position + Vector2(40, 40 + i * 31), area.end - Vector2(40, 60 - i * 8), Color(0.25, 0.2, 0.13, 0.22), 1)

func _draw_cartographer(pos: Vector2, sleeping: bool) -> void:
	draw_circle(pos + Vector2(0, -28), 13, Color("#3b3128"))
	draw_rect(Rect2(pos.x - 17, pos.y - 15, 34, 47), Color("#584638"), true)
	draw_line(pos + Vector2(-15, 32), pos + Vector2(-25, 56), Color("#2d2722"), 5)
	draw_line(pos + Vector2(15, 32), pos + Vector2(25, 56), Color("#2d2722"), 5)
	if sleeping:
		draw_line(pos + Vector2(30, 18), pos + Vector2(85, 8), Color("#d9c69b"), 2)

func _draw_island(pos: Vector2, radius: float, label: String) -> void:
	draw_circle(pos, radius, Color("#77674e"))
	draw_circle(pos - Vector2(0, 7), radius * 0.8, Color("#4f6651"))
	if label != "":
		draw_string(ThemeDB.fallback_font, pos + Vector2(-radius * 0.55, radius + 20), label, HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color("#d1bd95"))

func _draw_lighthouse(pos: Vector2) -> void:
	draw_rect(Rect2(pos - Vector2(12, 45), Vector2(24, 65)), Color("#d1c09a"), true)
	draw_circle(pos - Vector2(0, 50), 15, Color("#dfb36e"))
	draw_string(ThemeDB.fallback_font, pos + Vector2(-35, 34), "WAKE", HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color("#e5cda3"))

func _draw_tentacles() -> void:
	var count := int(horror_level * 7.0)
	for i in range(count):
		var base := Vector2(300 + i * 115, 600 - (i % 3) * 180)
		draw_arc(base, 85 + i * 3, 3.3, 5.8, 24, Color(0.04, 0.025, 0.03, 0.9), 14.0)

func _format_time(value: float) -> String:
	return "%02d:%05.2f" % [int(value) / 60, fmod(value, 60.0)]
