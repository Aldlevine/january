shader_type canvas_item;
render_mode blend_add;

uniform vec4 color: hint_color = vec4(0.23, 0.27, 0.72, 1.0);
uniform int octaves = 8;
uniform vec2 fog_scale = vec2(8.0, 2.0);

float rand(vec2 coord) {
  return fract(sin(dot(coord, vec2(12.125, 78.5))) * 43758.5453123);
}

vec2 rand2(vec2 coord){
    coord = vec2( dot(coord,vec2(12.9898,78.233)),
              dot(coord,vec2(269.5234,183.32236)) );
    return -1.0 + 2.0*fract(sin(coord)*43758.5453123);
}

float noise(vec2 coord) {
  vec2 i = floor(coord);
  vec2 f = fract(coord);
  
  float a = rand(i);
  float b = rand(i + vec2(1.0, 0.0));
  float c = rand(i + vec2(0.0, 1.0));
  float d = rand(i + vec2(1.0, 1.0));
  
//  vec2 u = f * f * (3.0 - 2.0 * f);
  vec2 u = smoothstep(0.0, 1.0, f);
  
//  return mix(a, b, u.x) + (c - a) * u.y * (1.0 - u.x) + (d - b) * u.x * u.y;
  return mix( mix( dot( rand2(i + vec2(0.0,0.0) ), f - vec2(0.0,0.0) ),
                     dot( rand2(i + vec2(1.0,0.0) ), f - vec2(1.0,0.0) ), u.x),
                mix( dot( rand2(i + vec2(0.0,1.0) ), f - vec2(0.0,1.0) ),
                     dot( rand2(i + vec2(1.0,1.0) ), f - vec2(1.0,1.0) ), u.x), u.y) + 0.5;
}

float fbm(vec2 coord) {
    float value = 0.0;
    float scale = 0.5;
    vec2 shift = vec2(100.0);
    
    mat2 rot = mat2(vec2(cos(0.5), sin(0.5)), vec2(-sin(0.5), cos(0.5)));
    
    for (int i = 0; i < octaves;  i++) {
      value += noise(coord) * scale;
      coord = rot * coord * 2.0 + shift;
      // coord = coord * 2.0;
      scale *= 0.5;  
    }
    
    return value;
}

void fragment() {
  float time = floor(TIME * 8.0) / 8.0;
//  vec2 coord = UV * vec2(20.0 / 8.0, 12.0 / 2.0);
  vec2 coord = UV * 1.0 / TEXTURE_PIXEL_SIZE / fog_scale;
  vec2 time_offset = vec2(time * 1.0 / 100.0, 0.0);
  coord += time_offset;
  
  
  float motion1 = fbm(coord + vec2(time * -0.25 / 8.0, time * -0.125 / 8.0));
  float motion2 = fbm(coord + vec2(time * -0.125 / 8.0, time * 0.25 / 8.0));
  
  float final = fbm(coord + (motion1 + motion2) / 2.0 * 8.0);
  
//  float alpha = distance(SCREEN_UV, vec2(0.5));
  float alpha = 0.5 * final;
  alpha = alpha * alpha * (3.0 - 2.0 * alpha);
  float alpha_scale = pow(smoothstep(1.0, 0.1, final), 2.0);
  alpha_scale = alpha_scale < 0.5 ? 0.0 : pow(alpha_scale, 0.125);
  alpha_scale = pow(alpha_scale, 8.0);
  float alpha_scale2 = alpha_scale < 0.75 ? 0.0 : pow(alpha_scale, 0.125);
  alpha = alpha * 0.5 + alpha_scale * 0.25 + alpha_scale2 * 0.125;
  alpha = alpha * 0.8 + 0.1;
  
  COLOR = vec4(color.rgb, final * 0.5 * alpha + alpha * 0.5);
}