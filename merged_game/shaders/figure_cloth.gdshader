shader_type spatial;
render_mode cull_disabled;
varying vec3 local_position;
void vertex() {
	float hem = clamp((0.45 - VERTEX.y), 0.0, 1.0);
	VERTEX.x += sin(TIME * 1.1 + VERTEX.y * 6.0) * hem * 0.017;
	VERTEX.z += sin(TIME * 0.8 + VERTEX.x * 14.0) * hem * 0.012;
	local_position = VERTEX;
}
void fragment() {
	float folds = sin(atan(local_position.z,local_position.x) * 18.0) * 0.012;
	float weave = sin(local_position.y * 700.0) * sin(local_position.x * 700.0) * 0.004;
	ALBEDO = vec3(0.07,0.078,0.084) + folds + weave;
	ROUGHNESS = 0.96;
}
