require_relative '../../../spec_helper'
require 'set'

describe "ImmutableSet#superset?" do
  before :each do
    @set = ImmutableSet[1, 2, 3, 4]
  end

  it "returns true if passed a ImmutableSet that equals self or self is a proper superset of" do
    @set.superset?(@set).should be true
    ImmutableSet[].superset?(ImmutableSet[]).should be true

    @set.superset?(ImmutableSet[]).should be true
    ImmutableSet[1, 2, 3].superset?(ImmutableSet[]).should be true
    ImmutableSet["a", "b", "c"].superset?(ImmutableSet[]).should be true

    @set.superset?(ImmutableSet[1, 2, 3]).should be true
    @set.superset?(ImmutableSet[1, 3]).should be true
    @set.superset?(ImmutableSet[1, 2]).should be true
    @set.superset?(ImmutableSet[1]).should be true

    @set.superset?(ImmutableSet[5]).should be false
    @set.superset?(ImmutableSet[1, 5]).should be false
    @set.superset?(ImmutableSet["test"]).should be false
  end

  it "raises an ArgumentError when passed a non-ImmutableSet" do
    lambda { ImmutableSet[].superset?([]) }.should raise_error(ArgumentError)
    lambda { ImmutableSet[].superset?(1) }.should raise_error(ArgumentError)
    lambda { ImmutableSet[].superset?("test") }.should raise_error(ArgumentError)
    lambda { ImmutableSet[].superset?(Object.new) }.should raise_error(ArgumentError)
  end
end
