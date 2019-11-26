shader_type canvas_item;

uniform int octaves = 8;

float random (vec2 st) {
  return fract(sin(dot(st.xy, vec2(12.9898,78.233))) * 43758.5453123);
}

float noise (vec2 st) {
  vec2 i = floor(st);
  vec2 f = fract(st);

  // Four corners in 2D of a tile
  float a = random(i);
  float b = random(i + vec2(1.0, 0.0));
  float c = random(i + vec2(0.0, 1.0));
  float d = random(i + vec2(1.0, 1.0));

  vec2 u = f * f * (3.0 - 2.0 * f);

  return mix(a, b, u.x) +
          (c - a)* u.y * (1.0 - u.x) +
          (d - b) * u.x * u.y;
}

float fbm (vec2 st) {
    float v = 0.0;
    float a = 0.5;
    vec2 shift = vec2(100.0);
    // Rotate to reduce axial bias
    mat2 rot = mat2(vec2(cos(0.5), sin(0.5)),
                    vec2(-sin(0.5), cos(0.50)));
    for (int i = 0; i < octaves; ++i) {
        v += a * noise(st);
        st = rot * st * 2.0 + shift;
        a *= 0.5;
    }
    return v;
}

float fbm (vec2 st) {
    float value = 0.0;
    float amplitude = .5;
    
	for (int i = 0; i < octaves; i++) {
    	value += amplitude * noise(st);
       	amplitude *= .5;
   }
   return value;
}

void fragment() {
  /*
  vec2 st = UV * 16.0;
  float time = fract(TIME * 0.1);
  float time2 = fract((TIME * 0.1) + 0.5);
  
  vec2 dir = textureLod(TEXTURE, UV, 0.0).xy;
  dir.x -= 0.5;
  dir.x *= -2.0;
  dir.y -= 0.5;
  dir.y *= -2.0;
  
  dir = normalize(dir);
  
  float motion1 = fbm(st + time * dir * 16.0);
  float motion2 = fbm(st + time2 * dir * 16.0);
  
  float final = mix(motion1, motion2, time);
  
  COLOR = vec4(vec3(final), 1.0);
  */
  
  float intensity = 1.5;
  float timescale = 0.574;
  
  vec2 distortion = (textureLod(TEXTURE, UV, 0.0).rg - 0.5) * -2.0 * intensity;
  float scaletime = TIME * timescale;
  float flow_t0 = fract(scaletime);
  float flow_t1 = fract(scaletime + 0.5);
  float alternate = abs((flow_t0 - 0.5) * 2.0);
  
  float motion1 = fbm(UV * 24.0 + distortion * flow_t0);
  float motion2 = fbm(UV * 24.0 + distortion * flow_t1);
  float final = mix(motion1, motion2, alternate);
  
  vec3 color1 = vec3(0.0, 0.0, 1.0);
  vec3 color2 = vec3(0.0, 1.0, 1.0);
  vec3 color = final > 0.675 ? color2 : color1;
  
  COLOR = vec4(color, 1.0);
}