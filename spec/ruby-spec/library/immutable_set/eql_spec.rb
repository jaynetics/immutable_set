require_relative '../../../spec_helper'
require 'set'

describe "ImmutableSet#eql?" do
  it "returns true when the passed argument is a ImmutableSet and contains the same elements" do
    ImmutableSet[].should eql(ImmutableSet[])
    ImmutableSet[1, 2, 3].should eql(ImmutableSet[1, 2, 3])
    ImmutableSet[1, 2, 3].should eql(ImmutableSet[3, 2, 1])

#    ImmutableSet["a", :b, ?c].should eql(ImmutableSet[?c, :b, "a"])

    ImmutableSet[1, 2, 3].should_not eql(ImmutableSet[1.0, 2, 3])
    ImmutableSet[1, 2, 3].should_not eql(ImmutableSet[2, 3])
    ImmutableSet[1, 2, 3].should_not eql(ImmutableSet[])
  end
end
