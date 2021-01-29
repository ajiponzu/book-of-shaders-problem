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
vec3 set_circle(vec3 rgb, float rad, vec2 center, vec2 st)
{
  //円
  float pct = distance(st, center);

  //楕円, おそらく重心が二つあるから
  //ちなみに，完璧な楕円を描くには，smoothstepに指定する境界値の大きい方を, 重心間距離分だけ足しこむ必要がある．
//  pct = distance(st,vec2(center)) + distance(st,vec2(center + 0.2));

  //無駄にでかくなる．
//  pct = distance(st,vec2(center)) * distance(st,vec2(center));

  //円を二個描画できる, 二点のうち，距離の小さい方の点を中心とする．
//  pct = min(distance(st,vec2(center)),distance(st,vec2(center + 0.2)));

  //フットボール型の図形を描画, 二つの点を結ぶ線分の垂直二等分線を基準に，円弧をそれぞれ描く
  //距離が大きい方の円弧を採用するので，フットボール型になる．
//  pct = max(distance(st,vec2(center)),distance(st,vec2(center + 0.2)));
  
  //pow(x, n)はxのn乗を計算し，x=distance(st, a)を指定した場合，aを基準とした距離が拡大・縮小される
  //nもdistanceの場合，位置によって拡大率を変えることができる．
  //なお，distanceは0.0~1.0なので，nが大きくなるほどpowは小さくなる = 円内の領域が拡大される
//  pct = pow(distance(st,vec2(center)),distance(st,center + 2.0));
  
  //当然，距離が大きくなると，円内の領域は小さくなるので，想定より小さい円が描画される
//  pct = distance(st, center);

  //高速な円描画アルゴリズム, 円のベクトル方程式と内積を用いる |p|・|p| cos0 = |p|^2 = rad^2
  //distance内部では二乗和と平方根が用いられていると推測されるためできれば使用しない
  //ちなみにradで内積を割るのは，dot(p, p)が円内(円周上も含む)の点のベクトルの内積を示すなら，
  //dot(p, p) <= rad^2 < m^2と表せ，dot(p, p) / rad <= rad < m^2 / radが成り立つためである．
  //このようにしないと，想定より大きな円を描いてしまう．(小数なので)
  //また，上述の楕円などの式をこちらのアルゴリズムで描くと，ずれが生じる．
  //ただの円を描くときはこちらを使い，自由度を求めるなら負荷を覚悟して上述のアルゴリズムを用いる．
  vec2 p = st - center;
  pct = dot(p, p) / rad;
  
  //最終的に背景と図形を塗分ける．円を描くことを想定しているので，閾値は半径
  //smoothstep(~, ~, pct)だと背景色が白，円内が黒になる． 円の内部(中心距離 <= 半径), そこで，1.0から引いている.
  //また，smoothstepによって枠をきれいにしている．radは半径
  pct = 1.0 - smoothstep(rad - 0.01, rad + 0.01, pct);
  return pct * rgb;
}

void main(void)
{
  vec2 st = gl_FragCoord.xy / resolution.xy;
  
  //二つの円を振幅させ，かつ移動アニメーションも行う
  float rad = 0.1 + 0.1 * abs(sin(time * 4.0));
  float rad2 = 0.1 + 0.1 * abs(cos(time * 8.0));
  vec3 color = set_circle(palette2, rad, vec2(0.7), st)
            + set_circle(palette1, rad2, vec2(0.5 + sin(time)), st);
            
  
  gl_FragColor = vec4(color, 1.0);
}
