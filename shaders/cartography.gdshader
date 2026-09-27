shader_type canvas_item;
render_mode unshaded;
uniform sampler2D discovery : filter_linear, repeat_disable;
uniform vec2 world_size = vec2(1280.0,720.0);
uniform vec4 parchment : source_color = vec4(0.78,0.73,0.61,1.0);
void fragment() {
	vec2 p=UV;
	float ink=texture(discovery,p).r;
	float fiber=fract(sin(dot(floor(p*world_size),vec2(12.9898,78.233)))*43758.5453);
	vec3 paper=parchment.rgb+(fiber-0.5)*0.045;
	float edge=1.0-smoothstep(0.06,0.65,ink);
	COLOR=vec4(mix(paper,paper*0.72,smoothstep(0.0,0.15,ink)*edge),1.0-smoothstep(0.10,0.82,ink));
}
