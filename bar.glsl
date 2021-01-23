#ifdef GL_ES
precision mediump float;
#endif

uniform vec2 u_resolution;
uniform vec2 u_mouse;
uniform float u_time;

//the book of shaders shape_1
//特定の位置，特定の幅で棒線を描画する関数
float get_pct(vec2 thick, vec2 pos, vec2 st)
{
  float left = step(pos.x, st.x);
  float right = 1.0 - step(pos.x + thick.x, st.x);
  float bottom = step(pos.y, st.y);
  float top = 1.0 - step(pos.y + thick.y, st.y);
  return 1.0 - left * right * bottom * top;
}

void main(void)
{
  vec2 st = gl_FragCoord.xy / u_resolution.xy;
  float pct = get_pct(vec2(0.05, 1), vec2(0.1, 0.0), st);
  pct *= get_pct(vec2(0.05, 1.0), vec2(0.8, 0.0), st);
  pct *= get_pct(vec2(1.0, 0.05), vec2(0.0, 0.5), st);
  vec3 color = vec3(pct) * vec3(1.0 - st.y, 1.0, 1.0 - st.x);
  gl_FragColor = vec4(color, 1.0);
}