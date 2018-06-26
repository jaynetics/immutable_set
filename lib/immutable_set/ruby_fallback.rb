class ImmutableSet < Set
  module RubyFallback
    module_function

    def inversion(set, range, ucp_only)
      from = range.begin
      upto = range.end

      set.class.build_with_hash_and_max do |new_hash|
        own_min, own_max = set.minmax
        new_max = nil

        insertion_proc = ->(o) do
          return if ucp_only && o >= 0xD800 && o <= 0xDFFF
          new_hash[o] = true
          new_max = o
        end

        if own_max.nil?
          # empty Set - inversion is pretty much equal to Set[from..upto]
          from.upto(upto) { |o| insertion_proc.call(o) }
          next new_max
        end

        own_hash = set.instance_variable_get(:@hash)
        o = from

        # insert all below own lower boundary without check
        while o < own_min && o <= upto
          insertion_proc.call(o)
          o = o.next
        end

        # insert with check within bounds
        while o <= own_max && o <= upto
          insertion_proc.call(o) unless own_hash.key?(o)
          o = o.next
        end

        # insert all above own upper boundary without check
        while o <= upto
          insertion_proc.call(o)
          o = o.next
        end

        new_max
      end
    end

    def union(set_a, set_b)
      a_min, a_max = set_a.minmax
      b_min, b_max = set_b.minmax
      a_hash = set_a.instance_variable_get(:@hash)
      b_hash = set_b.instance_variable_get(:@hash)

      # disjoint sets case (self wholly below b)
      if a_max < b_min
        hash = a_hash.dup.update(b_hash)
        return set_a.class.build_with_hash_and_max(hash, b_max)
      # disjoint sets case (b wholly below self)
      elsif b_max < a_min
        hash = b_hash.dup.update(a_hash)
        return set_a.class.build_with_hash_and_max(hash, a_max)
      end

      # sets with overlapping bounds case - insert objects in order
      set_a.class.build_with_hash_and_max do |new_hash|
        a_keys = a_hash.keys
        b_keys = b_hash.keys
        a_key = a_keys[i = 0]
        b_key = b_keys[j = 0]
        while a_key && b_key
          if a_key < b_key
            new_hash[a_key] = true
            a_key = a_keys[i += 1]
          else
            new_hash[b_key] = true
            b_key = b_keys[j += 1]
          end
        end

        remaining_keys, offset = a_key ? [a_keys, i] : [b_keys, j]
        remaining_size = remaining_keys.size
        while offset < remaining_size
          new_hash[remaining_keys[offset]] = true
          offset += 1
        end
        [a_max, b_max].max
      end
    end

    def difference(set_a, set_b)
      new_hash = set_a.instance_variable_get(:@hash).dup
      set_b.each { |o| new_hash.delete(o) }
      set_a.class.build_with_hash_and_max(new_hash, new_hash.keys.last)
    end

    def intersection(set_a, set_b)
      set_a.class.build_with_hash_and_max do |new_hash|
        a_keys = set_a.to_a
        a_max  = set_a.max

        b_keys = set_b.to_a
        b_max  = set_b.max

        a_key = a_keys[i = 0]
        b_key = b_keys[j = 0]

        while a_key && b_key && a_key <= b_max && b_key <= a_max
          if a_key == b_key
            new_hash[a_key] = true
            a_key = a_keys[i += 1]
            b_key = b_keys[j += 1]
          elsif a_key < b_key
            a_key = a_keys[i += 1]
          else # a_key > b_key
            b_key = b_keys[j += 1]
          end
        end

        [a_max, b_max].min
      end
    end

    def intersect?(set_a, set_b)
      cmp = ->(smaller_set, larger_set) do
        return false if smaller_set.distinct_bounds?(larger_set)

        larger_set_min, larger_set_max = larger_set.minmax
        smaller_set.any? do |smaller_set_obj|
          next         if smaller_set_obj < larger_set_min
          return false if smaller_set_obj > larger_set_max
          larger_set.include?(smaller_set_obj)
        end
      end
      set_a.size < set_b.size ? cmp.call(set_a, set_b) : cmp.call(set_b, set_a)
    end

    def exclusion(set_a, set_b)
      set_a.class.build_with_hash_and_max do |new_hash|
        new_max = nil
        set_a.each { |o| new_hash[new_max = o] = true unless set_b.include?(o) }
        set_b.each { |o| new_hash[new_max = o] = true unless set_a.include?(o) }
        new_max
      end
    end
  end
end
