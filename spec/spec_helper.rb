require 'bundler/setup'

require 'immutable_set'

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  # config.disable_monkey_patching! # required for ruby-spec examples

  config.expect_with :rspec do |c|
    c.syntax = [:expect, :should] # :should is for ruby-spec examples
  end

  config.mock_with :rspec do |c|
    c.syntax = [:expect, :should] # :should is for ruby-spec examples
  end
end
