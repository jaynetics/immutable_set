require_relative '../../../spec_helper'
require 'set'

describe "ImmutableSet#pretty_print" do
  it "passes the 'pretty print' representation of self to the pretty print writer" do
    pp = double("PrettyPrint")
    set = ImmutableSet[1, 2, 3]

    pp.should_receive(:text).with("#<ImmutableSet: {")
    pp.should_receive(:text).with("}>")

    pp.should_receive(:nest).with(1).and_yield
    pp.should_receive(:seplist).with(set)

    set.pretty_print(pp)
  end
end
