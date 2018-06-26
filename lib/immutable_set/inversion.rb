class ImmutableSet < Set
  # Returns an ImmutableSet.
  #
  # The result includes all members `from`..`upto` that are not in self.
  # If `ucp_only` is true, invalid unicode codepoints are omitted.
  def inversion(from: nil, upto: nil, ucp_only: false)
    if native_ext && from.object_id.odd? && upto.object_id.odd?
      native_ext.invert_fixnum_set(self, from..upto, ucp_only)
    else
      RubyFallback.inversion(self, from..upto, ucp_only)
    end
  end
end
