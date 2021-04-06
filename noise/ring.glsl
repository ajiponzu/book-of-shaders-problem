#ifdef GL_ES
precision highp float;
#endif

uniform vec2 u_resolution;
uniform float u_time;
uniform vec2 u_mouse;

//写経した擬似乱数生成関数
//ブロックノイズというらしい
float random (in vec2 st) {
    return fract(sin(dot(st.xy,
                         vec2(12.9898,78.233)))
                 * 43758.5453123);
}

//ランダムな4点を作るらしい
//グラディエントノイズというらしい
float noise (in vec2 st) {
    vec2 i = floor(st);
    vec2 f = fract(st); //パターン化

    float a = random(i);
    float b = random(i + vec2(1., 0.));
    float c = random(i + vec2(0., 1.));
    float d = random(i + vec2(1., 1.));

    vec2 u = f*f*(3. - 2. * f);

    return mix(a, b, u.x) +
            (c - a)* u.y * (1.0 - u.x) +
            (d - b) * u.x * u.y;
}

void main() {
    vec2 st = gl_FragCoord.xy/u_resolution.xy;

    //時間による乱数・ノイズの作成
    vec2 pos = vec2(st * 10. * 10000.);

    float n = noise(pos) * .01; //半径に収まるようなオフセットにするために * .01をしている
    float dst = distance(st, vec2(.5)); //円のディスタンス
    //円のディスタンスフィールド，ノイズをオフセットとし，輪郭をにじませる
    //オフセットを使わない場合もたいして変わらず環っかが表示される．しかし，ノイズによって鉛筆で書いたような味がでる
    float pct = smoothstep(.41, .32, dst + n) * smoothstep(.3, .31, dst + n);
    gl_FragColor = vec4(vec3(pct), 1.);
}
