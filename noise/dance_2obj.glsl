#ifdef GL_ES
precision highp float;
#endif

uniform vec2 u_resolution;
uniform float u_time;
uniform vec2 u_mouse;

mat2 rotate2d(float _angle){
  return mat2(cos(_angle),-sin(_angle),
              sin(_angle),cos(_angle));
}

vec3 MakeCircle(vec3 rgb, float rad, vec2 center, vec2 st)
{
  float pct = distance(st, center);
  pct = 1.0 - smoothstep(rad - 0.01, rad + 0.01, pct);
  return pct * rgb;
}

float box(in vec2 _st, in vec2 _size)
{
  _size = vec2(.5) - _size*.5;

  vec2 uv = smoothstep(_size,
                      _size+vec2(.001),
                      _st);

  uv *= smoothstep(_size,
                    _size+vec2(.001),
                    vec2(1.)-_st);

  return uv.x*uv.y;
}

float cross(in vec2 _st, float _size)
{
  return  box(_st, vec2(_size,_size/4.)) +
          box(_st, vec2(_size/4.,_size));
}

float rand(float x)
{
  return fract(sin(x)*100000.0);
}

float rand (vec2 st)
{
  return fract(sin(dot(st.xy,
          vec2(12.9898,78.233)))*
          43758.5453123);
}

void Dancing(in vec2 st)
{
  vec2 _st = st;

  _st = rotate2d(u_time) * (_st - .5);
  _st += .5;
  vec2 _st2 = _st + u_time;

  float ix = floor(_st2.x);
  float fx = fract(_st2.x);
  float randNumX = rand(ix);
  randNumX = mix(rand(ix), rand(ix + 1.0), smoothstep(0.,1.,fx));

  float iy = floor(_st2.y);
  float fy = fract(_st2.y);
  float randNumY = rand(iy);
  randNumY = mix(rand(iy), rand(iy + 1.0), smoothstep(0.,1.,fy));

  vec3 circle = MakeCircle(vec3(.5, .2, 1.), randNumX, vec2(clamp(randNumY, 0., 1.)), _st);

  vec3 color = vec3(randNumX);
  color = circle;
  color += vec3(cross(_st + vec2(randNumX, randNumY),randNumY));

  gl_FragColor = vec4(color,1.0);
}

void main()
{
  vec2 st = gl_FragCoord.xy/u_resolution.xy;
  Dancing(st);
}