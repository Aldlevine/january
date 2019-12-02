shader_type canvas_item;

uniform vec4 modulate : hint_color = vec4(1.);
uniform float sink_offset = 0.0;
uniform float sink = 0.0;
uniform float sink_scale = 16.;
//uniform vec4 water_edge_color : hint_color;

vec3 rgb2hsv(vec3 c)
{
    vec4 K = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
    vec4 p = mix(vec4(c.bg, K.wz), vec4(c.gb, K.xy), step(c.b, c.g));
    vec4 q = mix(vec4(p.xyw, c.r), vec4(c.r, p.yzx), step(p.x, c.r));

    float d = q.x - min(q.w, q.y);
    float e = 1.0e-10;
    return vec3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
}

vec3 darken(vec3 base, vec3 blend) {
//  return rgb2hsv(base).x < rgb2hsv(blend).x ? base : blend;
  return vec3(min(base.r,blend.r),min(base.g,blend.g),min(base.b,blend.b));
}

void fragment() {
  float s = sink + sink_offset;
  vec4 color = textureLod(TEXTURE, UV, 0.0);
  float height = textureLod(NORMAL_TEXTURE, UV, 0.0).r * sink_scale;
  if (sink > 0. && s > height) {
    COLOR = mix(mix(color, vec4(0.125, 0.0, 0.5, 1.), 0.333), textureLod(SCREEN_TEXTURE, SCREEN_UV, 0.0), 0.667);
    COLOR.a = color.a;
//    COLOR = mix(color, vec4(0., 0.25, 0.5, 1.), 0.875);
//    COLOR = vec4(mix(COLOR.rgb, textureLod(SCREEN_TEXTURE, SCREEN_UV, 0.0).rgb, 0.5), color.a);
//    COLOR = vec4(darken(textureLod(SCREEN_TEXTURE, SCREEN_UV, 0.0).rgb, COLOR.rgb), color.a);
  }
  else {
    COLOR = color * modulate;
  }
}