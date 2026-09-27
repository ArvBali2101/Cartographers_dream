shader_type canvas_item;
render_mode unshaded;
uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_linear;
uniform float danger=0.0;
uniform float night=0.0;
uniform float clock=0.0;
void fragment() {
	vec2 uv=SCREEN_UV;
	float split=danger*0.0009;
	vec3 c=texture(screen_texture,uv).rgb;
	c.r=texture(screen_texture,uv+vec2(split,0.0)).r;
	c.b=texture(screen_texture,uv-vec2(split,0.0)).b;
	float grain=fract(sin(dot(floor(uv*vec2(1280.,720.))+floor(clock*12.),vec2(12.9898,78.233)))*43758.5453);
	float vignette=smoothstep(0.32,0.76,length((uv-0.5)*vec2(1.08,1.0)));
	c*=1.0-vignette*(0.18+danger*0.3);
	c=mix(c,c*vec3(0.87,0.98,1.06),night*0.18);
	c+=(grain-0.5)*(0.012+danger*0.016);
	COLOR=vec4(c,1.0);
}
