require_relative '../../../spec_helper'
require 'set'

describe "ImmutableSet#subset?" do
  before :each do
    @set = ImmutableSet[1, 2, 3, 4]
  end

  it "returns true if passed a ImmutableSet that is equal to self or self is a subset of" do
    @set.subset?(@set).should be true
    ImmutableSet[].subset?(ImmutableSet[]).should be true

    ImmutableSet[].subset?(@set).should be true
    ImmutableSet[].subset?(ImmutableSet[1, 2, 3]).should be true
    ImmutableSet[].subset?(ImmutableSet["a", "b", "c"]).should be true

    ImmutableSet[1, 2, 3].subset?(@set).should be true
    ImmutableSet[1, 3].subset?(@set).should be true
    ImmutableSet[1, 2].subset?(@set).should be true
    ImmutableSet[1].subset?(@set).should be true

    ImmutableSet[5].subset?(@set).should be false
    ImmutableSet[1, 5].subset?(@set).should be false
    ImmutableSet["test"].subset?(@set).should be false
  end

  it "raises an ArgumentError when passed a non-ImmutableSet" do
    lambda { ImmutableSet[].subset?([]) }.should raise_error(ArgumentError)
    lambda { ImmutableSet[].subset?(1) }.should raise_error(ArgumentError)
    lambda { ImmutableSet[].subset?("test") }.should raise_error(ArgumentError)
    lambda { ImmutableSet[].subset?(Object.new) }.should raise_error(ArgumentError)
  end
end
