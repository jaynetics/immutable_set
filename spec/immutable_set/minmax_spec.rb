shared_examples :immutable_set_minmax do |variant|
  it 'is [nil, nil] for an empty set' do
    expect(variant[].minmax).to eq [nil, nil]
  end

  it 'is correct for a set built with ::[]' do
    expect(variant[1, 2, 3].minmax).to eq [1, 3]
  end

  it 'is correct for a set built from an Array' do
    expect(variant.new([2, 3, 1]).minmax).to eq [1, 3]
  end

  it 'is correct for a set built from a Range' do
    expect(variant.new(1..3).minmax).to eq [1, 3]
  end

  it 'is correct for a set built from another ImmutableSet' do
    expect(variant.new(variant[1, 2, 3]).minmax).to eq [1, 3]
  end

  it 'is correct for a set with just one member' do
    expect(variant[1].minmax).to eq [1, 1]
  end

  it 'is correct after #+ (union)' do
    expect((variant[1] + variant[3]).minmax).to eq [1, 3]
  end

  it 'is correct after #- (difference)' do
    expect((variant[1, 2, 3] - variant[3]).minmax).to eq [1, 2]
  end

  it 'is correct after #& (intersection)' do
    expect((variant[1, 2, 3] & variant[1, 2]).minmax).to eq [1, 2]
  end

  it 'is correct after #^ (exclusion)' do
    expect((variant[1, 2, 3] ^ variant[3]).minmax).to eq [1, 2]
  end
end

describe "ImmutableSet#minmax" do
  it_behaves_like :immutable_set_minmax, ImmutableSet
end

describe "ImmutableSet::Pure#minmax" do
  it_behaves_like :immutable_set_minmax, ImmutableSet::Pure
end
