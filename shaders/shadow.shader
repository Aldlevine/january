shader_type canvas_item;
render_mode blend_disabled;

uniform float dark_hue = 0.666666667;

vec3 rgb2hsv(vec3 c)
{
    vec4 K = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
    vec4 p = mix(vec4(c.bg, K.wz), vec4(c.gb, K.xy), step(c.b, c.g));
    vec4 q = mix(vec4(p.xyw, c.r), vec4(c.r, p.yzx), step(p.x, c.r));

    float d = q.x - min(q.w, q.y);
    float e = 1.0e-10;
    return vec3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
}

vec3 hsv2rgb(vec3 c)
{
    vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

float wrap(float value) {
  if (value < 0.0) { return value + 1.0; }
  if (value > 1.0) { return value - 1.0; }
}

void fragment() {
  vec4 color = textureLod(SCREEN_TEXTURE, SCREEN_UV, 0.);
  vec3 hsv = rgb2hsv(color.rgb);
  float hue = hsv.x;
  float dark_hue_shifted = wrap(dark_hue - 0.5);
  if (hue > dark_hue_shifted && hue < dark_hue) {
    // shift positive
    hue += 0.25;  
  }
  else {
    // shift negative
    hue -= 0.25;
  }
  hsv = vec3(hue, hsv.y * 0.75, hsv.z * 0.75);
//  hsv = vec3(hue, hsv.y, hsv.z);
  COLOR = vec4(hsv2rgb(hsv), textureLod(TEXTURE, UV, 0.0).a * 0.5);
}