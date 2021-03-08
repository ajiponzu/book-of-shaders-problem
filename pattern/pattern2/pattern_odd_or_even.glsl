#ifdef GL_ES
precision mediump float;
#endif

uniform vec2 u_resolution;
uniform float u_time;

vec2 brickTile(vec2 _st, float _zoom){
  _st *= _zoom;

  _st.x += step(1., mod(_st.y,2.)) * .5;

  return fract(_st);
}

vec2 BrickTileY(vec2 _st, float _zoom){
  _st *= _zoom;

  _st.y += step(1., mod(_st.x,2.)) * .5;

  return fract(_st);
}

float box(vec2 _st, vec2 _size){
  _size = vec2(.5)-_size*.5;
  vec2 uv = smoothstep(_size,_size+vec2(1e-4),_st);
  uv *= smoothstep(_size,_size+vec2(1e-4),vec2(1.)-_st);
  return uv.x*uv.y;
}

float circle(vec2 _st, float _radius){
    vec2 pos = vec2(0.5)-_st;
    return smoothstep(1.0-_radius,1.0-_radius+_radius*0.2,1.-dot(pos,pos)*3.14);
}

void main(void){
  vec2 st = gl_FragCoord.xy/u_resolution.xy;
  vec3 color = vec3(0.);
  float tileSize = 4;

  //0行から数えるものとする
  //奇数行(ただし，正確には剰余が1以上(つまり1.0~1.999...の範囲)のみスライド
//  st.x += step(1., mod(st.y * tileSize, 2.)) * u_time;
  //偶数行のみスライド
//  st.x += step(mod(st.y * tileSize, 2.), 1.) * u_time;
  //ちなみに両方コメントアウトすると両方スライドする
  //(+=で，しかもオフセットは等しい(片方の式で0になるため))
  //以下はスライド方向が変わる例 (偶数: 左, 奇数: 右)
  //引くと右にスライド, 足すと左にスライド
  //なお，タイル化のサイズを元の座標に掛けてから2の剰余を求める
//  st.x -= step(1., mod(st.y * tileSize, 2.)) * u_time;
//  st.x += step(mod(st.y * tileSize, 2.), 1.) * u_time;

  //x方向にずれたレンガ模様を作る
  //アニメーションさせる場合は，レンガ化する前に足しこむ(fractで返ってくるので)
//  vec2 _st = brickTile(st,2.);


  //0列から数えるものとする
  //奇数列のみスライド
//  st.y += step(1., mod(st.x * tileSize, 2.)) * u_time;
  //偶数列のみスライド
//  st.y += step(mod(st.x * tileSize, 2.), 1.) * u_time;
  //両方コメントアウトで両方スライド
  //以下は方向をそれぞれ変える例
  //引くと上にスライド, 足すと下にスライド
  //行スライドとの対応(引くと座標あ値の大きい方へスライド, 足すと小さい方へスライド)
  st.y -= step(1., mod(st.x * tileSize, 2.)) * u_time;
  st.y += step(mod(st.x * tileSize, 2.), 1.) * u_time;

  //y方向にずれたレンガ模様を作る
  vec2 _st = BrickTileY(st, tileSize);

  //パターンごとの模様を決定する
//  color = vec3(box(_st,vec2(.9)));
  color = vec3(circle(_st, .25));

  //レンガ模様
//  color = vec3(st,0.0);

  gl_FragColor = vec4(color,1.);
}
