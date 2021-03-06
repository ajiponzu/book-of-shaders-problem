#ifdef GL_ES
precision highp float;
#endif

uniform vec2 resolution;
uniform vec2 mouse;
uniform float time;

//glslにおける疑似乱数
float rand(vec2 p) {
  return fract(sin(dot(p, vec2(12.9898, 78.233)) * 43758.5453));
}

//描きたいグラフの関数を，0=~の形に式変形してやる．この式の右辺を
//pに代入する．smoothstepの二つの閾値の幅が狭いほど細い線を描くことができる．
float plot(float p) {
  return smoothstep(.03 , .0, abs(p));
}

void main(){
  vec2 st = gl_FragCoord.xy/resolution.xy;
  vec3 color = vec3(.0);

  vec2 pos = st - vec2(.5);

  float r = length(pos)*2.;
  float theta = atan(pos.y,pos.x);

  //三角関数と極座標の組み合わせにより，角度に応じて塗りつぶす範囲を変化させる
  float rad = cos((theta * 3.));

  //距離が負になる場合, 0として扱うが，大きさは0ではない．よって絶対値を使用することで，塗りつぶす範囲を拡大
  rad = abs(cos(theta * 2.));
  //桜の花
  rad = abs(cos(theta*2.5))*.5+.3;
  //雪の結晶
//  rad = abs(cos(theta*12.)*sin(theta*3.))*.8+.1;
  //歯車
//  rad = smoothstep(-.5,1., cos(theta*10.))*0.2+0.5;

  //回転アニメーション，一定間隔で逆回転
//  rad = abs(cos((theta * 3.) + cos(time) * 10.));

  //通常図形, ちなみにstepと異なり，smoothstepは閾値を二つ設定できるので，
  //本来，smoothstep(a, b, r)の場合，a < bだが，a > bとすることで，結果を反転することができる．
//  color = vec3(smoothstep(rad+.02, rad, r));

  //型抜き図形，上の形から縮小図形型に型抜く
  color = vec3(smoothstep(rad+.02, rad, r) * smoothstep(rad-.2, rad, r));
//  color = vec3((1.-smoothstep(rad,rad+.02,r)) * smoothstep(rad - .1, rad, r));
//  color = vec3((1. - step(rad, r)) * step(rad - .1, r));
  //radとrがほぼ一致するようなピクセルのみ描画すると，枠線のみ残る
  //枠線外の場合，plotによって0が帰ってくるので，枠線のみ残すようにくり抜く．
  color = vec3(smoothstep(rad+.02, rad, r) * plot(rad - r));
  gl_FragColor = vec4(color, 1.);

  //smoothstepによって輪郭がぼやける．
  //ぼやける範囲をcos, tanとtimeによってコントロールすることで，明滅アニメーションを実装
//  color = vec3(smoothstep(rad+cos(tan(time)), rad,r) * smoothstep(rad-.2, rad, r));
//  vec2 red = vec2(abs(tan(time)));
//  vec2 green = vec2(abs(sin(time)));
//  vec2 blue = vec2(abs(cos(time)));
//
//  gl_FragColor = vec4(color + vec3(rand(red), rand(green), rand(blue)), 1.);
}
