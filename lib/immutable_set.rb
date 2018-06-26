require 'set'
require 'immutable_set/builder_methods'
require 'immutable_set/native_ext'
require 'immutable_set/disable_mutating_methods'
require 'immutable_set/inversion'
require 'immutable_set/pure'
require 'immutable_set/ruby_fallback'
require 'immutable_set/stdlib_set_method_overrides'
require 'immutable_set/version'

class ImmutableSet < Set
  attr_reader :max

  def initialize(arg = nil)
    @hash = Hash.new(false)

    if arg.is_a?(ImmutableSet)
      @hash = arg.instance_variable_get(:@hash)
      @max = arg.max
    elsif arg.is_a?(Range)
      self.class.send(:feed_range_to_hash, arg, @hash)
      @max = arg.max
    elsif arg.respond_to?(:to_a)
      sorted_arg = arg.to_a.sort
      if block_given?
        sorted_arg.each { |o| @hash[yield(o)] = true }
      else
        sorted_arg.each { |o| @hash[o] = true }
      end
      @max = sorted_arg.last
    elsif !arg.nil?
      raise ArgumentError, 'value must be enumerable'
    end

    @hash.freeze
  end

  def min
    @min ||= (first_key, = @hash.first) && first_key
  end

  def minmax
    [min, max]
  end

  def distinct_bounds?(other)
    raise ArgumentError, 'pass an ImmutableSet' unless other.is_a?(ImmutableSet)
    empty? || other.empty? || (min > other.max || max < other.min)
  end
end
