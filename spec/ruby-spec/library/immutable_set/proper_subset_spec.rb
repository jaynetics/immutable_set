require_relative '../../../spec_helper'
require 'set'

describe "ImmutableSet#proper_subset?" do
  before :each do
    @set = ImmutableSet[1, 2, 3, 4]
  end

  it "returns true if passed a ImmutableSet that self is a proper subset of" do
    ImmutableSet[].proper_subset?(@set).should be true
    ImmutableSet[].proper_subset?(ImmutableSet[1, 2, 3]).should be true
    ImmutableSet[].proper_subset?(ImmutableSet["a", "b", "c"]).should be true

    ImmutableSet[1, 2, 3].proper_subset?(@set).should be true
    ImmutableSet[1, 3].proper_subset?(@set).should be true
    ImmutableSet[1, 2].proper_subset?(@set).should be true
    ImmutableSet[1].proper_subset?(@set).should be true

    ImmutableSet[5].proper_subset?(@set).should be false
    ImmutableSet[1, 5].proper_subset?(@set).should be false
    ImmutableSet["test"].proper_subset?(@set).should be false

    @set.proper_subset?(@set).should be false
    ImmutableSet[].proper_subset?(ImmutableSet[]).should be false
  end

  it "raises an ArgumentError when passed a non-ImmutableSet" do
    lambda { ImmutableSet[].proper_subset?([]) }.should raise_error(ArgumentError)
    lambda { ImmutableSet[].proper_subset?(1) }.should raise_error(ArgumentError)
    lambda { ImmutableSet[].proper_subset?("test") }.should raise_error(ArgumentError)
    lambda { ImmutableSet[].proper_subset?(Object.new) }.should raise_error(ArgumentError)
  end
end
