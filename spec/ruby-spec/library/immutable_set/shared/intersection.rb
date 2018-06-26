shared_examples :sorted_set_1_intersection do |method|
  before :each do
    @set = ImmutableSet["a", "b", "c"]
  end

  it "returns a new ImmutableSet containing only elements shared by self and the passed Enumerable" do
    @set.send(method, ImmutableSet["b", "c", "d", "e"]).should == ImmutableSet["b", "c"]
    @set.send(method, ["b", "c", "d"]).should == ImmutableSet["b", "c"]
  end

  it "raises an ArgumentError when passed a non-Enumerable" do
    lambda { @set.send(method, 1) }.should raise_error(ArgumentError)
    lambda { @set.send(method, Object.new) }.should raise_error(ArgumentError)
  end
end
