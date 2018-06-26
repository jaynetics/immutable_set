require_relative '../../../spec_helper'
require_relative 'shared/include'
require 'set'

describe "ImmutableSet::Pure#member?" do
  it_behaves_like :sorted_set_2_include, :member?
end
