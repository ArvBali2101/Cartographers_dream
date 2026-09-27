extends Node

const ORDER := ["jungle","sea","city","cave","maze"]
const TITLES := {"jungle":"I / THE EXPEDITION","sea":"II / THE DROWNED CHART","city":"III / THE CITY THAT REMEMBERS","cave":"IV / BEFORE THERE WERE MAPS","maze":"V / THE LAST MAP"}
const STORIES := {
	"intro":["For centuries, this region remained blank.","We came to give it a name.","Two days inland, the expedition made camp.","The others slept. I remained beside the fire.","One more river. One more ridge.","My hand slowed. The lines began to blur.","I do not remember putting down the pencil."],
	"jungle":["In his dreams, the maps became his reality.","Beside the sleeping hand, the pencil moved.","A line he had never drawn reached the coast.","From somewhere beneath the paper: look.","I drew a connection. Something has begun using it."],
	"sea":["There was no ocean on our route.","The voices stopped when the ship reached shore.","Do you want to leave?", "Then why do you keep going deeper?","This dream knows the expedition. It is not mine alone."],
	"city":["The thought of home allowed him no respite.","They knew his name. They knew what he had drawn.","The maps were not records. They were invitations.","Below the city waited a place older than ink.","My signature is an address. The old warnings may erase it."],
	"cave":["The first maps were warnings.","One eye in the darkness. Too large to belong to anything.","It cannot see.","So why is it looking at me?","Two red witnesses. One brass key. A way out, not a victory."],
	"win":["Birds. Morning. The fire had burned out.","Sleep well?", "The map was ordinary. His hands were ordinary.","He laughed, and the expedition continued.","The maps were published. He went home.","Years passed. Nothing came for him."],
	"lose":["The last thing he heard was his own name.","At morning, the expedition found a finished map.","Beside it lay an empty bedroll.","A new symbol appeared where the cartographer should have been."],
	"sting":["YOU SHOULDN'T HAVE LOOKED AT A GOD.","CARTOGRAPHER'S DREAM / MAP"]
}

var data = preload("res://scripts/run_data.gd").new()
var art = preload("res://world_art.gd").new()
var ambient: Node
var level: Node
var presentation: Node2D
var ui: CanvasLayer
var panel: Control
var hud: Control
var chapter_label: Label
var objective_label: Label
var controls_label: Label
var clock_label: Label
var hint_label: Label
var toast_label: Label
var subtitle_label: Label
var mode := "menu"
var chapter := ""
var cinematic := "intro"
var page := 0
var page_time := 0.0
var time := 0.0
var run_clock := 0.0
var split_start := 0.0
var splits := {}
var deaths := 0
var paused := false
var overview := false
var note_open := false
var note_callback := Callable()
var records: Array[String] = []
var toast_time := 0.0
var hold_time := 0.0
var holding_continue := false
var final_result := ""
var captured := false
var capture_time := 0.0
var reveal_time := 0.0
var stamina := 1.0
var exhausted := false
var atmosphere: ColorRect
var atmosphere_material: ShaderMaterial
var cue: AudioStreamPlayer
var cue_cache := {}
var danger := 0.0
const LORE = preload("res://scripts/lore.gd")

func sprinting() -> bool:
	return Input.is_action_pressed("sprint") and not exhausted and stamina>0

func update_endurance(delta: float,moving: bool) -> void:
	if not active(): return
	if moving and sprinting():
		stamina=maxf(0,stamina-delta/3.8)
		if stamina<=0: exhausted=true
	else:
		stamina=minf(1,stamina+delta/6.5)
		if stamina>=0.35: exhausted=false

func _ready() -> void:
	setup_actions()
	ui=CanvasLayer.new()
	ui.layer=2
	add_child(ui)
	var effects := CanvasLayer.new()
	effects.layer=1
	add_child(effects)
	atmosphere=ColorRect.new()
	atmosphere.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	atmosphere.mouse_filter=Control.MOUSE_FILTER_IGNORE
	atmosphere_material=ShaderMaterial.new()
	atmosphere_material.shader=preload("res://shaders/atmosphere.gdshader")
	atmosphere.material=atmosphere_material
	effects.add_child(atmosphere)
	cue=AudioStreamPlayer.new()
	add_child(cue)
	presentation=preload("res://scripts/presentation.gd").new()
	presentation.app=self
	ui.add_child(presentation)
	ambient=preload("res://ambient.gd").new()
	add_child(ambient)
	show_menu()
	if "--chapter" in OS.get_cmdline_user_args():
		var args := OS.get_cmdline_user_args()
		var index := args.find("--chapter")
		if index+1<args.size() and args[index+1] in ORDER: enter_chapter(args[index+1])

func setup_actions() -> void:
	var bindings := {"left":[KEY_A,KEY_LEFT],"right":[KEY_D,KEY_RIGHT],"forward":[KEY_W,KEY_UP],"back":[KEY_S,KEY_DOWN],"sprint":[KEY_SHIFT],"interact":[KEY_E,KEY_SPACE],"flare":[KEY_F],"overview":[KEY_TAB]}
	for action in bindings:
		if not InputMap.has_action(action): InputMap.add_action(action)
		for code in bindings[action]:
			var event := InputEventKey.new()
			event.physical_keycode=code
			InputMap.action_add_event(action,event)

func _process(delta: float) -> void:
	time+=delta
	danger=level.danger_level() if mode=="play" and is_instance_valid(level) and level.has_method("danger_level") else 0.0
	atmosphere.visible=mode=="play"
	atmosphere_material.set_shader_parameter("danger",danger)
	atmosphere_material.set_shader_parameter("night",1.0 if chapter in ["sea","city","cave","maze"] else 0.0)
	atmosphere_material.set_shader_parameter("clock",time)
	toast_time=maxf(0,toast_time-delta)
	reveal_time=maxf(0,reveal_time-delta)
	if is_instance_valid(toast_label): toast_label.visible=toast_time>0
	if mode=="play" and not paused and not note_open:
		run_clock+=delta
		if is_instance_valid(clock_label): clock_label.text=data.clock(run_clock)
	if mode=="cinema":
		page_time+=delta
		if holding_continue and cinematic!="sting":
			hold_time+=delta
			if hold_time>=1.25:
				holding_continue=false
				finish_cinematic()
	if mode=="capture":
		capture_time+=delta
		if capture_time>=2.8: play_cinematic("lose")
	if is_instance_valid(ambient):
		var scene := 0
		if chapter=="sea": scene=4
		elif chapter in ["cave","maze","city"]: scene=6
		ambient.ambience_gain=float(data.settings.ambience)
		ambient.horror_gain=float(data.settings.horror)
		var silent := mode=="cinema" and (cinematic=="sting" or (cinematic=="cave" and page>=1))
		ambient.mix(8 if silent else scene,danger,delta)
		if silent:
			ambient.wind.volume_db=-80
			ambient.water.volume_db=-80
			ambient.dread.volume_db=-80
		AudioServer.set_bus_volume_db(0,linear_to_db(maxf(0.0001,float(data.settings.master))))
	presentation.queue_redraw()
	if mode=="play" and is_instance_valid(level):
		objective_label.text=level.objective()
		hint_label.text=level.prompt()
		hint_label.visible=not hint_label.text.is_empty()
		clock_label.visible=bool(data.settings.timer)
		if is_instance_valid(subtitle_label):
			subtitle_label.text=level.whisper() if level.has_method("whisper") else ""
			subtitle_label.visible=bool(data.settings.subtitles) and not subtitle_label.text.is_empty()

func _input(event: InputEvent) -> void:
	if event is InputEventKey and not event.echo:
		if event.keycode==KEY_TAB and mode=="play":
			overview=event.pressed
			return
		if event.keycode in [KEY_SPACE,KEY_ENTER] and mode=="cinema":
			if event.pressed:
				holding_continue=true
				hold_time=0
			elif holding_continue:
				holding_continue=false
				advance_page()
			return
	if event is not InputEventKey or not event.pressed or event.echo: return
	if event.keycode==KEY_ESCAPE:
		if note_open: close_note()
		elif mode=="play": toggle_pause()
		elif mode in ["settings","leaderboard","archive"]: show_menu()
		return
	if note_open and event.keycode in [KEY_E,KEY_SPACE,KEY_ENTER]:
		close_note()
		return
	if mode!="play": return
	if event.keycode==KEY_F2:
		data.settings.timer=not data.settings.timer
		data.save()
		return
	if paused: return
	if note_open:
		if event.keycode in [KEY_E,KEY_SPACE,KEY_ENTER]: close_note()
		return
	if overview or reveal_time>0: return
	if event.keycode in [KEY_E,KEY_SPACE]: level.interact()
	elif event.keycode==KEY_F and level.has_method("flare"): level.flare()
	elif event.keycode==KEY_F1: show_note("FIELD JOURNAL","\n\n".join(records) if not records.is_empty() else "No observations recorded yet.")
	elif event.keycode==KEY_F3: show_note("WHAT I KNOW",LORE.SUMMARIES.get(chapter,"")+"\n\n"+LORE.FIELD_GUIDE)

func active() -> bool:
	return mode=="play" and not paused and not note_open and not overview and reveal_time<=0

func clear_panel() -> void:
	if is_instance_valid(panel):
		panel.hide()
		panel.queue_free()
	panel=Control.new()
	panel.mouse_filter=Control.MOUSE_FILTER_IGNORE
	panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	ui.add_child(panel)

func label(text: String, size: int=18) -> Label:
	var node := Label.new()
	node.text=text
	node.add_theme_font_size_override("font_size",size)
	node.add_theme_color_override("font_color",Color("#e1ded4"))
	return node

func style(bg: Color,border: Color) -> StyleBoxFlat:
	var box := StyleBoxFlat.new()
	box.bg_color=bg
	box.border_color=border
	box.set_border_width_all(1)
	box.content_margin_left=18
	box.content_margin_right=18
	box.content_margin_top=10
	box.content_margin_bottom=10
	box.corner_radius_top_left=2
	box.corner_radius_bottom_right=2
	return box

func button(text: String,callback: Callable) -> Button:
	var node := Button.new()
	node.text=text
	node.custom_minimum_size=Vector2(340,44)
	node.add_theme_font_size_override("font_size",16)
	node.add_theme_stylebox_override("normal",style(Color(0.05,0.06,0.06,0.92),Color("#626863")))
	node.add_theme_stylebox_override("hover",style(Color("#313934"),Color("#bdbeb1")))
	node.add_theme_stylebox_override("focus",style(Color(0.08,0.09,0.08,0.7),Color("#eee8cf")))
	node.add_theme_stylebox_override("pressed",style(Color("#4a5049"),Color("#cfcfc0")))
	node.pressed.connect(callback)
	return node

func column(at: Vector2,width: float=420) -> VBoxContainer:
	var node := VBoxContainer.new()
	node.position=at
	node.size.x=width
	node.add_theme_constant_override("separation",12)
	panel.add_child(node)
	return node

func show_menu() -> void:
	mode="menu"
	paused=false
	note_open=false
	overview=false
	Input.mouse_mode=Input.MOUSE_MODE_VISIBLE
	if is_instance_valid(level): level.hide()
	if is_instance_valid(hud): hud.hide()
	clear_panel()
	var box := column(Vector2(446,303),388)
	var start := button("BEGIN EXPEDITION",begin_run)
	box.add_child(start)
	if not data.checkpoint.is_empty(): box.add_child(button("RESUME / "+data.checkpoint.to_upper(),resume_run))
	box.add_child(button("EXPEDITION RECORDS",show_leaderboard))
	box.add_child(button("LORE & SOURCES",show_archive))
	box.add_child(button("SETTINGS",show_settings))
	box.add_child(button("QUIT",func(): get_tree().quit()))
	start.grab_focus()

func show_archive() -> void:
	mode="archive"
	show_note("LORE & SOURCES",LORE.FIELD_GUIDE,show_menu)

func play_cue(kind: String) -> void:
	if not cue_cache.has(kind): cue_cache[kind]=preload("res://scripts/sound_cues.gd").make(kind)
	cue.stream=cue_cache[kind]
	cue.volume_db=-23+linear_to_db(maxf(0.0001,float(data.settings.horror)))
	cue.play()

func begin_run() -> void:
	run_clock=0
	deaths=0
	splits.clear()
	records.clear()
	data.checkpoint=""
	data.save()
	play_cinematic("intro")

func resume_run() -> void:
	run_clock=data.saved_time
	deaths=data.saved_deaths
	splits=data.saved_splits.duplicate()
	records.assign(data.saved_records)
	enter_chapter(data.checkpoint)

func show_settings() -> void:
	mode="settings"
	clear_panel()
	var box := column(Vector2(405,110),470)
	box.add_child(label("SETTINGS",29))
	box.add_child(label("Saved on this computer.",13))
	for item in [["master","Master volume"],["ambience","Wind and water"],["horror","Drones and creature sounds"]]:
		var key: String=item[0]
		box.add_child(label(item[1],15))
		var slider := HSlider.new()
		slider.min_value=0
		slider.max_value=1
		slider.step=0.01
		slider.value=data.settings[key]
		slider.add_theme_stylebox_override("slider",style(Color("#292c2b"),Color("#7d807b")))
		slider.add_theme_stylebox_override("grabber_area",style(Color("#b2b6ac"),Color("#ddddce")))
		slider.value_changed.connect(func(value): data.settings[key]=value; data.save())
		box.add_child(slider)
	for item in [["timer","Display speedrun timer"],["subtitles","Ambient subtitles"],["shake","Camera shake"]]:
		var key: String=item[0]
		var toggle := CheckButton.new()
		toggle.text=item[1]
		toggle.button_pressed=bool(data.settings[key])
		toggle.toggled.connect(func(value): data.settings[key]=value; data.save())
		box.add_child(toggle)
	box.add_child(label("Mouse sensitivity",15))
	var sensitivity := HSlider.new()
	sensitivity.min_value=0.001
	sensitivity.max_value=0.005
	sensitivity.step=0.0001
	sensitivity.value=data.settings.sensitivity
	sensitivity.value_changed.connect(func(value): data.settings.sensitivity=value; data.save())
	box.add_child(sensitivity)
	box.add_child(button("BACK",show_menu))

func show_leaderboard() -> void:
	mode="leaderboard"
	Input.mouse_mode=Input.MOUSE_MODE_VISIBLE
	if is_instance_valid(hud): hud.hide()
	clear_panel()
	var box := column(Vector2(310,130),660)
	box.add_child(label("EXPEDITION RECORDS",28))
	box.add_child(label("Local completed escapes / fastest first",14))
	if data.scores.is_empty(): box.add_child(label("No one has returned yet.",20))
	for i in range(data.scores.size()):
		var score: Dictionary=data.scores[i]
		box.add_child(label("%02d    %s    %d deaths    %s" % [i+1,data.clock(score.time),score.deaths,score.date],17))
	box.add_child(button("RETURN TO MENU",show_menu))
	box.add_child(button("QUIT",func(): get_tree().quit()))

func play_cinematic(which: String) -> void:
	mode="cinema"
	cinematic=which
	page=0
	page_time=0
	holding_continue=false
	note_open=false
	paused=false
	Input.mouse_mode=Input.MOUSE_MODE_VISIBLE
	clear_panel()
	if is_instance_valid(level): level.hide()
	if is_instance_valid(hud): hud.hide()

func advance_page() -> void:
	if cinematic=="sting" and page==0 and page_time<6: return
	page+=1
	page_time=0
	if page>=STORIES[cinematic].size(): finish_cinematic()

func finish_cinematic() -> void:
	holding_continue=false
	if cinematic=="intro": enter_chapter("jungle")
	elif cinematic in ORDER:
		var index := ORDER.find(cinematic)
		if index+1<ORDER.size(): enter_chapter(ORDER[index+1])
	elif cinematic=="win": play_cinematic("sting")
	elif cinematic in ["lose","sting"]: show_leaderboard()

func enter_chapter(which: String) -> void:
	if not which in ORDER: return
	if is_instance_valid(level):
		level.hide()
		remove_child(level)
		level.queue_free()
	chapter=which
	mode="play"
	paused=false
	overview=false
	note_open=false
	captured=false
	stamina=1.0
	exhausted=false
	reveal_time=0
	clear_panel()
	level=preload("res://scripts/level_3d.gd").new() if which in ["cave","maze"] else preload("res://scripts/level_2d.gd").new()
	level.app=self
	level.chapter=which
	add_child(level)
	split_start=run_clock
	build_hud()
	data.checkpoint=which
	data.saved_time=run_clock
	data.saved_deaths=deaths
	data.saved_splits=splits.duplicate()
	data.saved_records=records.duplicate()
	data.save()
	Input.mouse_mode=Input.MOUSE_MODE_CAPTURED if which in ["cave","maze"] else Input.MOUSE_MODE_VISIBLE

func build_hud() -> void:
	if is_instance_valid(hud): hud.queue_free()
	hud=Control.new()
	hud.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	hud.mouse_filter=Control.MOUSE_FILTER_IGNORE
	ui.add_child(hud)
	chapter_label=label(TITLES[chapter],18)
	chapter_label.position=Vector2(30,21)
	hud.add_child(chapter_label)
	objective_label=label("",14)
	objective_label.position=Vector2(30,50)
	hud.add_child(objective_label)
	clock_label=label(data.clock(run_clock),19)
	clock_label.position=Vector2(1090,23)
	hud.add_child(clock_label)
	controls_label=label("WASD MOVE   SHIFT SPRINT   E / SPACE EXAMINE   TAB MAP   F1 JOURNAL   ESC PAUSE",11)
	if chapter=="sea": controls_label.text="WASD STEER   SHIFT ROW   F FLARE   E / SPACE DOCK   TAB CHART   ESC PAUSE"
	elif chapter in ["cave","maze"]: controls_label.text="WASD MOVE   MOUSE LOOK   SHIFT SPRINT   E / SPACE INTERACT   TAB SURVEY   ESC PAUSE"
	controls_label.text+="   F3 GUIDE"
	controls_label.position=Vector2(28,686)
	hud.add_child(controls_label)
	hint_label=label("",18)
	hint_label.position=Vector2(300,615)
	hint_label.size=Vector2(680,48)
	hint_label.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
	hint_label.add_theme_stylebox_override("normal",style(Color(0.015,0.025,0.02,0.94),Color("#626a61")))
	hud.add_child(hint_label)
	toast_label=label("",17)
	toast_label.position=Vector2(200,110)
	toast_label.size=Vector2(880,50)
	toast_label.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
	toast_label.add_theme_stylebox_override("normal",style(Color(0.01,0.025,0.02,0.92),Color("#49554b")))
	hud.add_child(toast_label)
	subtitle_label=label("",16)
	subtitle_label.position=Vector2(400,575)
	subtitle_label.size.x=480
	subtitle_label.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
	subtitle_label.add_theme_stylebox_override("normal",style(Color(0.01,0.025,0.02,0.92),Color("#49554b")))
	hud.add_child(subtitle_label)

func toast(text: String) -> void:
	if not is_instance_valid(toast_label): return
	toast_label.text=text
	toast_time=4.0

func show_note(title: String,body: String,callback: Callable=Callable()) -> void:
	note_open=true
	note_callback=callback
	Input.mouse_mode=Input.MOUSE_MODE_VISIBLE
	if not title+"\n"+body in records and title!="FIELD JOURNAL": records.append(title+"\n"+body)
	clear_panel()
	var backdrop := ColorRect.new()
	backdrop.color=Color(0.005,0.01,0.01,0.65)
	backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	panel.add_child(backdrop)
	var box := PanelContainer.new()
	box.position=Vector2(235,177)
	box.size=Vector2(810,405)
	box.add_theme_stylebox_override("panel",style(Color("#18201c"),Color("#8f9685")))
	panel.add_child(box)
	var content := VBoxContainer.new()
	content.add_theme_constant_override("separation",18)
	box.add_child(content)
	content.add_child(label(title,25))
	var scroll := ScrollContainer.new()
	scroll.custom_minimum_size=Vector2(730,245)
	scroll.size_flags_vertical=Control.SIZE_EXPAND_FILL
	content.add_child(scroll)
	var words := label(body,18)
	words.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
	words.custom_minimum_size.x=735
	scroll.add_child(words)
	content.add_child(button("E / SPACE / ENTER  CONTINUE",close_note))

func close_note() -> void:
	note_open=false
	clear_panel()
	if chapter in ["cave","maze"] and mode=="play": Input.mouse_mode=Input.MOUSE_MODE_CAPTURED
	if note_callback.is_valid():
		var callback := note_callback
		note_callback=Callable()
		callback.call()

func toggle_pause() -> void:
	paused=not paused
	Input.mouse_mode=Input.MOUSE_MODE_VISIBLE if paused else Input.MOUSE_MODE_CAPTURED if chapter in ["cave","maze"] else Input.MOUSE_MODE_VISIBLE
	clear_panel()
	if paused:
		var box := column(Vector2(440,220),400)
		box.add_child(label("THE EXPEDITION WAITS",26))
		box.add_child(button("RESUME",toggle_pause))
		box.add_child(button("RESTART CHAPTER",func(): deaths+=1; enter_chapter(chapter)))
		box.add_child(button("SAVE & RETURN TO MENU",save_and_return))

func save_and_return() -> void:
	data.saved_time=run_clock
	data.saved_deaths=deaths
	data.saved_splits=splits.duplicate()
	data.saved_records=records.duplicate()
	data.save()
	show_menu()

func chapter_complete() -> void:
	if mode!="play": return
	splits[chapter]=run_clock-split_start
	if chapter=="maze":
		final_result="escape"
		data.finish(run_clock,deaths,splits)
		play_cinematic("win")
	else:
		records.append("CHAPTER CONCLUSION / "+chapter.to_upper()+"\n"+LORE.SUMMARIES[chapter])
		play_cinematic(chapter)

func fail_run(reason: String,final_capture: bool=false) -> void:
	if mode!="play": return
	deaths+=1
	if final_capture:
		mode="capture"
		captured=true
		capture_time=0
		final_result="captured"
		Input.mouse_mode=Input.MOUSE_MODE_VISIBLE
		clear_panel()
		if is_instance_valid(hud): hud.hide()
	else:
		mode="death"
		Input.mouse_mode=Input.MOUSE_MODE_VISIBLE
		clear_panel()
		var box := column(Vector2(400,245),480)
		box.add_child(label(reason,30))
		box.add_child(label("The page is not finished with you.",17))
		box.add_child(button("RETURN TO THIS CHAPTER",func(): enter_chapter(chapter)))
		box.add_child(button("MENU",show_menu))
