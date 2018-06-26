lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'set'
require 'immutable_set/version'

Gem::Specification.new do |s|
  s.name          = 'immutable_set'
  s.version       = ImmutableSet::VERSION
  s.authors       = ['Janosch Müller']
  s.email         = ['janosch84@gmail.com']

  s.summary       = "A faster, immutable replacement for Ruby's Set"
  s.homepage      = 'https://github.com/janosch-x/immutable_set'
  s.license       = 'MIT'

  s.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(benchmarks|test|spec|features)/})
  end
  s.executables   = s.files.grep(%r{^exe/}) { |f| File.basename(f) }
  s.require_paths = ['lib']

  if RUBY_PLATFORM !~ /java/i
    s.extensions  = %w[ext/immutable_set/extconf.rb]
  end

  s.required_ruby_version = '>= 2.0.0'

  s.add_development_dependency 'benchmark-ips', '~> 2.7'
  s.add_development_dependency 'bundler', '~> 1.16'
  s.add_development_dependency 'rake', '~> 10.0'
  s.add_development_dependency 'rake-compiler', '~> 1.0'
  s.add_development_dependency 'rspec', '~> 3.0'
end
