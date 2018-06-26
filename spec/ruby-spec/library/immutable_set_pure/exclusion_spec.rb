require_relative '../../../spec_helper'
require 'set'

describe "ImmutableSet::Pure#^" do
  before :each do
    @set = ImmutableSet::Pure[1, 2, 3, 4]
  end

  it "returns a new ImmutableSet::Pure containing elements that are not in both self and the passed Enumberable" do
    (@set ^ ImmutableSet::Pure[3, 4, 5]).should == ImmutableSet::Pure[1, 2, 5]
    (@set ^ [3, 4, 5]).should == ImmutableSet::Pure[1, 2, 5]
  end

  it "raises an ArgumentError when passed a non-Enumerable" do
    lambda { @set ^ 3 }.should raise_error(ArgumentError)
    lambda { @set ^ Object.new }.should raise_error(ArgumentError)
  end
end
