require_relative '../../../spec_helper'
require_relative 'shared/union'
require 'set'

describe "ImmutableSet::Pure#+" do
  it_behaves_like :sorted_set_2_union, :+
end
