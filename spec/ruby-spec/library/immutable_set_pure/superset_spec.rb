require_relative '../../../spec_helper'
require 'set'

describe "ImmutableSet::Pure#superset?" do
  before :each do
    @set = ImmutableSet::Pure[1, 2, 3, 4]
  end

  it "returns true if passed a ImmutableSet::Pure that equals self or self is a proper superset of" do
    @set.superset?(@set).should be true
    ImmutableSet::Pure[].superset?(ImmutableSet::Pure[]).should be true

    @set.superset?(ImmutableSet::Pure[]).should be true
    ImmutableSet::Pure[1, 2, 3].superset?(ImmutableSet::Pure[]).should be true
    ImmutableSet::Pure["a", "b", "c"].superset?(ImmutableSet::Pure[]).should be true

    @set.superset?(ImmutableSet::Pure[1, 2, 3]).should be true
    @set.superset?(ImmutableSet::Pure[1, 3]).should be true
    @set.superset?(ImmutableSet::Pure[1, 2]).should be true
    @set.superset?(ImmutableSet::Pure[1]).should be true

    @set.superset?(ImmutableSet::Pure[5]).should be false
    @set.superset?(ImmutableSet::Pure[1, 5]).should be false
    @set.superset?(ImmutableSet::Pure["test"]).should be false
  end

  it "raises an ArgumentError when passed a non-ImmutableSet::Pure" do
    lambda { ImmutableSet::Pure[].superset?([]) }.should raise_error(ArgumentError)
    lambda { ImmutableSet::Pure[].superset?(1) }.should raise_error(ArgumentError)
    lambda { ImmutableSet::Pure[].superset?("test") }.should raise_error(ArgumentError)
    lambda { ImmutableSet::Pure[].superset?(Object.new) }.should raise_error(ArgumentError)
  end
end
