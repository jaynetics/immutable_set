require_relative '../../../spec_helper'
require 'set'

describe "ImmutableSet::Pure#hash" do
  it "is static" do
    ImmutableSet::Pure[].hash.should == ImmutableSet::Pure[].hash
    ImmutableSet::Pure[1, 2, 3].hash.should == ImmutableSet::Pure[1, 2, 3].hash
    ImmutableSet::Pure["a", "b", "c"].hash.should == ImmutableSet::Pure["c", "b", "a"].hash

    ImmutableSet::Pure[].hash.should_not == ImmutableSet::Pure[1, 2, 3].hash
    ImmutableSet::Pure[1, 2, 3].hash.should_not == ImmutableSet::Pure["a", "b", "c"].hash
  end
end
