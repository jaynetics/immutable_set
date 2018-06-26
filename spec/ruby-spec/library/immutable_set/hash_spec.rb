require_relative '../../../spec_helper'
require 'set'

describe "ImmutableSet#hash" do
  it "is static" do
    ImmutableSet[].hash.should == ImmutableSet[].hash
    ImmutableSet[1, 2, 3].hash.should == ImmutableSet[1, 2, 3].hash
    ImmutableSet["a", "b", "c"].hash.should == ImmutableSet["c", "b", "a"].hash

    ImmutableSet[].hash.should_not == ImmutableSet[1, 2, 3].hash
    ImmutableSet[1, 2, 3].hash.should_not == ImmutableSet["a", "b", "c"].hash
  end
end
