shader_type canvas_item;

uniform float time_step = 8.;
uniform float timescale = 1.;

uniform vec4 color1 : hint_color;
uniform vec4 color2 : hint_color;
uniform vec4 color3 : hint_color;
uniform vec4 color4 : hint_color;

uniform float threshold1 = 0.375;
uniform float threshold2 = 0.55;
uniform float threshold3 = 0.625;

uniform float scale = 12.;
uniform vec2 tile_offset = vec2(0.);
uniform int octaves = 8;

float random (vec2 p) {
  p = mod(p, scale);
  return fract(sin(dot(p.xy, vec2(12.98989,78.233))) * 43758.5453123);
}

float noise (vec2 p) {
    // something magic happens here, and 4.0 is the magic number
    p *= scale;
    p /= 4.;
    vec2 i = floor(p);
    vec2 f = fract(p);

    // Four corners in 2D of a tile
    float a = random(i);
    float b = random(i + vec2(1.0, 0.0));
    float c = random(i + vec2(0.0, 1.0));
    float d = random(i + vec2(1.0, 1.0));

    // Smooth Interpolation

    // Cubic Hermine Curve.  Same as SmoothStep()
    vec2 u = f*f*(3.0-2.0*f);
    // u = smoothstep(0.,1.,f);

    // Mix 4 coorners percentages
    return mix(a, b, u.x) +
            (c - a)* u.y * (1.0 - u.x) +
            (d - b) * u.x * u.y;
}

float fbm (vec2 p) {
    // Initial values
    float value = 0.0;
    float amplitude = .5;
    float frequency = 0.;
    //
    // Loop of octaves
    for (int i = 0; i < octaves; i++) {
        value += amplitude * abs(noise(p));
        p *= 2.;
        amplitude *= .5;
    }
    return value;
}

void fragment() {
  vec2 p = (UV + random(tile_offset)) * scale; 
  float time = floor(TIME * time_step) / time_step * timescale;
//  time += sqrt(tile_offset.x * tile_offset.x + tile_offset.y * tile_offset.y);
//  time += random(tile_offset) * scale;
  
  vec2 distortion = (textureLod(TEXTURE, UV, 0.0).rg - 0.5) * -2.0;
  
  vec2 p1 = p + distortion * time * 0.75;
  vec2 p2 = p + distortion * time * 0.875;
  vec2 p3 = p + distortion * time * 0.125;
  
  float height = fbm(p1 /*+ fbm(p2) /*+ fbm(p3)*/);
  height = mix(height, fbm(p2), 0.5);
  vec3 color = color1.rgb;
  
  if (height > threshold3) {
    color = color4.rgb;
  }
  else if (height > threshold2) {
    color = color3.rgb;
  }
  else if (height > threshold1) {
    color = color2.rgb;
  }
  
  COLOR = vec4(color, 1.0);
}