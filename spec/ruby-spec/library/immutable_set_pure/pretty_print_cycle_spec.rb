require_relative '../../../spec_helper'
require 'set'

describe "ImmutableSet::Pure#pretty_print_cycle" do
  it "passes the 'pretty print' representation of a self-referencing ImmutableSet::Pure to the pretty print writer" do
    pp = double("PrettyPrint")
    pp.should_receive(:text).with("#<ImmutableSet::Pure: {...}>")
    ImmutableSet::Pure[1, 2, 3].pretty_print_cycle(pp)
  end
end
