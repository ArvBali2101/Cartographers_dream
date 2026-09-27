extends Control
## Animated cartographic inserts. Real drawing, not flattened cutscene images.
var motif := "sea"
var beat := 0
var age := 0.0
var clock := 0.0
var ink := Color(0.56, 0.68, 0.72, 0.55)

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
	_fit_parent()
	get_parent().resized.connect(_fit_parent)

func _fit_parent() -> void:
	size = get_parent().size

func reveal(value: int) -> void:
	beat = value
	age = 0.0

func _process(delta: float) -> void:
	clock += delta
	age += delta
	queue_redraw()

func _draw() -> void:
	var centre := Vector2(size.x * 0.5, size.y * 0.25)
	var radius := minf(size.x * 0.17, size.y * 0.16)
	var amount := clampf(age / 1.7, 0.0, 1.0)
	var tint := Color(ink, ink.a * amount)
	# Survey ticks, then a route that visibly inks itself.
	for i in 32:
		var angle := TAU * i / 32.0
		var direction := Vector2.from_angle(angle)
		draw_line(centre + direction * (radius + 12.0), centre + direction * (radius + 18.0 if i % 4 == 0 else radius + 15.0), Color(tint, tint.a * 0.4), 1.0, true)
	var route := PackedVector2Array()
	for i in int(amount * 72.0) + 1:
		var phase := i / 72.0
		route.append(centre + Vector2((phase - 0.5) * radius * 2.2, sin(phase * 10.0 + beat) * radius * 0.26))
	if route.size() > 1:
		draw_polyline(route, Color(0.64, 0.23, 0.17, 0.7), 2.0, true)
	if motif == "sea":
		for j in 5:
			var wave := PackedVector2Array()
			for i in 60:
				var x := (i / 59.0 - 0.5) * radius * 2.8
				wave.append(centre + Vector2(x, (j - 2) * 30.0 + sin(x * 0.04 + clock * 0.5 + j) * 7.0))
			draw_polyline(wave, Color(tint, tint.a * 0.5), 1.2, true)
		# A shadow passes below the chart. Never resolve its whole shape.
		var shadow := centre + Vector2(sin(clock * 0.18) * radius, 22.0)
		draw_set_transform(shadow, -0.2, Vector2(2.4, 0.5))
		draw_circle(Vector2.ZERO, radius * 0.55, Color(0, 0, 0, 0.45 * amount))
		draw_set_transform(Vector2.ZERO)
	elif motif == "survey":
		for j in 6:
			var contour := PackedVector2Array()
			for i in 81:
				var angle := TAU * i / 80.0
				var distance := radius * (0.35 + j * 0.12) + sin(angle * 3.0 + clock * 0.18) * 11.0
				contour.append(centre + Vector2.from_angle(angle) * distance * Vector2(1.5, 0.65))
			draw_polyline(contour, Color(tint, tint.a * 0.65), 1.0, true)
		var figure := centre + Vector2(radius * sin(clock * 0.3), -20.0)
		draw_circle(figure - Vector2(0, 11), 4.0, Color(0.01, 0.01, 0.01, amount))
		draw_line(figure - Vector2(0, 7), figure + Vector2(0, 9), Color(0.01, 0.01, 0.01, amount), 5.0)
	else:
		# Nested orbit diagrams: Yog-Sothoth's threshold, not a complete god portrait.
		for j in 7:
			var angle := TAU * j / 7.0 + clock * 0.045
			var orbit := centre + Vector2.from_angle(angle) * radius * 0.6
			draw_arc(orbit, radius * 0.37, 0, TAU * amount, 48, Color(tint, tint.a * 0.65), 1.4, true)
		if beat >= 4:
			# Blind, closed eye fragment; no full creature and no loud jump sting.
			var lid := PackedVector2Array()
			for i in 50:
				var x := (i / 49.0 - 0.5) * 2.0
				lid.append(centre + Vector2(x * radius * 1.5, sin(x * PI) * 6.0))
			draw_polyline(lid, Color(0.66, 0.43, 0.34, 0.7 * amount), 3.0, true)
