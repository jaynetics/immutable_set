require_relative '../../../spec_helper'
require 'set'

describe "ImmutableSet::Pure#proper_subset?" do
  before :each do
    @set = ImmutableSet::Pure[1, 2, 3, 4]
  end

  it "returns true if passed a ImmutableSet::Pure that self is a proper subset of" do
    ImmutableSet::Pure[].proper_subset?(@set).should be true
    ImmutableSet::Pure[].proper_subset?(ImmutableSet::Pure[1, 2, 3]).should be true
    ImmutableSet::Pure[].proper_subset?(ImmutableSet::Pure["a", "b", "c"]).should be true

    ImmutableSet::Pure[1, 2, 3].proper_subset?(@set).should be true
    ImmutableSet::Pure[1, 3].proper_subset?(@set).should be true
    ImmutableSet::Pure[1, 2].proper_subset?(@set).should be true
    ImmutableSet::Pure[1].proper_subset?(@set).should be true

    ImmutableSet::Pure[5].proper_subset?(@set).should be false
    ImmutableSet::Pure[1, 5].proper_subset?(@set).should be false
    ImmutableSet::Pure["test"].proper_subset?(@set).should be false

    @set.proper_subset?(@set).should be false
    ImmutableSet::Pure[].proper_subset?(ImmutableSet::Pure[]).should be false
  end

  it "raises an ArgumentError when passed a non-ImmutableSet::Pure" do
    lambda { ImmutableSet::Pure[].proper_subset?([]) }.should raise_error(ArgumentError)
    lambda { ImmutableSet::Pure[].proper_subset?(1) }.should raise_error(ArgumentError)
    lambda { ImmutableSet::Pure[].proper_subset?("test") }.should raise_error(ArgumentError)
    lambda { ImmutableSet::Pure[].proper_subset?(Object.new) }.should raise_error(ArgumentError)
  end
end
