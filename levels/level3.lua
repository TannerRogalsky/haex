return {
  width = 16,
  height = 16,
  next = 'level4',
  enemies = {
    {
      type = GridRandom,
      number = 2,
    },
    {
      type = GridChase,
      number = 1,
    },
    {
      type = FreeChase,
      number = 1,
    },
  },
  blockThreshold = 0.11,
  lineThreshold = 0.39,
  seed = 7687291852685312
}
