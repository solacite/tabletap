shader_type canvas_item;

uniform vec4 in_color = vec4(0.933, 0.749, 0.514, 1.0);
uniform vec4 out_color = vec4(0.0, 0.0, 0.0, 1.0);
uniform float in_out : hint_range(0.0, 1.0) = 0.0;
uniform float position : hint_range(-1.5, 1.0) = -1.0;
uniform vec2 size = vec2(8.0, 8.0);

void fragment() {
    vec2 grid_cells = size;
    vec2 cell_uv = UV * grid_cells;
    vec2 cell_center_uv = fract(cell_uv) * 2.0 - 1.0;

    float circle = length(cell_center_uv) * 0.7;
    float reveal = 1.0 - step(0.5, circle);
	
    vec4 color = mix(in_color, out_color, in_out);
    COLOR = vec4(color.rgb * reveal, color.a * reveal);
}