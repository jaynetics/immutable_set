require_relative './shared'

benchmark(
  caption: '::new with 5M Range items',
  cases: {
    'stdlib'    => ->{ S.new(0...5_000_000) },
    'gem'       => ->{ I.new(0...5_000_000) },
    'gem w/o C' => ->{ P.new(0...5_000_000) },
  }
)

benchmark(
  caption: '::new with 100k Range items',
  cases: {
    'stdlib'    => ->{ S.new(0...100_000) },
    'gem'       => ->{ I.new(0...100_000) },
    'gem w/o C' => ->{ P.new(0...100_000) },
  }
)

prep_ranges = [
  0...1000, 1001...2001, 2002...3002, 3003...4003, 4004...5004, 5005...5006,
  6006...6007, 7007...7008, 8008...8009, 9009...9010, 10_010...11_010
]
benchmark(
  caption: '::new with 10k Range items in 10 non-continuous Ranges',
  cases: {
    'stdlib'    => ->{ set = S.new; prep_ranges.each { |r| set.merge(r) } },
    'gem'       => ->{ I.from_ranges(*prep_ranges) },
    'gem w/o C' => ->{ P.from_ranges(*prep_ranges) },
  }
)
