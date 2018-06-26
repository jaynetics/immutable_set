require_relative '../../../spec_helper'
require 'set'

describe "ImmutableSet#each" do
  before :each do
    @set = ImmutableSet[1, 2, 3]
  end

  it "yields each Object in self in sorted order" do
    ret = []
    ImmutableSet["one", "two", "three"].each { |x| ret << x }
    ret.should == ["one", "two", "three"].sort
  end

  it "returns self" do
    @set.each { |x| x }.should equal(@set)
  end

  it "returns an Enumerator when not passed a block" do
    enum = @set.each

    ret = []
    enum.each { |x| ret << x }
    ret.sort.should == [1, 2, 3]
  end
end
