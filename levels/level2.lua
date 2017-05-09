return {
  width = 8,
  height = 8,
  next = 'level3',
  enemies = {
    {
      type = GridRandom,
      number = 4,
    },
    {
      type = GridChase,
      number = 1,
    },
  },
  blockThreshold = 0.093,
  lineThreshold = 0.33,
  -- seed = 1197219778692350
}
