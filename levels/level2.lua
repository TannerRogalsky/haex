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
  seed = nil
}
