shared_examples :sorted_set_2_intersection do |method|
  before :each do
    @set = ImmutableSet::Pure["a", "b", "c"]
  end

  it "returns a new ImmutableSet::Pure containing only elements shared by self and the passed Enumerable" do
    @set.send(method, ImmutableSet::Pure["b", "c", "d", "e"]).should == ImmutableSet::Pure["b", "c"]
    @set.send(method, ["b", "c", "d"]).should == ImmutableSet::Pure["b", "c"]
  end

  it "raises an ArgumentError when passed a non-Enumerable" do
    lambda { @set.send(method, 1) }.should raise_error(ArgumentError)
    lambda { @set.send(method, Object.new) }.should raise_error(ArgumentError)
  end
end
