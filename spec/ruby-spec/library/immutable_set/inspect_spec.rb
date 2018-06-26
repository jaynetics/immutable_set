require_relative '../../../spec_helper'
require 'set'

describe "ImmutableSet#inspect" do
  it "returns a String representation of self" do
    ImmutableSet[].inspect.should be_kind_of(String)
    ImmutableSet[1, 2, 3].inspect.should be_kind_of(String)
    ImmutableSet["1", "2", "3"].inspect.should be_kind_of(String)
  end
end
