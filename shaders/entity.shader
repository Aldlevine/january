shader_type canvas_item;

uniform vec4 modulate : hint_color = vec4(1.);
uniform float sink_offset = 0.0;
uniform float sink = 0.0;
uniform float sink_scale = 16.;
//uniform vec4 water_edge_color : hint_color;

void fragment() {
  float s = sink + sink_offset;
  vec4 color = textureLod(TEXTURE, UV, 0.0);
  float height = textureLod(NORMAL_TEXTURE, UV, 0.0).r * sink_scale;
  if (sink > 0. && s > height) {
    COLOR = mix(color, textureLod(SCREEN_TEXTURE, SCREEN_UV, 0.0), 0.875);
    COLOR.a = color.a;
  }
  else {
    COLOR = color * modulate;
  }
}