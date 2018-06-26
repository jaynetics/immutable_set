shared_examples :sorted_set_2_difference do |method|
  before :each do
    @set = ImmutableSet::Pure["a", "b", "c"]
  end

  it "returns a new ImmutableSet::Pure containing self's elements excluding the elements in the passed Enumerable" do
    @set.send(method, ImmutableSet::Pure["a", "b"]).should == ImmutableSet::Pure["c"]
    @set.send(method, ["b", "c"]).should == ImmutableSet::Pure["a"]
  end

  it "raises an ArgumentError when passed a non-Enumerable" do
    lambda { @set.send(method, 1) }.should raise_error(ArgumentError)
    lambda { @set.send(method, Object.new) }.should raise_error(ArgumentError)
  end
end
