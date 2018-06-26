require_relative '../../../spec_helper'
require 'set'

describe "ImmutableSet::Pure#eql?" do
  it "returns true when the passed argument is a ImmutableSet::Pure and contains the same elements" do
    ImmutableSet::Pure[].should eql(ImmutableSet::Pure[])
    ImmutableSet::Pure[1, 2, 3].should eql(ImmutableSet::Pure[1, 2, 3])
    ImmutableSet::Pure[1, 2, 3].should eql(ImmutableSet::Pure[3, 2, 1])

#    ImmutableSet::Pure["a", :b, ?c].should eql(ImmutableSet::Pure[?c, :b, "a"])

    ImmutableSet::Pure[1, 2, 3].should_not eql(ImmutableSet::Pure[1.0, 2, 3])
    ImmutableSet::Pure[1, 2, 3].should_not eql(ImmutableSet::Pure[2, 3])
    ImmutableSet::Pure[1, 2, 3].should_not eql(ImmutableSet::Pure[])
  end
end
