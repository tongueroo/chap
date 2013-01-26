module Chap
  class Task
    def self.setup(options={})
      puts "Generating config files" unless options[:quiet]
      setup = File.expand_path("../../setup", __FILE__)
      output = options[:output] || '.'
      Dir.glob("#{setup}/*").each do |source|
        dest = "#{output}/#{File.basename(source)}"
        if File.exist?(dest)
          if options[:force]
            puts "Overwriting: #{dest}" unless options[:quiet]
            FileUtils.cp(source, dest)
          else
            puts "Already exist: #{dest}" unless options[:quiet]
          end
        else
          FileUtils.cp(source, dest)
          puts "Created: #{dest}" unless options[:quiet]
        end
      end
    end

    def self.deploy(options)
      @runner = options.empty? ? Runner.new : Runner.new(options)
      @runner.deploy
    end
  end
end