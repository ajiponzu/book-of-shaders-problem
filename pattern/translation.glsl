#ifdef GL_ES
precision highp float;
#endif

uniform vec2 u_resolution;
uniform vec2 u_mouse;
uniform float u_time;

//長方形を描画，xとyのサイズを調整することで，形状だけでなく横転，直立させることができる
//bar.glslのset_barとやっていることは同じ，vec2を用いているのでコード量を削減できる
float box(in vec2 _st, in vec2 _size){
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
float cross(in vec2 _st, float _size){
  //同一の高さ・横をもつ正方形ではない長方形を直行させる
  //x, yごとにthicknessの値を変えている．
  //そうしなければ正方形を重ねてしまう
  return  box(_st, vec2(_size,_size/4.)) +
          box(_st, vec2(_size/4.,_size));
}

void main(){
  vec2 st = gl_FragCoord.xy/u_resolution.xy;
  vec3 color = vec3(.0);

  // To move the cross we move the space
  //振り子
  //等速円運動の速度の公式．
  //振り子において，y方向はx方向の半分の値域なのでabsを使用
  //あくまで平行移動の変化量としての速度であることに注意
  vec2 translate = vec2(cos(u_time), abs(sin(u_time)));

  //蛇行運動，xとyに速度差をつければよい
  translate = vec2(cos(u_time * 2.), sin(u_time * .25));


  //平行移動
  st += translate * .5;

  // Show the coordinates of the space on the background
  color = vec3(st.x,st.y,.0);

  // Add the shape on the foreground
  color += vec3(cross(st,.25));

  gl_FragColor = vec4(color,.0);
}
