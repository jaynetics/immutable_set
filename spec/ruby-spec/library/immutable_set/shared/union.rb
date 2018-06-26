shared_examples :sorted_set_1_union do |method|
  before :each do
    @set = ImmutableSet["a", "b", "c"]
  end

  it "returns a new ImmutableSet containing all elements of self and the passed Enumerable" do
    @set.send(method, ImmutableSet["b", "d", "e"]).should == ImmutableSet["a", "b", "c", "d", "e"]
    @set.send(method, ["b", "e"]).should == ImmutableSet["a", "b", "c", "e"]
  end

  it "raises an ArgumentError when passed a non-Enumerable" do
    lambda { @set.send(method, 1) }.should raise_error(ArgumentError)
    lambda { @set.send(method, Object.new) }.should raise_error(ArgumentError)
  end
end
