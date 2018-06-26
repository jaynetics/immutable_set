shared_examples :set_without_mutating_methods do |variant|
  %w[
    <<
    add
    add?
    clear
    clone
    collect!
    delete
    delete_if
    delete?
    dup
    flatten!
    keep_if
    map!
    merge
    reject!
    replace
    reset
    select!
    subtract
  ].each do |method|
    it "does not respond to the method ##{method}" do
      expect(variant.new).not_to respond_to(method)
    end
  end

  it 'raises a helpful error when a disabled method is called' do
    expect { variant.new.add(42) }
      .to raise_error(NoMethodError, /#add can't be called on an ImmutableSet/)
  end
end

describe ImmutableSet do
  it_behaves_like :set_without_mutating_methods, ImmutableSet
end

describe ImmutableSet::Pure do
  it_behaves_like :set_without_mutating_methods, ImmutableSet::Pure
end
