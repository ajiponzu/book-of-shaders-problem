#ifdef GL_ES
precision highp float;
#endif

#define PI 3.14159265359

uniform vec2 resolution;
uniform vec2 mouse;
uniform float time;

//拡大・縮小行列を返す
mat2 scale(vec2 _scale)
{
  return mat2(_scale.x,0.0,
              0.0,_scale.y);
}

//回転行列を返す
mat2 rotate2d(float _angle){
  return mat2(cos(_angle),-sin(_angle),
              sin(_angle),cos(_angle));
}

//長方形を描画，xとyのサイズを調整することで，形状だけでなく横転，直立させることができる
//bar.glslのset_barとやっていることは同じ，vec2を用いているのでコード量を削減できる
float box(in vec2 _st, in vec2 _size)
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
float cross(in vec2 _st, float _size)
{
  //同一の高さ・横をもつ正方形ではない長方形を直行させる
  //x, yごとにthicknessの値を変えている．
  //そうしなければ正方形を重ねてしまう
  return  box(_st, vec2(_size,_size/4.)) +
          box(_st, vec2(_size/4.,_size));
}

float circle(in vec2 _st, in float _radius)
{
  vec2 l = _st-vec2(0.5);
  return 1.-smoothstep(_radius-(_radius*0.01),
                       _radius+(_radius*0.01),
                       dot(l,l)*4.0);
}

//パターンベクトルを返す
//args...
//  _gridSize: 格子の個数の平方根
vec2 pattern(in vec2 _st, in float _gridSize)
{
  return vec2(fract(_st * _gridSize));
}

//×マークを格子の好きな位置の中心に描画する(ある意味変換関数)
//args...
//  _grid: 変換前座標
//  _st: 変換前座標*gridSizeした(fractはかけていない)座標
//  _gridPos: 0~2の範囲でvec2(x, y)によって行と位置を指定
vec3 noSign(in vec2 _grid, in vec2 _st, in vec2 _gridPos)
{
  //十字架を45°だけ回転した座標をもとに描くことで×マークを描画
  vec3 no = vec3(cross(rotate2d(PI/4.) * (_grid - .5) + .5, .5));
  //stepによって，描く格子を指定
  return no * step(_gridPos.x, _st.x) * step(_gridPos.y, _st.y)
            * (1. - step(_gridPos.x + 1., _st.x)) * (1. - step(_gridPos.y + 1., _st.y));
}

//〇マークを格子の好きな位置の中心に描画する(ある意味変換関数)
//args...
//  _grid: 変換前座標
//  _st: 変換前座標*gridSizeした(fractはかけていない)座標
//  _gridPos: 0~2の範囲でvec2(x, y)によって行と位置を指定
vec3 okSign(in vec2 _grid, in vec2 _st, in vec2 _gridPos)
{
  //外円を通常通りに描く，内円は色を反転させる．
  //積の結果，AND演算と同様に，共に1の輪郭が白く描画される
  vec3 ok = vec3(circle(_grid, .3)) * (1. - vec3(circle(_grid, .2)));
  //stepによって，描く格子を指定
  return ok * step(_gridPos.x, _st.x) * step(_gridPos.y, _st.y)
            * (1. - step(_gridPos.x + 1., _st.x)) * (1. - step(_gridPos.y + 1., _st.y));
}

//〇×入れ替え
//args...
//  cycle: 入れ替えの周期関数
//  _grid: 変換前座標
//  _st: 変換前座標*gridSizeした(fractはかけていない)座標
//  _gridPos: 0~2の範囲でvec2(x, y)によって行と位置を指定
vec3 switchTwoSign(in float cycle, in vec2 _grid, in vec2 _st, in vec2 _gridPos)
{
  return mix(noSign(_grid, _st, _gridPos), okSign(_grid, _st, _gridPos), cycle);
}

void main()
{
  vec2 st = gl_FragCoord.xy / resolution.xy;

  //格子数
  float gridSize = 3.;

  //背景のみ回転
  vec2 back = pattern(st, gridSize);
  back -= .5;
  back = rotate2d(cos(time)) * back;
  back += .5;

  //格子形成
  vec3 color = vec3(pattern(st, gridSize), .0);
    color += noSign(color.xy, st * 3., vec2(floor(cos(time)), 2.));

    color += okSign(color.xy, st * 3., vec2(floor(tan(time)), 1.));

  //図形ベクトルを加算していくことで図形を同時に表示
  color += switchTwoSign(abs(cos(time * .4)), color.xy, st * 3., vec2(1., .0));

  //背景と前景(図形)をマージ
  color.xy += back;

  gl_FragColor = vec4(color,.0);
}
