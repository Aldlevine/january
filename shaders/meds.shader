shader_type canvas_item;
render_mode blend_add;

uniform int octaves = 8;
uniform float threshold = 0.3;
uniform float time_offset = 0.0;

float rand(vec2 coord) {
  return fract(sin(dot(coord, vec2(12.9898, 78.233))) * 43758.5453123);
}

float noise (vec2 coord) {
    vec2 i = floor(coord);
    vec2 f = fract(coord);

    // Four corners in 2D of a tile
    float a = rand(i);
    float b = rand(i + vec2(1.0, 0.0));
    float c = rand(i + vec2(0.0, 1.0));
    float d = rand(i + vec2(1.0, 1.0));

    vec2 u = f * f * (3.0 - 2.0 * f);

    return mix(a, b, u.x) +
            (c - a)* u.y * (1.0 - u.x) +
            (d - b) * u.x * u.y;
}

float fbm(vec2 coord) {
    float v = 0.0;
    float a = 0.5;
    vec2 shift = vec2(100.0);
    // Rotate to reduce axial bias
    mat2 rot = mat2(vec2(cos(0.5), sin(0.5)),
                    vec2(-sin(0.5), cos(0.50)));
    for (int i = 0; i < octaves; ++i) {
        v += a * noise(coord);
        coord = rot * coord * 2.0 + shift;
        a *= 0.5;
    }
    return v;
}

float overlay (float base, float top) {
  if (base < 0.5) {
    return 2.0 * base * top;
  }
  else {
    return 2.0 * (1.0 - base) * (1.0 - top);  
  }
}

float egg_shape (vec2 coord, float radius) {
  vec2 center = vec2(0.5, 0.8);
  vec2 diff = coord - center;
  
  if (coord.y < center.y) {
    diff.y *= 0.5;  
  }
  else {
    diff.y *= 2.0   ;  
  }
  
  float dist = sqrt(pow(diff.x, 2.0) + pow(diff.y, 2.0)) / radius;
  float value = sqrt(1.0 - dist * dist);
  return clamp(value, 0.0, 1.0);
}

void fragment() {
  float time = floor((TIME + time_offset) * 15.0) / 15.0;
  vec2 coord = UV / TEXTURE_PIXEL_SIZE * 0.25;
  vec2 fbm_coord = coord * 2.0;
  
  float egg_s = egg_shape(UV, 0.4) * 0.75;
  egg_s += egg_shape(UV, 0.2) * 0.5;
  
  float noise1 = noise(coord * 16.0 + vec2(time * -0.25, time * 12.0));
  float noise2 = noise(coord * 16.0 + vec2(time * 0.25, time * 6.0));
  float combined_noise = (noise1 + noise2) / 2.0;
  
  float fbm_noise = fbm(fbm_coord + vec2(0.0, time * 3.0));
  fbm_noise = overlay(fbm_noise, UV.y);
  
  float everything = combined_noise * fbm_noise * egg_s;
  
  if (everything < threshold) {
    COLOR = vec4(0.0, 0.0, 0.0, 0.0);
  }
  else {
    COLOR = vec4(vec3(1.0), everything);
  }
  
//  COLOR = vec4(everything);
}