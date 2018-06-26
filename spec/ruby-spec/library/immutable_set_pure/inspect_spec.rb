require_relative '../../../spec_helper'
require 'set'

describe "ImmutableSet::Pure#inspect" do
  it "returns a String representation of self" do
    ImmutableSet::Pure[].inspect.should be_kind_of(String)
    ImmutableSet::Pure[1, 2, 3].inspect.should be_kind_of(String)
    ImmutableSet::Pure["1", "2", "3"].inspect.should be_kind_of(String)
  end
end
