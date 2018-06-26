require_relative '../../../spec_helper'
require 'set'

describe "ImmutableSet#empty?" do
  it "returns true if self is empty" do
    ImmutableSet[].empty?.should be true
    ImmutableSet[1].empty?.should be false
    ImmutableSet[1,2,3].empty?.should be false
  end
end
