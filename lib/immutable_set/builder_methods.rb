#
# Builder methods that set @hash and @max.
#
class ImmutableSet < Set
  class << self
    # Returns an ImmutableSet.
    #
    # Its members will be ordered, irrespective of the order of passed Ranges.
    def from_ranges(*ranges)
      build_with_hash_and_max do |new_hash|
        highest_max = nil
        Array(ranges).sort_by(&:min).each do |range|
          feed_range_to_hash(range, new_hash)
          highest_max = [highest_max || range.max, range.max].max
        end
        highest_max
      end
    end

    # Returns an ImmutableSet.
    #
    # This method can be directly passed a Hash and a max value.
    # It also yields the Hash (or a new Hash if none is given) to any
    # given block, to allow filling it while it is already attached to the
    # new set, which can offer performance benefits for large hashes.
    # If a block is given and no max is passed as parameter, the block must
    # return the new max.
    #
    # Make sure to pass the *correct* max of the new Set, or things will break.
    def build_with_hash_and_max(hash = nil, max = nil)
      hash ||= Hash.new(false)
      set = new
      set.instance_variable_set(:@hash, hash)

      max = yield(hash) if block_given?
      raise ArgumentError, 'pass a comparable max' unless max.respond_to?(:<=>)

      hash.freeze
      set.instance_variable_set(:@max, max)
      set
    end

    # Returns an ImmutableSet.
    #
    # Used to cast Enumerables to ImmutableSet if needed for comparisons.
    def cast(obj)
      obj.is_a?(ImmutableSet) ? obj : new(obj)
    end

    private

    def feed_range_to_hash(range, hash)
      if native_ext && range.begin.object_id.odd? && range.end.object_id.odd?
        native_ext.fill_with_fixnums(hash, range)
      else
        range.each { |o| hash[o] = true }
      end
    end
  end
end
