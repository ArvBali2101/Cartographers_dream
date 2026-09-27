extends RefCounted

static func make(kind: String) -> AudioStreamWAV:
	var count := 22050
	var bytes := PackedByteArray()
	bytes.resize(count*2)
	var rng := RandomNumberGenerator.new()
	rng.seed=181
	var noise := 0.0
	for i in range(count):
		var t := float(i)/22050
		noise=lerpf(noise,rng.randf_range(-1,1),0.12)
		var sample := 0.0
		if kind=="bell": sample=(sin(t*TAU*213)+sin(t*TAU*571)*0.32+sin(t*TAU*807)*0.16)*exp(-t*5)*0.5
		elif kind=="knock":
			for onset in [0.0,0.25,0.58]:
				if t>=onset: sample+=(noise*0.8+sin(t*TAU*89)*0.3)*exp(-(t-onset)*35)
		else: sample=(sin(t*TAU*54)*0.6+noise*0.22)*exp(-t*4)
		bytes.encode_s16(i*2,int(clampf(sample,-1,1)*15000))
	var stream := AudioStreamWAV.new()
	stream.format=AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate=22050
	stream.data=bytes
	return stream
