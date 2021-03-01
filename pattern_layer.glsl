#ifdef GL_ES
precision highp float;
#endif

#define PI 3.14159265359

uniform vec2 u_resolution;
uniform vec2 u_mouse;
uniform float u_time;

//拡大・縮小行列を返す
mat2 Scale(vec2 _scale)
{
  return mat2(_scale.x,0.0,
              0.0,_scale.y);
}

//回転行列を返す
mat2 Rotate2d(float _angle){
  return mat2(cos(_angle),-sin(_angle),
              sin(_angle),cos(_angle));
}

//長方形を描画，xとyのサイズを調整することで，形状だけでなく横転，直立させることができる
//bar.glslのset_barとやっていることは同じ，vec2を用いているのでコード量を削減できる
float Box(in vec2 _st, in vec2 _size)
{
  //thickness，細長い長方形になるように調整している
  _size = vec2(.5) - _size*.5;

  //left, bottom
  vec2 uv = smoothstep(_size,
                      _size+vec2(.001),
                      _st);
  //right, top
  uv *= smoothstep(_size,
                    _size+vec2(.001),
                    vec2(1.)-_st);

  return uv.x*uv.y;
}

//十字型を描画
float Cross(in vec2 _st, float _size)
{
  //同一の高さ・横をもつ正方形ではない長方形を直行させる
  //x, yごとにthicknessの値を変えている．
  //そうしなければ正方形を重ねてしまう
  return  Box(_st, vec2(_size,_size/4.)) +
          Box(_st, vec2(_size/4.,_size));
}

float Circle(in vec2 _st, in float _radius)
{
  vec2 l = _st-vec2(0.5);
  return 1.-smoothstep(_radius-(_radius*0.01),
                       _radius+(_radius*0.01),
                       dot(l,l)*4.0);
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
            * (1. - step(_gridPos.x + 1., _st.x)) * (1. - step(_gridPos.y + 1., _st.y));
}

vec3 Reverse(in vec3 rgb)
{
  return 1. - rgb;
}

const vec3 red = vec3(1., .0, .0);
const vec3 white = vec3(1., 1., 1.);
const vec3 black = vec3(.0, .0, .0);

void main()
{
  vec2 st = gl_FragCoord.xy/u_resolution.xy;
  vec3 color = vec3(.0, .0, .0);

  vec3 baseColor = black;

  vec2 baseBox = st;
//  baseBox = Rotate2d(PI * 0.02) * baseBox;

  //格子数
  float gridSize = 3.;
  //基本パターン作成後，以下をコメントアウトすることで複製
//  baseBox = Pattern(baseBox, gridSize);

  //対角線上に赤
//  vec3 temp = Draw(red, baseBox * gridSize, vec2(.0));
//  temp += Draw(red, baseBox * gridSize, vec2(1.));
//  temp += Draw(red, baseBox * gridSize, vec2(2.));
//  color += max(baseColor, temp);


  //対角に白
//  vec3 temp2 = Draw(white, baseBox * gridSize, vec2(.0));
//  temp2 += Draw(white, baseBox * gridSize, vec2(1.));
//  temp2 += Draw(white, baseBox * gridSize, vec2(2.));
//  color += max(temp2, baseColor);

  //パターン化した色を，rgbのどの二つに入れるかで最終的な色が決まる．
  vec3 temp3 = vec3(.0, Pattern(baseBox, gridSize));
  vec3 temp4 = Draw(white, baseBox * gridSize, vec2(.0));
  //パターン化したキャンバスのうちの1マスを，さらにパターン化・細分化したキャンバスを色として塗る
  temp4 += Draw(temp3, baseBox * gridSize, vec2(1.));
  temp4 += Draw(white, baseBox * gridSize, vec2(2.));
  color += max(temp4, baseColor);

//  color = vec3(pattern(st, gridSize), .5);
//  color = vec3(pattern(st, gridSize), .5);

  gl_FragColor = vec4(color, 1.);
}