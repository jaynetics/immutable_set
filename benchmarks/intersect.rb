require_relative './shared'

benchmark(
  method: :intersect?,
  caption: '#intersect? with 5M intersecting items',
  cases: {
    'stdlib'    => [S.new(250_000..2_750_000), S.new(2_000_000..5_000_000)],
    'gem'       => [I.new(250_000..2_750_000), I.new(2_000_000..5_000_000)],
    'gem w/o C' => [P.new(250_000..2_750_000), P.new(2_000_000..5_000_000)],
  }
)

benchmark(
  method: :intersect?,
  caption: '#intersect? with 5M sparse items (rare case?)',
  cases: {
    'stdlib'    => [S.new(250_000..2_750_000), S.new((10_000..20_000).to_a + (3_000_000..5_000_000).to_a)],
    'gem'       => [I.new(250_000..2_750_000), I.from_ranges(10_000..20_000, 3_000_000..5_000_000)],
    'gem w/o C' => [P.new(250_000..2_750_000), P.from_ranges(10_000..20_000, 3_000_000..5_000_000)],
  }
)

benchmark(
  method: :intersect?,
  caption: '#intersect? with 5M distinct items',
  cases: {
    'stdlib'    => [S.new(250_000..2_750_000), S.new(3_000_000..5_000_000)],
    'gem'       => [I.new(250_000..2_750_000), I.new(3_000_000..5_000_000)],
    'gem w/o C' => [P.new(250_000..2_750_000), P.new(3_000_000..5_000_000)],
  }
)
