require 'benchmark'

module Chap
  module Benchmarking
    def self.included(base)
      @@benchmarks = []
      base.extend(ClassMethods)
    end

    module ClassMethods
      def benchmark(*methods)
        methods.each do |method|
          benchmark_each method
        end
      end
      def benchmark_each(method, scope=nil)
        class_eval <<-EOL
          def #{method}_with_benchmark(*args,&block)
            scope=#{scope.inspect}
            result = nil
            realtime = Benchmark.realtime do
              result = #{method}_without_benchmark(*args,&block)
            end
            method_name = if args.empty?
                            "#{method}"
                          else
                            name = "#{method}" + '("' + args.join(',') + '")'
                            name = shorten_name(name)
                          end
            method_name = scope + ': ' + method_name if scope
            @@benchmarks << [method_name, realtime]
            result
          end
        EOL
        alias_method "#{method}_without_benchmark", method
        alias_method method, "#{method}_with_benchmark"
      end
    end

    def shorten_name(string)
      if string.length >= 80
        preprend = string[0,20]
        append = string[-55..-1]
        preprend + ' ... ' + append
      else 
        string
      end
    end

    def benchmarks
      @@benchmarks
    end

    def report_benchmarks
      return if benchmarks.empty?
      report = []
      report << "Benchmark Report:"

      max = benchmarks.collect{|x| x[0]}.max_by{|a| a.length}.length
      report_block = lambda do |data|
        name,took = data
        mins = '%.0f' % (took / 60)
        secs = '%.0f' % (took % 60)
        report << "  %-#{max}s : %2s mins and %2s secs" % [name,mins,secs]
      end

      report << "Ordered by slowest:"
      benchmarks.sort_by {|x| x[1]}.reverse.each(&report_block)

      report.each do |line|
        log(line) unless options[:quiet]
      end
    end

  end
end