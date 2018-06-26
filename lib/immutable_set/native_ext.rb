class ImmutableSet < Set
  native_ext_available =
    begin
      require_relative './immutable_set'
      Kernel.const_defined?(:ImmutableSetExt)
    rescue LoadError
      false
    end

  if native_ext_available
    def self.native_ext; ::ImmutableSetExt end
  else
    def self.native_ext; end
  end

  def native_ext
    self.class.native_ext
  end
end
