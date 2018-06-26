require_relative '../../../spec_helper'
require 'set'

describe "ImmutableSet::Pure#classify" do
  before :each do
    @set = ImmutableSet::Pure["one", "two", "three", "four"]
  end

  it "yields each Object in self in sorted order" do
    res = []
    @set.classify { |x| res << x }
    res.should == ["one", "two", "three", "four"].sort
  end

  it "returns an Enumerator when passed no block" do
    enum = @set.classify
    enum.should be_an_instance_of(Enumerator)

    classified = enum.each { |x| x.length }
    classified.should == { 3 => ImmutableSet::Pure["one", "two"], 4 => ImmutableSet::Pure["four"], 5 => ImmutableSet::Pure["three"] }
  end

  it "classifies the Objects in self based on the block's return value" do
    classified = @set.classify { |x| x.length }
    classified.should == { 3 => ImmutableSet::Pure["one", "two"], 4 => ImmutableSet::Pure["four"], 5 => ImmutableSet::Pure["three"] }
  end
end
