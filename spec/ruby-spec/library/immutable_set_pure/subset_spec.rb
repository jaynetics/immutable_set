require_relative '../../../spec_helper'
require 'set'

describe "ImmutableSet::Pure#subset?" do
  before :each do
    @set = ImmutableSet::Pure[1, 2, 3, 4]
  end

  it "returns true if passed a ImmutableSet::Pure that is equal to self or self is a subset of" do
    @set.subset?(@set).should be true
    ImmutableSet::Pure[].subset?(ImmutableSet::Pure[]).should be true

    ImmutableSet::Pure[].subset?(@set).should be true
    ImmutableSet::Pure[].subset?(ImmutableSet::Pure[1, 2, 3]).should be true
    ImmutableSet::Pure[].subset?(ImmutableSet::Pure["a", "b", "c"]).should be true

    ImmutableSet::Pure[1, 2, 3].subset?(@set).should be true
    ImmutableSet::Pure[1, 3].subset?(@set).should be true
    ImmutableSet::Pure[1, 2].subset?(@set).should be true
    ImmutableSet::Pure[1].subset?(@set).should be true

    ImmutableSet::Pure[5].subset?(@set).should be false
    ImmutableSet::Pure[1, 5].subset?(@set).should be false
    ImmutableSet::Pure["test"].subset?(@set).should be false
  end

  it "raises an ArgumentError when passed a non-ImmutableSet::Pure" do
    lambda { ImmutableSet::Pure[].subset?([]) }.should raise_error(ArgumentError)
    lambda { ImmutableSet::Pure[].subset?(1) }.should raise_error(ArgumentError)
    lambda { ImmutableSet::Pure[].subset?("test") }.should raise_error(ArgumentError)
    lambda { ImmutableSet::Pure[].subset?(Object.new) }.should raise_error(ArgumentError)
  end
end
