#ifdef VERTEX
vec4 position(mat4 transform_projection, vec4 vertex_position) {
  return transform_projection * vertex_position;
}
#endif

#ifdef PIXEL
vec4 effect(vec4 color, Image texture, vec2 tc, vec2 screen_coords) {
  float line_width = 0.05;

  // bottom-left
  vec2 bl = step(vec2(line_width), tc);
  float pct = bl.x * bl.y;

  // top-right
  vec2 tr = step(vec2(line_width), 1.0 - tc);
  pct *= tr.x * tr.y;

  return Texel(texture, tc) * color * vec4(vec3(1.0 - pct), 1.0);
}
#endif
