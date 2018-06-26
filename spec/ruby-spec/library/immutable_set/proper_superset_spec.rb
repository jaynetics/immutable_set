require_relative '../../../spec_helper'
require 'set'

describe "ImmutableSet#proper_superset?" do
  before :each do
    @set = ImmutableSet[1, 2, 3, 4]
  end

  it "returns true if passed a ImmutableSet that self is a proper superset of" do
    @set.proper_superset?(ImmutableSet[]).should be true
    ImmutableSet[1, 2, 3].proper_superset?(ImmutableSet[]).should be true
    ImmutableSet["a", "b", "c"].proper_superset?(ImmutableSet[]).should be true

    @set.proper_superset?(ImmutableSet[1, 2, 3]).should be true
    @set.proper_superset?(ImmutableSet[1, 3]).should be true
    @set.proper_superset?(ImmutableSet[1, 2]).should be true
    @set.proper_superset?(ImmutableSet[1]).should be true

    @set.proper_superset?(ImmutableSet[5]).should be false
    @set.proper_superset?(ImmutableSet[1, 5]).should be false
    @set.proper_superset?(ImmutableSet["test"]).should be false

    @set.proper_superset?(@set).should be false
    ImmutableSet[].proper_superset?(ImmutableSet[]).should be false
  end

  it "raises an ArgumentError when passed a non-ImmutableSet" do
    lambda { ImmutableSet[].proper_superset?([]) }.should raise_error(ArgumentError)
    lambda { ImmutableSet[].proper_superset?(1) }.should raise_error(ArgumentError)
    lambda { ImmutableSet[].proper_superset?("test") }.should raise_error(ArgumentError)
    lambda { ImmutableSet[].proper_superset?(Object.new) }.should raise_error(ArgumentError)
  end
end
