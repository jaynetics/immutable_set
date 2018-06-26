require_relative '../../../spec_helper'
require 'set'

describe "ImmutableSet#pretty_print_cycle" do
  it "passes the 'pretty print' representation of a self-referencing ImmutableSet to the pretty print writer" do
    pp = double("PrettyPrint")
    pp.should_receive(:text).with("#<ImmutableSet: {...}>")
    ImmutableSet[1, 2, 3].pretty_print_cycle(pp)
  end
end
