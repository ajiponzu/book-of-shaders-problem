#ifdef GL_ES
precision highp float;
#endif

uniform vec2 resolution;
uniform vec2 mouse;
uniform float time;

vec3 base_color = vec3(1.0, 0.995, 0.738);
//vec3 base_color = vec3(1.0, 1.0, 1.0);
vec3 palette1 = vec3(1.0, 0.0, 1.0);
vec3 palette2 = vec3(0.0, 1.0, 1.0);
vec3 palette3 = vec3(1.0, 1.0, 1.0);

//the book of shaders shape_2
//円を描画する関数
vec3 set_circle(vec3 rgb, float stretch, vec2 center, vec2 st)
{
  float pct = distance(st, center);
  pct = 1.0 - smoothstep(0.399 + stretch, 0.401 + stretch, pct);
  return pct * rgb;
}

void main(void)
{
  vec2 st = gl_FragCoord.xy / resolution.xy;
  float stretch = 0.1 * abs(sin(time * 4.0));
  float stretch2 = 0.1 * abs(cos(time * 8.0));
  vec3 color = set_circle(palette2, stretch, vec2(1.0), st)
            + set_circle(palette1, stretch2, vec2(0.5 + sin(time)), st);
  gl_FragColor = vec4(color, 1.0);
}