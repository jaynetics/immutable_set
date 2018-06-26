shared_examples :immutable_set_from_ranges do |variant|
  it 'fills the receiver with the numbers from all passed ranges' do
    expect(variant.from_ranges(2..3, 5..7)).to eq variant[2, 3, 5, 6, 7]
  end

  it 'inserts the elements in order, irrespective of the order of args' do
    hash = variant.from_ranges(5..7, 2..3).instance_variable_get(:@hash)
    expect(hash.first).to eq [2, true]
  end

  it 'sets a correct #max' do
    expect(variant.from_ranges(5..7, 2..3).max).to eq 7
  end

  it 'works with Strings' do
    result = variant.from_ranges('f'..'f', 'b'..'d')
    expect(result).to eq variant['b', 'c', 'd', 'f']
    expect(result.min).to eq 'b'
    expect(result.max).to eq 'f'
  end

  it 'works with (what used to be) Bignums' do
    big = 129**2
    result = variant.from_ranges((big + 5)..(big + 5), (big + 1)..(big + 3))
    expect(result).to eq variant[big + 1, big + 2, big + 3, big + 5]
    expect(result.min).to eq big + 1
    expect(result.max).to eq big + 5
  end
end

describe "ImmutableSet::from_ranges" do
  it_behaves_like :immutable_set_from_ranges, ImmutableSet
end

describe "ImmutableSet::Pure::from_ranges" do
  it_behaves_like :immutable_set_from_ranges, ImmutableSet::Pure
end
