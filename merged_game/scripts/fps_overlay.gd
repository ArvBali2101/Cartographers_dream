extends CanvasLayer
## First-person overlay: a faint crosshair, the "E — open the door" prompt,
## page text, blood on the lens, and the final fade.

var _hand: Font = preload("res://assets/fonts/Caveat.ttf")
var _prompt: Label
var _page: PanelContainer
var _page_text: Label
var _page_tween: Tween
var _reader: Control
var _reader_scroll: ScrollContainer
var _page_close: Button
var _page_previous: Button
var _page_next: Button
var _page_counter: Label
var _page_blocks := PackedStringArray()
var _page_index := 0
var reading := false
var _previous_pause := false
var _previous_mouse := Input.MOUSE_MODE_VISIBLE
var _blood: Control
var _fade: ColorRect
var _cross: Control
var _splats: Array = []
var _blood_t := -1.0


func _ready() -> void:
	layer = 6
	process_mode = Node.PROCESS_MODE_ALWAYS
	add_to_group("fps_overlay")
	_cross = Control.new()
	_cross.set_anchors_preset(Control.PRESET_FULL_RECT)
	_cross.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_cross.draw.connect(func(): _cross.draw_circle(_cross.size / 2.0, 2.0, Color(0.9, 0.9, 0.95, 0.35)))
	add_child(_cross)
	_prompt = Label.new()
	_prompt.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_prompt.set_anchors_preset(Control.PRESET_CENTER)
	_prompt.grow_horizontal = Control.GROW_DIRECTION_BOTH
	_prompt.position.y += 60
	_prompt.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_prompt.add_theme_font_override("font", _hand)
	_prompt.add_theme_font_size_override("font_size", 30)
	_prompt.add_theme_color_override("font_color", Color(0.92, 0.9, 0.85, 0.85))
	_prompt.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.9))
	_prompt.add_theme_constant_override("outline_size", 6)
	add_child(_prompt)
	_build_reader()
	_blood = Control.new()
	_blood.set_anchors_preset(Control.PRESET_FULL_RECT)
	_blood.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_blood.draw.connect(_draw_blood)
	add_child(_blood)
	_fade = ColorRect.new()
	_fade.set_anchors_preset(Control.PRESET_FULL_RECT)
	_fade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_fade.color = Color(0, 0, 0, 0)
	add_child(_fade)


var _line: Label
var _line_tw: Tween
var _stam: Control
var player: Node3D


## A line of his thoughts, near the top of the screen, for a few seconds.
func say(text: String, secs := 3.5, big := false) -> void:
	if _line == null:
		_line = Label.new()
		_line.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_line.set_anchors_preset(Control.PRESET_CENTER_TOP)
		_line.grow_horizontal = Control.GROW_DIRECTION_BOTH
		_line.position.y = 150
		_line.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		_line.add_theme_font_override("font", _hand)
		_line.add_theme_color_override("font_color", Color(0.92, 0.88, 0.8))
		_line.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.9))
		_line.add_theme_constant_override("outline_size", 8)
		add_child(_line)
	_line.add_theme_font_size_override("font_size", 64 if big else 32)
	_line.text = text
	if big:
		_line.add_theme_color_override("font_color", Color(0.85, 0.12, 0.08))
	else:
		_line.add_theme_color_override("font_color", Color(0.92, 0.88, 0.8))
	if _line_tw:
		_line_tw.kill()
	_line.modulate.a = 0.0
	_line_tw = create_tween()
	_line_tw.tween_property(_line, "modulate:a", 1.0, 0.4)
	_line_tw.tween_interval(secs)
	_line_tw.tween_property(_line, "modulate:a", 0.0, 1.0)


## A quick flash of colour (a false door's white).
func flash(color: Color, hold := 0.3, out := 0.8) -> void:
	_fade.color = Color(color, 1.0)
	var tw := create_tween()
	tw.tween_interval(hold)
	tw.tween_property(_fade, "color:a", 0.0, out)


func _draw_stamina() -> void:
	if player == null or not ("stamina" in player):
		return
	var f: float = player.stamina / player.stamina_max
	if f >= 0.999:
		return
	var w := 160.0
	var at := Vector2((_stam.size.x - w) / 2.0, _stam.size.y - 46.0)
	_stam.draw_rect(Rect2(at, Vector2(w, 5)), Color(0, 0, 0, 0.5))
	_stam.draw_rect(Rect2(at, Vector2(w * f, 5)), Color(0.85, 0.82, 0.75, 0.6) if f > 0.2 else Color(0.8, 0.2, 0.15, 0.7))


func set_prompt(text: String) -> void:
	var passive := text.begins_with("locked") or text.begins_with("it") or text.begins_with("the light")
	_prompt.text = "" if text == "" else (text if passive else "E / Space — " + text)


func show_page(text: String) -> void:
	if _page_tween:
		_page_tween.kill()
	if not reading:
		_previous_pause = get_tree().paused
		_previous_mouse = Input.mouse_mode
	reading = true
	_page_blocks = text.split("\n\n---\n\n", false)
	if _page_blocks.is_empty(): _page_blocks.append("The page is blank.")
	_page_index = 0
	_show_page_block()
	_page.modulate.a = 1.0
	_reader.show()
	_cross.hide()
	_prompt.hide()
	get_tree().paused = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	_page_close.grab_focus()


func _build_reader() -> void:
	var reader_layer := CanvasLayer.new()
	reader_layer.layer = 30
	add_child(reader_layer)
	_reader = Control.new()
	_reader.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	reader_layer.add_child(_reader)
	var shade := ColorRect.new()
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	shade.color = Color(0, 0, 0, 0.68)
	_reader.add_child(shade)
	_page = PanelContainer.new()
	_page.set_anchors_preset(Control.PRESET_CENTER)
	var parchment := StyleBoxFlat.new()
	parchment.bg_color = Color(0.86, 0.8, 0.67)
	parchment.border_color = Color(0.23, 0.17, 0.11)
	parchment.set_border_width_all(2)
	parchment.set_content_margin_all(24)
	_page.add_theme_stylebox_override("panel", parchment)
	_reader.add_child(_page)
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 14)
	_page.add_child(column)
	var heading := Label.new()
	heading.text = "The cartographer's papers"
	heading.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	heading.add_theme_font_override("font", preload("res://assets/fonts/IMFellEnglish.ttf"))
	heading.add_theme_font_size_override("font_size", 30)
	heading.add_theme_color_override("font_color", Color(0.2, 0.13, 0.08))
	column.add_child(heading)
	_reader_scroll = ScrollContainer.new()
	_reader_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_reader_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	column.add_child(_reader_scroll)
	_page_text = Label.new()
	_page_text.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_page_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_page_text.add_theme_font_override("font", _hand)
	_page_text.add_theme_font_size_override("font_size", 26)
	_page_text.add_theme_color_override("font_color", Color(0.25, 0.14, 0.08))
	_reader_scroll.add_child(_page_text)
	_page_counter = Label.new()
	_page_counter.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_page_counter.add_theme_font_size_override("font_size", 18)
	_page_counter.add_theme_color_override("font_color", Color(0.3, 0.22, 0.14))
	column.add_child(_page_counter)
	var buttons := HBoxContainer.new()
	buttons.alignment = BoxContainer.ALIGNMENT_CENTER
	buttons.add_theme_constant_override("separation", 16)
	column.add_child(buttons)
	_page_previous = Button.new()
	_page_previous.text = "Previous page"
	_page_previous.add_theme_font_size_override("font_size", 22)
	_page_previous.pressed.connect(func(): _turn_page(-1))
	buttons.add_child(_page_previous)
	_page_next = Button.new()
	_page_next.text = "Next page"
	_page_next.add_theme_font_size_override("font_size", 22)
	_page_next.pressed.connect(func(): _turn_page(1))
	buttons.add_child(_page_next)
	_page_close = Button.new()
	_page_close.text = "Finish reading"
	_page_close.custom_minimum_size = Vector2(190, 48)
	_page_close.add_theme_font_size_override("font_size", 22)
	_page_close.add_theme_color_override("font_color", Color(0.97, 0.93, 0.83))
	_page_close.add_theme_color_override("font_hover_color", Color(1, 0.96, 0.86))
	var finish_style := StyleBoxFlat.new()
	finish_style.bg_color = Color(0.21, 0.16, 0.11)
	finish_style.border_color = Color(0.5, 0.4, 0.26)
	finish_style.set_border_width_all(1)
	finish_style.set_content_margin_all(12)
	_page_close.add_theme_stylebox_override("normal", finish_style)
	var hover_style := finish_style.duplicate() as StyleBoxFlat
	hover_style.bg_color = Color(0.32, 0.24, 0.15)
	_page_close.add_theme_stylebox_override("hover", hover_style)
	_page_close.add_theme_stylebox_override("pressed", finish_style)
	_page_close.pressed.connect(close_page)
	buttons.add_child(_page_close)
	_layout_reader()
	get_viewport().size_changed.connect(_layout_reader)
	_reader.hide()


func _layout_reader() -> void:
	var screen := get_viewport().get_visible_rect().size
	var width := minf(860, screen.x - 40)
	var height := minf(600, screen.y - 40)
	_page.offset_left = -width / 2
	_page.offset_right = width / 2
	_page.offset_top = -height / 2
	_page.offset_bottom = height / 2
	_reader_scroll.custom_minimum_size.y = maxf(80, height - 320)


func _show_page_block() -> void:
	_page_text.text = _page_blocks[_page_index].strip_edges()
	_page_counter.text = "Page %d of %d  •  E / Space / Esc to finish" % [_page_index + 1, _page_blocks.size()]
	_page_previous.disabled = _page_index == 0
	_page_next.disabled = _page_index + 1 >= _page_blocks.size()
	_reader_scroll.scroll_vertical = 0


func _turn_page(direction: int) -> void:
	_page_index = clampi(_page_index + direction, 0, _page_blocks.size() - 1)
	_show_page_block()


func close_page() -> void:
	if not reading: return
	reading = false
	if _page_tween: _page_tween.kill()
	_reader.hide()
	_page.modulate.a = 0
	_cross.show()
	_prompt.show()
	get_tree().paused = _previous_pause
	Input.mouse_mode = _previous_mouse
	_page_close.release_focus()


func _input(event: InputEvent) -> void:
	if reading and (event.is_action_pressed("interact") or event.is_action_pressed("pause") or event.is_action_pressed("ui_cancel")):
		get_viewport().set_input_as_handled()
		close_page()


func _exit_tree() -> void:
	if reading:
		get_tree().paused = _previous_pause


func fade_to(color: Color, t: float) -> void:
	_fade.color = Color(color, _fade.color.a)
	await create_tween().tween_property(_fade, "color:a", 1.0, t).finished


## Blood hits the lens in a burst of splats that then run down the screen.
func splatter() -> void:
	_cross.hide()
	_prompt.text = ""
	var s := _blood.size
	var rng := RandomNumberGenerator.new()
	rng.randomize()
	for i in 11:
		var c := Vector2(rng.randf_range(0.05, 0.95) * s.x, rng.randf_range(0.05, 0.75) * s.y)
		var r := rng.randf_range(28.0, 90.0)
		if i < 2:
			c = s * Vector2(rng.randf_range(0.35, 0.65), rng.randf_range(0.3, 0.55))
			r = rng.randf_range(110.0, 160.0)
		# a smooth, lumpy blob (always star-shaped around c, so it fills cleanly)
		var pts := PackedVector2Array()
		var k := 40
		var p1 := rng.randf() * TAU
		var p2 := rng.randf() * TAU
		for j in k:
			var a := TAU * j / k
			var rr := r * (1.0 + 0.22 * sin(3.0 * a + p1) + 0.12 * sin(7.0 * a + p2))
			pts.append(c + Vector2.from_angle(a) * rr)
		# flung spatter: thin rays and droplets
		var rays := []
		for d in rng.randi_range(3, 7):
			var a := rng.randf() * TAU
			rays.append({"a": a, "len": r * rng.randf_range(1.2, 2.2), "w": r * rng.randf_range(0.08, 0.16)})
		var drops := []
		for d in rng.randi_range(5, 12):
			drops.append({"p": c + Vector2.from_angle(rng.randf() * TAU) * r * rng.randf_range(1.2, 2.4), "r": rng.randf_range(2.5, 9.0)})
		var drips := []
		for d in rng.randi_range(1, 3):
			drips.append({"x": c.x + rng.randf_range(-r * 0.5, r * 0.5), "w": rng.randf_range(4.0, 10.0), "speed": rng.randf_range(30.0, 110.0), "y0": c.y + r * 0.5})
		_splats.append({"c": c, "r": r, "poly": pts, "rays": rays, "drops": drops, "drips": drips,
			"delay": i * 0.025 + (0.0 if i < 2 else 0.1), "shade": rng.randf_range(0.3, 0.48)})
	_blood_t = 0.0


func _process(delta: float) -> void:
	if _stam == null:
		_stam = Control.new()
		_stam.set_anchors_preset(Control.PRESET_FULL_RECT)
		_stam.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_stam.draw.connect(_draw_stamina)
		add_child(_stam)
		move_child(_stam, 1)
	_stam.queue_redraw()
	if _blood_t >= 0.0:
		_blood_t += delta
		_blood.queue_redraw()


func _draw_blood() -> void:
	if _blood_t < 0.0:
		return
	# a red wash first
	_blood.draw_rect(Rect2(Vector2.ZERO, _blood.size), Color(0.35, 0.0, 0.0, clampf(_blood_t * 1.5, 0.0, 0.35)))
	for sp in _splats:
		var t: float = _blood_t - sp.delay
		if t <= 0.0:
			continue
		var grow := minf(t / 0.1, 1.0)
		var c: Vector2 = sp.c
		var col := Color(sp.shade, 0.0, 0.01, 0.9)
		var dark := Color(sp.shade * 0.55, 0.0, 0.0, 0.9)
		for ray in sp.rays:
			var dir: Vector2 = Vector2.from_angle(ray.a)
			var side: Vector2 = dir.orthogonal() * ray.w
			var tip: Vector2 = c + dir * ray.len * grow
			_blood.draw_colored_polygon(PackedVector2Array([c + side, tip, c - side]), col)
			_blood.draw_circle(tip, ray.w * 0.6, col)
		var poly := PackedVector2Array()
		for p in sp.poly:
			poly.append(c + (p - c) * grow)
		_blood.draw_colored_polygon(poly, col)
		_blood.draw_colored_polygon(_shrink(poly, c, 0.6), dark)
		_blood.draw_circle(c - Vector2(sp.r, sp.r) * 0.25 * grow, sp.r * 0.12, Color(1, 0.6, 0.6, 0.12))  # wet highlight
		for d in sp.drops:
			_blood.draw_circle(c + (d.p - c) * grow, d.r * grow, col)
		for dr in sp.drips:
			var length := minf(t * dr.speed, 500.0)
			var top := Vector2(dr.x - dr.w / 2.0, dr.y0)
			_blood.draw_rect(Rect2(top, Vector2(dr.w, length)), col)
			_blood.draw_circle(top + Vector2(dr.w / 2.0, length), dr.w * 0.7, col)


func _shrink(poly: PackedVector2Array, c: Vector2, k: float) -> PackedVector2Array:
	var out := PackedVector2Array()
	for p in poly:
		out.append(c + (p - c) * k)
	return out
