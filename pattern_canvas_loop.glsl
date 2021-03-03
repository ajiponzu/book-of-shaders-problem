#ifdef GL_ES
precision mediump float;
#endif

uniform vec2 u_resolution;
uniform vec2 u_mouse;
uniform float u_time;

//色を反転する
// args...
//  rgb: 反転対象の色ベクトル
// return: 反転後の色ベクトル
vec3 Reverse(in vec3 rgb)
{
  return 1. - rgb;
}

//パターンベクトルを返す
//args...
//  _gridSize: 格子の個数の平方根
vec2 Pattern(vec2 _st, in float _gridSize)
{
//  _st *= _gridSize;
  return fract(_st * _gridSize);
}

//所定位置を塗りつぶす
//args...
//  rgb: 塗りつぶす色
//  _st: グリッド空間の座標
//  _gridPos: 所定位置
vec3 Draw(in vec3 rgb, in vec2 _st, float _gridSize, in vec2 _gridPos)
{
  _st *= _gridSize;
  return rgb * step(_gridPos.x, _st.x) * step(_gridPos.y, _st.y)
            * (1. - step(_gridPos.x + 1., _st.x))
            * (1. - step(_gridPos.y + 1., _st.y));
}

///レイヤを作成する
//全グリッド単色
vec3 MakeLayerOneColor(in vec3 _color, in vec2 _baseBox, in float _gridSize)
{
  vec3 layer = vec3(.0);

  float i, j;
  for (j = .0; j < 3; j += 1.)
    for (i = .0; i < 3; i += 1.)
      layer += Draw(_color, _baseBox, _gridSize, vec2(i, j));

  return layer;
}

vec3 MakeLayerType1(in vec3 _color, in vec2 _baseBox, in float _gridSize)
{
  vec3 layer = vec3(.0);

  float i;
  for (i = .0; i < 3; i += 1.)
    layer += Draw(_color, _baseBox, _gridSize, vec2(i));

  return layer;
}

vec3 MakeLayerType2(in vec3 _color1, in vec3 _color2, in vec2 _baseBox, in float _gridSize)
{
  vec3 layer = vec3(.0);

  float i;
  for (i = .0; i < 3; i += 1.)
    layer += Draw(_color1, _baseBox, _gridSize, vec2(i));

  layer += Draw(_color2, _baseBox, _gridSize, vec2(.0, 1.));
  layer += Draw(_color2, _baseBox, _gridSize, vec2(1., .0));
  layer += Draw(_color2, _baseBox, _gridSize, vec2(2., .0));
  layer += Draw(_color2, _baseBox, _gridSize, vec2(2., 1.));

  return layer;
}

vec3 MakeLayerType3(in vec3 _color1, in vec3 _color2, in vec2 _baseBox, in float _gridSize)
{
  vec3 layer = vec3(.0);

  float i, j;
  for (i = .0; i < 3; i += 1.)
    layer += Draw(_color1, _baseBox, _gridSize, vec2(i, .0));

  for (j = 1.; j < 3; j += 1.)
    for (i = .0; i < 3; i += 1.)
      layer += Draw(_color2, _baseBox, _gridSize, vec2(i, j));

  return layer;
}

const vec3 red = vec3(1., .0, .0);
const vec3 blue = vec3(.0, .0, 1.);
const vec3 white = vec3(1., 1., 1.);
const vec3 black = vec3(.0, .0, .0);

//キャンバスを作成する
//キャンバス: 仮想的な画面をそう呼ぶことにする
//レイヤもそう呼ぶが，キャンバスはレイヤを塗り分けたものと考える
vec3 CreateCanvas01_1(in vec2 _baseBox)
{
  //パターン
  vec2 baseBox = Pattern(_baseBox, 3.);

  //キャンバスを作成する
  //今回はレイヤをそのまま複製した
  vec3 canvas = MakeLayerType1(white, baseBox, 3.);
  return canvas;
}

//キャンバスを数種類のレイヤで塗り分ける
//手順はあまり一種類のときと変わらない
//パターン化し，その座標を用いて複数のレイヤを作成
//その後，変換前座標を用いて塗り分け
vec3 CreateCanvas01_2(in vec2 _baseBox)
{
  vec3 canvas = vec3(.0);
  //パターン化
  vec2 baseBox = Pattern(_baseBox, 3.);

  //レイヤを作成
  vec3 layer1 = MakeLayerType1(white, baseBox, 3.);
  vec3 layer2 = MakeLayerType2(white, blue, baseBox, 3.);

  //分割数とレイヤ作成時の分割数は異なってもよいが，パターン化の分割数は同じである
  canvas = MakeLayerType3(layer2, layer1, _baseBox, 3.);

  return canvas;
}

//新たなキャンバスを作成し，別のキャンバスをレイヤとして塗り分ける
vec3 CreateCanvas01_3(in vec2 _baseBox)
{
  vec3 canvas = vec3(.0);
  //パターン化
  vec2 baseBox = Pattern(_baseBox, 3.);

  //レイヤを作成, 今回はキャンバスをレイヤとする
  //よってパターン化した座標を渡す
  vec3 layer1 = CreateCanvas01_1(baseBox);
  vec3 layer2 = CreateCanvas01_2(baseBox);

  //塗り分け
  float i;
  for (i = 1.; i < 3.; i += 1.)
  {
    canvas += Draw(layer1, _baseBox, 3., vec2(.0, i));
    canvas += Draw(layer1, _baseBox, 3., vec2(2., i));
  }
  for (i = .0; i < 3.; i += 2.)
    canvas += Draw(layer2, _baseBox, 3., vec2(i, .0));

  return canvas;
}

void main()
{
  vec2 st = gl_FragCoord.xy / u_resolution;
  vec3 color = vec3(.0, .0, .0);

  vec2 _st = Pattern(st, 4.);
  color = CreateCanvas01_1(st);
  color = CreateCanvas01_2(st);
  //上記は過程
  //キャンバス，レイヤを塗り分ける際は，
  //上記の過程でできた画面をパターン化し，
  //最終的などの格子にも描画できる用意をする必要がある
  //つまり以下
  color = CreateCanvas01_1(Pattern(st, 3.));
  color = CreateCanvas01_2(Pattern(st, 3.));
  color = CreateCanvas01_3(st);

  gl_FragColor = vec4(color, 1.);
}