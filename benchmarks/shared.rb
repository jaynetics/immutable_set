lib = File.expand_path('../lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'benchmark/ips'
require 'immutable_set'

S = SortedSet
I = ImmutableSet
P = ImmutableSet::Pure

def benchmark(method: nil, cases: {}, caption: nil)
  caption ||= "##{method}"

  puts caption

  report = Benchmark.ips do |x|
    cases.each do |label, content|
      x.report(label) do
        if content.respond_to?(:call) then content.call
        elsif content.is_a?(Array)    then content[0].send(method, content[1])
        else                               content.send(method)
        end
      end
    end
    x.compare!
  end

  return unless $store_comparison_results

  old_stdout = $stdout.clone
  captured_stdout = StringIO.new
  $stdout = captured_stdout
  report.run_comparison
  $store_comparison_results[caption] = captured_stdout.string
  $stdout = old_stdout
end
