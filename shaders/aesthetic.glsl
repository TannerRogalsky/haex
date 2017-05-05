
#ifdef VERTEX
vec4 position(mat4 transform_projection, vec4 vertex_position) {
  return transform_projection * vertex_position;
}
#endif

#ifdef PIXEL
extern float elapsed;
extern Image noiseTexture;
extern float blockThreshold, lineThreshold;
extern float radialScale, radialBreathingScale;
extern float randomShiftScale;
extern float screenTransitionRatio;

vec2 radialDistortion(vec2 coord, float dist) {
  vec2 cc = coord - 0.5;
  dist = dot(cc, cc * radialScale) * dist + cos(elapsed * .3) * radialBreathingScale;
  return (coord + cc * (1.0 + dist) * dist);
}

vec4 effect(vec4 color, Image tex, vec2 uv, vec2 pc) {
  vec2 block = floor(gl_FragCoord.xy / (love_ScreenSize.xy / vec2(64.0)));
  vec2 uv_noise = block / vec2(64.0);
  uv_noise += floor(vec2(elapsed) * vec2(1234.0, 3543.0)) / vec2(64.0);

  float block_thresh = pow(fract(elapsed * 1236.0453), 2.0) * blockThreshold;
  float line_thresh = pow(fract(elapsed * 2236.0453), 3.0) * lineThreshold;

  // if (Texel(noiseTexture, uv_noise).g < block_thresh)
    // uv.x += sin(uv.y * 3.14 * 4.0 + elapsed) * 0.01;
  uv.x += fract(sin(uv.y * 12000.0 + elapsed)) * randomShiftScale;

  vec2 uv_r = uv, uv_g = uv, uv_b = uv;

  // glitch some blocks and lines
  if (Texel(noiseTexture, uv_noise).r < block_thresh ||
    Texel(noiseTexture, vec2(uv_noise.y, 0.0)).g < line_thresh) {

    vec2 dist = (fract(uv_noise) - 0.5) * 0.3;
    uv_r += dist * 0.1;
    uv_g += dist * 0.2;
    uv_b += dist * 0.125;
  }

  uv_r = radialDistortion(uv_r, .24)  + vec2(.001, 0);
  uv_g = radialDistortion(uv_g, .20);
  uv_b = radialDistortion(uv_b, .16) - vec2(.001, 0);
  vec4 res = vec4(Texel(tex, uv_r).r, Texel(tex, uv_g).g, Texel(tex, uv_b).b, 1)
    - cos(uv_g.y * 128. * 3.142 * 2) * .01
    - sin(uv_g.x * 128. * 3.142 * 2) * .01;

  vec4 outColor = res * Texel(tex, uv_g).a;

  // loose luma for some blocks
  if (Texel(noiseTexture, uv_noise).g < block_thresh)
    outColor.rgb = outColor.ggg;

  // discolor block lines
  if (Texel(noiseTexture, vec2(uv_noise.y, 0.0)).b * 3.5 < line_thresh)
    outColor.rgb = vec3(0.0, dot(outColor.rgb, vec3(1.0)), 0.0);

  // interleave lines in some blocks
  if (Texel(noiseTexture, uv_noise).g * 1.5 < block_thresh ||
    Texel(noiseTexture, vec2(uv_noise.y, 0.0)).g * 2.5 < line_thresh) {
    float line = fract(gl_FragCoord.y / 3.0);
    vec3 mask = vec3(3.0, 0.0, 0.0);
    if (line > 0.333)
      mask = vec3(0.0, 3.0, 0.0);
    if (line > 0.666)
      mask = vec3(0.0, 0.0, 3.0);

    outColor.xyz *= mask;
  }

  outColor.a = (1.0 - screenTransitionRatio);

  return outColor;
}
#endif
