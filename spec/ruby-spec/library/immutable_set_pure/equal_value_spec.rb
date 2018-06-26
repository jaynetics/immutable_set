require_relative '../../../spec_helper'
require 'set'

describe "ImmutableSet::Pure#==" do
  it "returns true when the passed Object is a ImmutableSet::Pure and self and the Object contain the same elements" do
    ImmutableSet::Pure[].should == ImmutableSet::Pure[]
    ImmutableSet::Pure[1, 2, 3].should == ImmutableSet::Pure[1, 2, 3]
    ImmutableSet::Pure["1", "2", "3"].should == ImmutableSet::Pure["1", "2", "3"]

    ImmutableSet::Pure[1, 2, 3].should_not == ImmutableSet::Pure[1.0, 2, 3]
    ImmutableSet::Pure[1, 2, 3].should_not == [1, 2, 3]
  end
end
