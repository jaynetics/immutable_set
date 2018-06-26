require_relative './shared'

# distinct case is extremely fast both w. gem and stdlib
# (except on Ruby < 2.3, where the gem is much faster)

benchmark(
  method: :subset?,
  caption: '#(proper_)subset/superset? with 5M subset items',
  cases: {
    'stdlib'    => [S.new(1..4_900_000), S.new(1..5_000_000)],
    'gem'       => [I.new(1..4_900_000), I.new(1..5_000_000)],
    'gem w/o C' => [P.new(1..4_900_000), P.new(1..5_000_000)],
  }
)

benchmark(
  method: :subset?,
  caption: '#(proper_)subset/superset? with 5M overlapping items',
  cases: {
    'stdlib'    => [S.new(1..4_900_000), S.new((1..4_900_001).to_a - [4_800_000])],
    'gem'       => [I.new(1..4_900_000), I.from_ranges(1..4_799_999, 4_800_001..4_900_001)],
    'gem w/o C' => [P.new(1..4_900_000), P.from_ranges(1..4_799_999, 4_800_001..4_900_001)],
  }
)

benchmark(
  method: :subset?,
  caption: '#(proper_)subset/superset? with 100k overlapping items',
  cases: {
    'stdlib'    => [S.new(1..99_000), S.new((1..99_001).to_a - [90_000])],
    'gem'       => [I.new(1..99_000), I.from_ranges(1..89_999, 90_001..99_001)],
    'gem w/o C' => [P.new(1..99_000), P.from_ranges(1..89_999, 90_001..99_001)],
  }
)
