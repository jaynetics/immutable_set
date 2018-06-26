require_relative './shared'

benchmark(
  method: :-,
  caption: '#- with 5M overlapping items',
  cases: {
    'stdlib'    => [S.new(250_000..2_750_000), S.new(1_000_000..4_000_000)],
    'gem'       => [I.new(250_000..2_750_000), I.new(1_000_000..4_000_000)],
    'gem w/o c' => [P.new(250_000..2_750_000), P.new(1_000_000..4_000_000)],
  }
)

benchmark(
  method: :-,
  caption: '#- with 5M distinct items',
  cases: {
    'stdlib'    => [S.new(250_000..2_750_000), S.new(3_000_000..5_000_000)],
    'gem'       => [I.new(250_000..2_750_000), I.new(3_000_000..5_000_000)],
    'gem w/o c' => [P.new(250_000..2_750_000), P.new(3_000_000..5_000_000)],
  }
)
