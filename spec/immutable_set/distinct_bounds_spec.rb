shared_examples :immutable_set_distinct_bounds do |variant|
  it 'is true if either set is empty' do
    expect(variant[].distinct_bounds?(variant[1])).to be true
    expect(variant[1].distinct_bounds?(variant[])).to be true
  end

  it 'is true if either set is beyond the minmax boundaries of the other' do
    expect(variant[2, 4].distinct_bounds?(variant[5])).to be true
    expect(variant[5].distinct_bounds?(variant[2, 4])).to be true
  end

  it 'is false if the minmax boundaries of both sets intersect' do
    expect(variant[2, 4].distinct_bounds?(variant[3])).to be false
    expect(variant[3].distinct_bounds?(variant[2, 4])).to be false
  end

  it 'works with Strings' do
    expect(variant['a', 'd'].distinct_bounds?(variant['c'])).to be false
    expect(variant['a', 'd'].distinct_bounds?(variant['f'])).to be true
  end

  it 'works with (what used to be) Bignums' do
    big = 129**2
    expect(variant[big + 1, big + 3].distinct_bounds?(variant[big + 2])).to be false
    expect(variant[big + 1, big + 3].distinct_bounds?(variant[big + 5])).to be true
  end
end

describe "ImmutableSet#distinct_bounds?" do
  it_behaves_like :immutable_set_distinct_bounds, ImmutableSet
end

describe "ImmutableSet::Pure#distinct_bounds?" do
  it_behaves_like :immutable_set_distinct_bounds, ImmutableSet::Pure
end
