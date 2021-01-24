#ifdef GL_ES
precision mediump float;
#endif

uniform vec2 u_resolution;
uniform vec2 u_mouse;
uniform float u_time;

vec3 base_color = vec3(0.970,0.938,0.867);
vec3 palette1 = vec3(0.750,0.132,0.003);
vec3 palette2 = vec3(1.000,0.824,0.215);
vec3 palette3 = vec3(0.215,0.364,0.910);

//the book of shaders shape_1
//特定の位置，特定の幅で棒線を描画する関数
float set_bar(vec2 thick, vec2 pos, vec2 st)
{
  float left = step(pos.x, st.x);
  float right = 1.0 - step(pos.x + thick.x, st.x);
  float bottom = step(pos.y, st.y);
  float top = 1.0 - step(pos.y + thick.y, st.y);
  return 1.0 - left * right * bottom * top;
}

vec3 set_color(vec3 palette, vec2 thick, vec2 pos, vec2 st) {
  float left = step(pos.x, st.x);
    float right = 1.0 - step(pos.x + thick.x, st.x);
    float bottom = step(pos.y, st.y);
    float top = 1.0 - step(pos.y + thick.y, st.y);
    return mix(base_color, palette, left * right * bottom * top);
}

void main(void)
{
  vec2 st = gl_FragCoord.xy / u_resolution.xy;
  float pct = set_bar(vec2(0.03, 0.4), vec2(0.05, 0.6), st)
    * set_bar(vec2(0.03, 1.0), vec2(0.93, 0.0), st)
    * set_bar(vec2(0.03, 1.0), vec2(0.75,0.0), st)
    * set_bar(vec2(0.03, 1.0), vec2(0.2, 0.0), st)
    * set_bar(vec2(1.0, 0.03), vec2(0.0, 0.6), st)
    * set_bar(vec2(0.8, 0.03), vec2(0.2, 0.05), st)
    * set_bar(vec2(1.0, 0.03), vec2(0.0, 0.8), st); 
  vec3 color = vec3(pct) 
    * set_color(palette1, vec2(0.2, 0.37), vec2(0.0, 0.63), st)
    * set_color(palette2, vec2(0.04, 0.37), vec2(0.96, 0.63), st) * set_color(palette3, vec2(0.22, 0.05), vec2(0.78, 0.0), st);
  gl_FragColor = vec4(color, 1.0);
}
