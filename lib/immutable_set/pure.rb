class ImmutableSet < Set
  class Pure < ImmutableSet
    def self.native_ext; end
  end
end
