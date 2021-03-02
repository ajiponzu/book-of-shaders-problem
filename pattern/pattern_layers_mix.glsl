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
  _st *= _gridSize;
  return fract(_st * _gridSize);
}

vec3 Draw(in vec3 rgb, in vec2 _st, in vec2 _gridPos)
{
  return rgb * step(_gridPos.x, _st.x) * step(_gridPos.y, _st.y)
            * (1. - step(_gridPos.x + 1., _st.x))
            * (1. - step(_gridPos.y + 1., _st.y));
}

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

void main()
{
  vec2 st = gl_FragCoord.xy / u_resolution;
  vec3 color = vec3(.0, .0, .0);

  vec2 baseBox = st;

  //格子数
  float gridSize = 3.;
  //基本パターン作成後，以下をコメントアウトすることで複製
  baseBox = Pattern(baseBox, 1.73);
//  baseBox = Pattern(baseBox, 2.);

  vec3 layer1 = MakeLayerType2(red, baseBox, gridSize);
  vec3 layer2 = MakeLayerType1(lemmon, baseBox, gridSize);
//  layer1 += Draw(layer2, baseBox * gridSize, vec2(1.0));
  color += MixLayersByRed(layer1, layer2);

  gl_FragColor = vec4(color, 1.);
}