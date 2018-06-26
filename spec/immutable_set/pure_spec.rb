RSpec.describe ImmutableSet::Pure do
  it 'does not use the native extension' do
    expect(ImmutableSet::Pure.native_ext).to be_nil
  end
end
