return {
  width = 16,
  height = 16,
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
  seed = nil
}
