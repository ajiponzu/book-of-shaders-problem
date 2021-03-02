#ifdef GL_ES
precision highp float;
#endif

#define PI 3.14159265359
#define TWO_PI 6.28318530718

uniform vec2 resolution;
uniform vec2 mouse;
uniform float time;

//円を描画する関数
vec3 set_circle(vec3 rgb, float rad, vec2 center, vec2 st)
{
  vec2 p = st - center;
  float pct = dot(p, p) / rad;
  pct = smoothstep(rad + .5, rad - .009, pct);
  return pct * rgb;
}

//正多角形を描画するためのディスタンスフィールドを返す
//N:頂点数, shrink: 縮小率, role: 回転位置
float ret_regular_polygon(float N, vec2 center, float shrink, float role, vec2 st) {
  vec2 pos = st - center;
  //極座標の取得
  float theta = atan(pos.x, pos.y)+role;
  float r = length(pos);
  //中心角2πをN等分する
  float alpha = TWO_PI / N;
  return cos(floor(.5+theta/alpha)*alpha-theta)*r * shrink;
}

void main(){
  vec2 st = gl_FragCoord.xy/ resolution.xy;
  vec2 center = vec2(.5);

  //三角形と逆三角形を組み合わせたディスタンスフィールド，魔法陣
  float triangle1 = ret_regular_polygon(3., center, 3.8, .0, st);
  float triangle2 = ret_regular_polygon(3., center, 3.8, PI, st);
  float d_min = min(fract(triangle1), fract(triangle2));

  //瞳を描く
  vec3 eye1 = set_circle(vec3(0., 1., 1.), .01, center, st);
  vec3 eye2 = set_circle(vec3(.5, .1, .4), .3, center, st);

  //円形のディスタンスフィールドも作成．
  float r = length(st - center);
  d_min = max(d_min, r * 1.1);

  vec3 color = vec3(smoothstep(.41 + .5 * abs(tan(time / 2.)), .4, d_min));

  gl_FragColor = vec4(color * vec3(.2, .5, .7) * d_min + eye1 + eye2,1.);
}
