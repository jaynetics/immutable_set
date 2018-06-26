require_relative '../../../spec_helper'
require 'set'

describe "ImmutableSet[]" do
  it "returns a new ImmutableSet populated with the passed Objects" do
    set = ImmutableSet[1, 2, 3]

    set.instance_of?(ImmutableSet).should be true
    set.size.should eql(3)

    set.should include(1)
    set.should include(2)
    set.should include(3)
  end
end
