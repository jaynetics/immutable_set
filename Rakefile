require 'bundler/gem_tasks'
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec)

task default: :spec

require 'rake/extensiontask'

Rake::ExtensionTask.new('immutable_set') do |ext|
  ext.lib_dir = 'lib/immutable_set'
end

desc 'Download relevant ruby/spec tests, adapt to ImmutableSet and its variants'
task :sync_ruby_spec do
  require 'fileutils'

  variants = {
    'ImmutableSet'       => './spec/ruby-spec/library/immutable_set',
    'ImmutableSet::Pure' => './spec/ruby-spec/library/immutable_set_pure',
  }
  variants.each { |_, dir| FileUtils.rm_rf(dir) if File.exist?(base_dir) }

  `svn export https://github.com/ruby/spec/trunk/library/set/sortedset #{base_dir}`

  base = variants.first[1]
  variants.each_value { |dir| FileUtils.copy_entry(base, dir) unless dir == base }

  variants.each.with_index do |(class_name, dir), i|
    Dir["#{dir}/**/*.rb"].each do |spec|
      if spec =~ %r{/(add|append|case|clear|collect|delete|filter|flatten|
                      initialize|keep_if|map|merge|replace|reject|select|subtract)}x
        File.delete(spec)
        next
      end

      # `i` must be added to shared example names or they'll override each other
      adapted_content =
        File
        .read(spec)
        .gsub('SortedSet', class_name)
        .gsub('sorted_set_', "sorted_set_#{i}_")
        .gsub(/describe (.*), shared.*$/, 'shared_examples \1 do |method|')
        .gsub('@method', 'method')
        .gsub(/be_(false|true)/, 'be \1')
        .gsub('mock', 'double')

      File.open(spec, 'w') { |f| f.puts adapted_content }
    end
  end
end

desc 'Run all IPS benchmarks'
task :benchmark do
  Dir['./benchmarks/*.rb'].sort.each { |file| require file }
end

namespace :benchmark do
  desc 'Run all IPS benchmarks and store the comparison results in BENCHMARK.md'
  task :write_to_file do
    $store_comparison_results = {}

    Rake.application[:benchmark].invoke

    File.open('BENCHMARK.md', 'w') do |f|
      f.puts "Results of `rake:benchmark` on #{RUBY_DESCRIPTION}",
             '',
             'Note: `stdlib` refers to `SortedSet` without the `rbtree` gem. '\
             'If the `rbtree` gem is present, `SortedSet` will [use it]'\
             '(https://github.com/ruby/ruby/blob/b1a8c64/lib/set.rb#L709-L724)'\
             ' and become even slower.',
             '',

      $store_comparison_results.each do |caption, result|
        f.puts '```', caption, result.strip.gsub(/(same-ish).*$/, '\1').lines[1..-1], '```'
      end
    end
  end
end

unless RUBY_PLATFORM =~ /java/
  # recompile before benchmarking or running specs
  task(:benchmark).enhance([:compile])
  task(:spec).enhance([:compile])
end
