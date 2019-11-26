shader_type canvas_item;

uniform sampler2D texture;
uniform float period = 2.;
uniform int octaves = 8;
uniform float whirl = 0.75;
uniform float intensity = 2.975;
uniform float timescale = .075;
uniform float timestep = 8.;
uniform vec2 tile_offset = vec2(0., 0.);

uniform vec4 low_color : hint_color;
uniform vec4 mid_color : hint_color;
uniform vec4 high_color : hint_color;

vec2 hash(vec2 p) {
  p = mod(p, period);
  p = vec2(dot(p,vec2(127.1,311.7)), dot(p,vec2(269.5,183.3)));
  return -1.0 + 2.0*fract(sin(p)*43758.5453123);
}

float noise(vec2 p) {
  vec2 i = floor(p);
  vec2 f = fract(p);
  vec2 u = f*f*(3. - 2. * f);
  
  return mix(
    mix(dot(hash(i + vec2(0., 0.)), f - vec2(0., 0.)),
        dot(hash(i + vec2(1., 0.)), f - vec2(1., 0.)), u.x),
    mix(dot(hash(i + vec2(0., 1.)), f - vec2(0., 1.)),
        dot(hash(i + vec2(1., 1.)), f - vec2(1., 1.)), u.x), u.y);
}

float fbm(vec2 p) {
  float value = 0.0;
  float scale = .5;
  
  for (int i = 0; i < octaves; i++) {
    value += scale * noise(p);
    p *= 2.;
    scale *= .5;
  }
  
  return value;
}

void fragment() {
  vec2 p = UV * period;
  float time = floor(TIME * timestep) / timestep * timescale;
  float flow_t0 = fract(time);
  float flow_t1 = fract(time + 0.5);
  float alternate = abs((flow_t0 - 0.5) * 2.0);
  float flow_p0 = floor(time);
  float flow_p1 = floor(time + 0.5);
  
//  vec2 dir = vec2((fbm(p + fbm(tile_offset/1000.)) / 2.), fbm((p + fbm(tile_offset/1000.))) / 2.);
  vec2 dir = vec2(fbm(p + fbm(tile_offset * period)), fbm(p + fbm(tile_offset * period))) * whirl;

//  dir += vec2(2., 0.);
  dir -= ((textureLod(TEXTURE, UV, 0.0) - 0.5) * 2.).xy;
  
  vec3 distortion1 = textureLod(texture, fract(UV * 3. + dir * flow_t0 * intensity), 0.0).rgb;
  vec3 distortion2 = textureLod(texture, fract(UV * 3. + dir * flow_t1 * intensity), 0.0).rgb;
  vec3 final = mix(distortion1, distortion2, (alternate + (noise(p) * .5 + .5)) / 2.);
//  vec3 final = mix(distortion1, distortion2, alternate);
  
  float height = length(final);
  vec3 color = high_color.rgb;
  if (height < 0.65) {
    color = mid_color.rgb;  
  }
  if (height < 0.55) {
    color = low_color.rgb;  
  }
  
  final = final * final * (3.0 - 2.0 * final);
 
//  final = vec3(tile_offset / 30., 0.); 

  COLOR = vec4(final, 1.0);
//  COLOR = vec4(dir * 0.5 + 0.5, 0.0, 1.0);
}