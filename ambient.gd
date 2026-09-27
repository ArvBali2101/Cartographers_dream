extends Node

var wind: AudioStreamPlayer
var water: AudioStreamPlayer
var dread: AudioStreamPlayer
var ambience_gain := 1.0
var horror_gain := 1.0

func _exit_tree() -> void:
	for layer in [wind,water,dread]:
		if is_instance_valid(layer):
			layer.stop()
			layer.stream = null

func _ready() -> void:
	wind = make_layer(13,0)
	water = make_layer(29,1)
	dread = make_layer(47,2)

func make_layer(noise_seed: int, kind: int) -> AudioStreamPlayer:
	var rng := RandomNumberGenerator.new()
	rng.seed = noise_seed
	var bytes := PackedByteArray()
	var count := 44100*4
	bytes.resize(count*2)
	var noise := 0.0
	for i in range(count):
		var t := float(i)/44100.0
		noise = lerpf(noise,rng.randf_range(-1,1),0.02 if kind!=1 else 0.12)
		var sample := noise*0.8
		if kind==0:
			sample += sin(t*TAU*2100)*pow(maxf(0,sin(t*TAU*4)),16)*0.018
		elif kind==1:
			sample *= 0.55+sin(t*TAU*0.5)*0.3
		else:
			sample = sin(t*TAU*43)*0.19+sin(t*TAU*44.5)*0.12+noise*0.12
		bytes.encode_s16(i*2,int(clampf(sample,-1,1)*16000))
	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = 44100
	stream.data = bytes
	stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
	stream.loop_begin = 0
	stream.loop_end = count
	var layer := AudioStreamPlayer.new()
	layer.stream = stream
	layer.volume_db = -80
	add_child(layer)
	layer.play()
	return layer

func mix(scene: int, danger: float, delta: float) -> void:
	var wind_level := -23.0 if scene in [0,1,2,3,7] else -55.0
	var water_level := -20.0 if scene in [4,5] else -60.0
	var dread_level := -30.0 + danger*14 if scene in [3,4,5,6] else -65.0
	if scene==8:
		wind_level=-80
		water_level=-80
		dread_level=-80
	wind_level+=linear_to_db(maxf(0.0001,ambience_gain))
	water_level+=linear_to_db(maxf(0.0001,ambience_gain))
	dread_level+=linear_to_db(maxf(0.0001,horror_gain))
	wind.volume_db = move_toward(wind.volume_db,wind_level,delta*20)
	water.volume_db = move_toward(water.volume_db,water_level,delta*20)
	dread.volume_db = move_toward(dread.volume_db,dread_level,delta*20)
