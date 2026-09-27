extends RefCounted

const SAVE := "user://cartographers_dream.cfg"
var settings := {"timer":false,"subtitles":true,"shake":true,"master":0.8,"ambience":0.7,"horror":0.75,"sensitivity":0.0023}
var scores: Array = []
var checkpoint := ""
var saved_time := 0.0
var saved_deaths := 0
var saved_splits := {}
var saved_records: Array = []
var save_path := SAVE

func _init() -> void:
	if "--test" in OS.get_cmdline_user_args(): save_path="user://cartographers_dream_tests.cfg"
	var file := ConfigFile.new()
	if file.load(save_path)!=OK: return
	for key in settings: settings[key]=file.get_value("settings",key,settings[key])
	scores=file.get_value("run","scores",[])
	checkpoint=file.get_value("run","checkpoint","")
	saved_time=file.get_value("run","time",0.0)
	saved_deaths=file.get_value("run","deaths",0)
	saved_splits=file.get_value("run","splits",{})
	saved_records=file.get_value("run","journal",[])

func save() -> void:
	var file := ConfigFile.new()
	for key in settings: file.set_value("settings",key,settings[key])
	file.set_value("run","scores",scores)
	file.set_value("run","checkpoint",checkpoint)
	file.set_value("run","time",saved_time)
	file.set_value("run","deaths",saved_deaths)
	file.set_value("run","splits",saved_splits)
	file.set_value("run","journal",saved_records)
	file.save(save_path)

func finish(seconds: float,deaths: int,splits: Dictionary) -> void:
	scores.append({"time":seconds,"deaths":deaths,"date":Time.get_date_string_from_system(),"splits":splits.duplicate()})
	scores.sort_custom(func(a,b): return a.time<b.time)
	if scores.size()>10: scores.resize(10)
	checkpoint=""
	save()

func clock(seconds: float) -> String:
	return "%02d:%06.3f" % [int(seconds)/60,fmod(seconds,60.0)]
