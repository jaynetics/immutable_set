RSpec.describe ImmutableSet do
  if Gem::Version.new(RUBY_VERSION.dup) >= Gem::Version.new('2.4.0')
    it 'uses the native extension' do
      expect(ImmutableSet.native_ext).not_to be_nil
    end
  end
end
