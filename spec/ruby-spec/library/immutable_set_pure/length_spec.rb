require_relative '../../../spec_helper'
require_relative 'shared/length'
require 'set'

describe "ImmutableSet::Pure#length" do
  it_behaves_like :sorted_set_2_length, :length
end
