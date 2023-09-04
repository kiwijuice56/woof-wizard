shader_type canvas_item;

uniform sampler2D tex_a: filter_linear, source_color, repeat_enable;
uniform sampler2D tex_b: filter_linear, source_color, repeat_enable;
uniform sampler2D tex_c: filter_linear, source_color, repeat_enable;

uniform vec4 color_a: source_color;
uniform vec4 color_b: source_color;
uniform vec4 color_c: source_color;
uniform vec4 color_d: source_color;

uniform float speed_a = 24.0;
uniform float speed_b = 12.0;
uniform float speed_c = 64.0;

uniform float threshold_a = 0.0;
uniform float threshold_b = 0.0;
uniform float threshold_speed = 1.0;

void fragment() {
	float r_1 = texture(tex_a, sin(UV.y * 3.0) / 4.0 + UV * 1.5 + TIME / speed_a).r;
	float r_2 = texture(tex_b, sin(UV.y * 2.0) / 2.0 + UV - TIME / speed_b).r;
	float r_3 = texture(tex_c, UV - TIME / speed_c).r;
	
	float threshold = threshold_a + (threshold_b - threshold_a) * (0.5 + sin(TIME / threshold_speed) / 2.0);
	
	if (r_1 <= threshold && r_2 <= threshold) {
		COLOR = color_a;
	} else if (r_1 <= threshold || r_2 <= threshold) {
		COLOR = color_b;
	} else if (r_3 <= threshold){
		COLOR = color_c;
	} else {
		COLOR = color_d;
	}
}
