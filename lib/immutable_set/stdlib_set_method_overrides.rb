class ImmutableSet < Set
  #
  # These comparison methods only offer a big speed gain with the C extension,
  # or on Ruby < 2.3 where `Set` has no access to Hash#<=>.
  #
  # In Ruby, bad Enumerator#next performance makes using two of them in parallel
  # slower than just looking up everything (as #super does) for many cases.
  #
  def superset?(set)
    return super unless native_ext_can_relate?(set)
    potentially_superset_of?(set) && native_ext.superset?(self, set)
  end
  alias >= superset?

  def proper_superset?(set)
    return super unless native_ext_can_relate?(set)
    potentially_proper_superset_of?(set) && native_ext.superset?(self, set)
  end
  alias > proper_superset?

  def subset?(set)
    return super unless native_ext_can_relate?(set)
    potentially_subset_of?(set) && native_ext.subset?(self, set)
  end
  alias <= subset?

  def proper_subset?(set)
    return super unless native_ext_can_relate?(set)
    potentially_proper_subset_of?(set) && native_ext.subset?(self, set)
  end
  alias < proper_subset?

  #
  # These methods are faster both with the C extension and the Ruby fallback.
  #

  def |(other)
    raise_unless_enumerable(other)
    return self if other.empty?

    other = self.class.cast(other)
    relate_with_method(:union, to_other: other)
  end
  alias + |
  alias union |

  def -(other)
    raise_unless_enumerable(other)
    return self if other.empty?

    other = self.class.cast(other)
    return self if distinct_bounds?(other)

    relate_with_method(:difference, to_other: other)
  end
  alias difference -

  def &(other)
    raise_unless_enumerable(other)
    return self.class.new if other.empty?

    other = self.class.cast(other)
    return self.class.new if distinct_bounds?(other)

    relate_with_method(:intersection, to_other: other)
  end
  alias intersection &

  def ^(other)
    raise_unless_enumerable(other)
    return other if empty?
    return self if other.empty?

    other = self.class.cast(other)
    return self + other if distinct_bounds?(other)

    relate_with_method(:exclusion, to_other: other)
  end

  # Set#intersect? at ~ O(m*n) *can* surpass ImmutableSet#intersect? at ~ O(m+n)
  # for sets with *very* different sizes and unfortunately offset members.
  # Example: Set[999_999].intersect?(Set.new(1..1_000_000))
  STD_INTERSECT_THRESHOLD_RATIO = 1000

  def intersect?(other)
    raise_unless_enumerable(other)
    return false if empty? || other.empty?

    other = self.class.cast(other)
    return false if distinct_bounds?(other)

    smaller_size, larger_size = [size, other.size].minmax
    return super if larger_size / smaller_size > STD_INTERSECT_THRESHOLD_RATIO

    relate_with_method(:intersect?, to_other: other)
  end

  def classify
    return super unless block_given?

    classification_hash = {}
    each do |o|
      tmp = (classification_hash[yield(o)] ||= { data: {}, max: nil })
      tmp[:data][o] = true
      tmp[:max] = o
    end
    classification_hash.map do |k, v|
      [k, self.class.build_with_hash_and_max(v[:data], v[:max])]
    end.to_h
  end

  #
  # The following private helper methods do not exist in the stdlib.
  #
  private

  def raise_unless_enumerable(obj)
    raise ArgumentError, 'value must be enumerable' unless obj.respond_to? :each
  end

  def relate_with_method(method, to_other: nil)
    relate_module(to_other).__send__(method, self, to_other)
  end

  def relate_module(other)
    native_ext_can_relate?(other) ? native_ext : RubyFallback
  end

  # The C extension can relate two sets if it is loaded, the other set is also
  # an ImmutableSet, neither is empty, and members are comparable between sets.
  def native_ext_can_relate?(other)
    native_ext && other.is_a?(ImmutableSet) && max && (max <=> other.max)
  end

  #
  # These are some very fast sanity checks that can improve clear-cut cases.
  # e.g.: a set with shorter bounds (at any end) can never be a superset.
  # This brings huge improvements on Ruby < 2.3 (Rubies without Hash#<=>).
  #
  def potentially_subset_of?(other)
    min >= other.min && max <= other.max
  end

  def potentially_proper_subset_of?(other)
    potentially_subset_of?(other) && (min > other.min || max < other.max)
  end

  def potentially_superset_of?(other)
    min <= other.min && max >= other.max
  end

  def potentially_proper_superset_of?(other)
    potentially_superset_of?(other) && (min < other.min || max > other.max)
  end
end
