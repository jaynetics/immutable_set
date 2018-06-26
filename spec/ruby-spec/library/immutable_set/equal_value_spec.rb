require_relative '../../../spec_helper'
require 'set'

describe "ImmutableSet#==" do
  it "returns true when the passed Object is a ImmutableSet and self and the Object contain the same elements" do
    ImmutableSet[].should == ImmutableSet[]
    ImmutableSet[1, 2, 3].should == ImmutableSet[1, 2, 3]
    ImmutableSet["1", "2", "3"].should == ImmutableSet["1", "2", "3"]

    ImmutableSet[1, 2, 3].should_not == ImmutableSet[1.0, 2, 3]
    ImmutableSet[1, 2, 3].should_not == [1, 2, 3]
  end
end
