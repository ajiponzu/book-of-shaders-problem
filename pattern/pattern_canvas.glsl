#ifdef GL_ES
precision mediump float;
#endif

uniform vec2 u_resolution;
uniform vec2 u_mouse;
uniform float u_time;

mat2 scale(vec2 _scale){
    return mat2(_scale.x,0.0,
                0.0,_scale.y);
}

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
  _st *= _gridSize;
  return fract(_st * _gridSize);
}

//所定位置を塗りつぶす
//args...
//  rgb: 塗りつぶす色
//  _st: グリッド空間の座標
//  _gridPos: 所定位置
vec3 Draw(in vec3 rgb, in vec2 _st, in vec2 _gridPos)
{
  return rgb * step(_gridPos.x, _st.x) * step(_gridPos.y, _st.y)
            * (1. - step(_gridPos.x + 1., _st.x))
            * (1. - step(_gridPos.y + 1., _st.y));
}

//レイヤを作成する
//
vec3 MakeLayerType1(in vec3 _color, in vec2 _baseBox, in float _gridSize)
{
  vec3 layer = vec3(.0);
  vec2 _st = _baseBox * _gridSize;
  layer += Draw(_color, _st, vec2(.0));
  layer += Draw(_color, _st, vec2(1.));
  layer += Draw(_color, _st, vec2(2.));
  return layer;
}

vec3 MakeLayerType2(in vec3 _color, in vec2 _baseBox, in float _gridSize)
{
  vec3 layer = vec3(.0);
  vec2 _st = _baseBox * _gridSize;
  layer += Draw(_color, _st, vec2(1., .0));
  layer += Draw(_color, _st, vec2(2., 1.));
  layer += Draw(_color, _st, vec2(0., 2.));
  return layer;
}

vec3 MakeLayerType2BaseWhite(in vec3 _color, in vec2 _baseBox, in float _gridSize)
{
  vec3 layer = vec3(.0);
  vec2 _st = _baseBox * _gridSize;
  vec3 _revC = Reverse(_color);
  layer += Draw(_revC, _st, vec2(1., .0));
  layer += Draw(_revC, _st, vec2(2., 1.));
  layer += Draw(_revC, _st, vec2(0., 2.));
  return Reverse(layer);
}

vec3 MixLayersByRed(in vec3 _layer1, in vec3 _layer2)
{
  //二値化によって線形補間に用いる定数を作成
  //レイヤを完全な形で併合できる
  float compR = step(_layer1.r, _layer2.r);

  return mix(_layer1, _layer2, compR);
}

vec3 MixLayersByGreen(in vec3 _layer1, in vec3 _layer2)
{
  float compG = step(_layer1.g, _layer2.g);

  return mix(_layer1, _layer2, compG);
}

vec3 MixLayersByBlue(in vec3 _layer1, in vec3 _layer2)
{
  float compB = step(_layer1.b, _layer2.b);

  return mix(_layer1, _layer2, compB);
}

vec3 MixLayersByRG(in vec3 _layer1, in vec3 _layer2)
{
  float compRG = step(_layer1.r + _layer1.g, _layer2.r + _layer2.g);

  return mix(_layer1, _layer2, compRG);
}

vec3 MixLayersByGB(in vec3 _layer1, in vec3 _layer2)
{
  float compGB = step(_layer1.g + _layer1.b, _layer2.g + _layer2.b);

  return mix(_layer1, _layer2, compGB);
}

vec3 MixLayersByBR(in vec3 _layer1, in vec3 _layer2)
{
  float compBR = step(_layer1.b + _layer1.r, _layer2.b + _layer2.r);

  return mix(_layer1, _layer2, compBR);
}

const vec3 red = vec3(1., .0, .0);
const vec3 lemmon = vec3(.84, .94, .35);
const vec3 white = vec3(1., 1., 1.);
const vec3 black = vec3(.0, .0, .0);

//キャンバスを作成する
//キャンバス: 仮想的な画面をそう呼ぶことにする
//レイヤもそう呼ぶが，キャンバスはレイヤを重ねたものと考えるものとする
//なお，MakeLayerTypeの都合上，_gridSizeは3以下を推奨する
//パターンを細かくしたい場合は内部のパターンの分割サイズを変更する
vec3 CreateCanvasType1(in vec2 _baseBox, float _gridSize)
{
  //パターンを細かくする
  _baseBox = Pattern(_baseBox, 2.73);
  _baseBox = Pattern(_baseBox, 2.1);

  //レイヤを作成する
  vec3 layer1 = MakeLayerType1(red, _baseBox, _gridSize);
  vec3 layer2 = MakeLayerType2(lemmon, _baseBox, _gridSize);
  return MixLayersByRed(layer1, layer2);
}

void main()
{
  vec2 st = gl_FragCoord.xy / u_resolution;
  vec3 color = vec3(.0, .0, .0);

  vec2 baseBox = st;
  vec3 canvas = CreateCanvasType1(baseBox, 3.);
  color += Draw(canvas, baseBox * 3., vec2(1.));
  color += Draw(canvas, baseBox * 3., vec2(2., 1.));
  color += MakeLayerType1(canvas, Pattern(baseBox, 1.73) , 3.);

  gl_FragColor = vec4(color, 1.);
}