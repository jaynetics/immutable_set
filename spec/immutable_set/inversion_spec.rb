shared_examples :immutable_set_inversion do |variant|
  it 'returns a set with ints upto `upto` not in the original set' do
    expect(variant[2, 4].inversion(from: 0, upto: 5))
      .to eq variant[0, 1, 3, 5]
  end

  it 'is equal to self ^ new(from..upto)' do
    expect(variant[2, 4].inversion(from: 0, upto: 5))
      .to eq variant[2, 4] ^ variant.new(0..5)
  end

  it 'returns an empty set if from..upto is covered' do
    expect(variant.new(1..10).inversion(from: 6, upto: 8))
      .to eq variant[]
  end

  it 'is equal to new(from..upto) for empty sets' do
    expect(variant.new.inversion(from: 6, upto: 8))
      .to eq variant.new(6..8)
  end

  it 'sets a correct #max if upto is below the old maximum' do
    expect(variant[9].inversion(from: 6, upto: 8).max).to eq 8
  end

  it 'sets a correct #max if upto equals the old maximum' do
    expect(variant[8].inversion(from: 6, upto: 8).max).to eq 7
  end

  it 'sets a correct #max if upto is beyond the old maximum' do
    expect(variant[7].inversion(from: 6, upto: 8).max).to eq 8
  end

  it 'works with Strings' do
    expect(variant['c', 'e'].inversion(from: 'a', upto: 'f'))
      .to eq variant['a', 'b', 'd', 'f']
  end

  it 'works with (what used to be) Bignums' do
    big = 2**129
    expect(variant[big + 1, big + 3].inversion(from: big, upto: big + 4))
      .to eq variant[big, big + 2, big + 4]
  end

  it 'inserts invalid unicode codepoints by default' do
    result = variant.new.inversion(from: 0xC000, upto: 0xE000)
    expect(result).to eq variant.new(0xC000..0xE000)
  end

  it 'does not insert invalid unicode codepoints if `ucp_only` is true' do
    result = variant.new.inversion(from: 0xC000, upto: 0xE000, ucp_only: true)
    expect(result).to eq variant.new((0xC000..0xD7FF).to_a + [0xE000])
  end
end

describe "ImmutableSet#inversion" do
  it_behaves_like :immutable_set_inversion, ImmutableSet
end

describe "ImmutableSet::Pure#inversion" do
  it_behaves_like :immutable_set_inversion, ImmutableSet::Pure
end
