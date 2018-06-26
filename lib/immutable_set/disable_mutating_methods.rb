class ImmutableSet < Set
  DISABLED_METHODS = %i[<< clear clone dup keep_if merge replace reset subtract]
                     .concat(instance_methods.grep(/^add|^delete|.!$/))

  (DISABLED_METHODS & instance_methods).each { |method| undef_method(method) }

  def method_missing(method_name, *args, &block)
    super unless DISABLED_METHODS.include?(method_name)
    raise NoMethodError, "##{method_name} can't be called on an ImmutableSet, "\
                         'only on a Set/SortedSet. Use #+, #-, #^, #& instead.'
  end
end
