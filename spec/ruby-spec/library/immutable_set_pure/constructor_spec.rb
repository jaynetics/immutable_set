require_relative '../../../spec_helper'
require 'set'

describe "ImmutableSet::Pure[]" do
  it "returns a new ImmutableSet::Pure populated with the passed Objects" do
    set = ImmutableSet::Pure[1, 2, 3]

    set.instance_of?(ImmutableSet::Pure).should be true
    set.size.should eql(3)

    set.should include(1)
    set.should include(2)
    set.should include(3)
  end
end
