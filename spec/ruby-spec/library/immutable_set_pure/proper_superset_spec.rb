require_relative '../../../spec_helper'
require 'set'

describe "ImmutableSet::Pure#proper_superset?" do
  before :each do
    @set = ImmutableSet::Pure[1, 2, 3, 4]
  end

  it "returns true if passed a ImmutableSet::Pure that self is a proper superset of" do
    @set.proper_superset?(ImmutableSet::Pure[]).should be true
    ImmutableSet::Pure[1, 2, 3].proper_superset?(ImmutableSet::Pure[]).should be true
    ImmutableSet::Pure["a", "b", "c"].proper_superset?(ImmutableSet::Pure[]).should be true

    @set.proper_superset?(ImmutableSet::Pure[1, 2, 3]).should be true
    @set.proper_superset?(ImmutableSet::Pure[1, 3]).should be true
    @set.proper_superset?(ImmutableSet::Pure[1, 2]).should be true
    @set.proper_superset?(ImmutableSet::Pure[1]).should be true

    @set.proper_superset?(ImmutableSet::Pure[5]).should be false
    @set.proper_superset?(ImmutableSet::Pure[1, 5]).should be false
    @set.proper_superset?(ImmutableSet::Pure["test"]).should be false

    @set.proper_superset?(@set).should be false
    ImmutableSet::Pure[].proper_superset?(ImmutableSet::Pure[]).should be false
  end

  it "raises an ArgumentError when passed a non-ImmutableSet::Pure" do
    lambda { ImmutableSet::Pure[].proper_superset?([]) }.should raise_error(ArgumentError)
    lambda { ImmutableSet::Pure[].proper_superset?(1) }.should raise_error(ArgumentError)
    lambda { ImmutableSet::Pure[].proper_superset?("test") }.should raise_error(ArgumentError)
    lambda { ImmutableSet::Pure[].proper_superset?(Object.new) }.should raise_error(ArgumentError)
  end
end
