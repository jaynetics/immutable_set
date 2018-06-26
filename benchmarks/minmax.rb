require_relative './shared'

benchmark(
  method: :minmax,
  caption: '#minmax with 10M items',
  cases: {
    'stdlib'    => S.new(0...10_000_000),
    'gem'       => I.new(0...10_000_000),
    'gem w/o C' => P.new(0...10_000_000),
  }
)

benchmark(
  method: :minmax,
  caption: '#minmax with 1M items',
  cases: {
    'stdlib'    => S.new(0...1_000_000),
    'gem'       => I.new(0...1_000_000),
    'gem w/o C' => P.new(0...1_000_000),
  }
)
