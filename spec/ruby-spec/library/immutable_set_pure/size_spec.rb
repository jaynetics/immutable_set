require_relative '../../../spec_helper'
require_relative 'shared/length'
require 'set'

describe "ImmutableSet::Pure#size" do
  it_behaves_like :sorted_set_2_length, :size
end
