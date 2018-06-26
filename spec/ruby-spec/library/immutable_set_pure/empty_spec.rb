require_relative '../../../spec_helper'
require 'set'

describe "ImmutableSet::Pure#empty?" do
  it "returns true if self is empty" do
    ImmutableSet::Pure[].empty?.should be true
    ImmutableSet::Pure[1].empty?.should be false
    ImmutableSet::Pure[1,2,3].empty?.should be false
  end
end
