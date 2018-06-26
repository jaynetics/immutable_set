require_relative './shared'

prep_5m = I.new(250_000..2_750_000)
prep_5m_pure = P.new(250_000..2_750_000)

prep_100k = I.new(25_000..75_000)
prep_100k_pure = P.new(25_000..75_000)

benchmark(
  method: :inversion,
  caption: '#inversion with 5M items',
  cases: {
    'gem'       => ->{ prep_5m.inversion(from: 0, upto: 5_000_000) },
    'gem w/o C' => ->{ prep_5m_pure.inversion(from: 0, upto: 5_000_000) },
    'stdlib #-' => ->{ Set.new(0..5_000_000) - prep_5m },
  }
)

benchmark(
  method: :inversion,
  caption: '#inversion with 100k items',
  cases: {
    'gem'       => ->{ prep_100k.inversion(from: 0, upto: 100_000) },
    'gem w/o C' => ->{ prep_100k_pure.inversion(from: 0, upto: 100_000) },
    'stdlib #-' => ->{ Set.new(0..100_000) - prep_100k },
  }
)
