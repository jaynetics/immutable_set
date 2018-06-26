require_relative '../../../spec_helper'
require_relative 'shared/intersection'
require 'set'

describe "ImmutableSet::Pure#intersection" do
  it_behaves_like :sorted_set_2_intersection, :intersection
end

describe "ImmutableSet::Pure#&" do
  it_behaves_like :sorted_set_2_intersection, :&
end
