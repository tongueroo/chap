module Chap
  class Hook
    include SpecialMethods

    attr_reader :options, :config
    def initialize(path, config)
      @path = path
      @config = config
      @with = nil
    end

    def evaluate
      instance_eval(File.read(@path), @path)
    end

    # hook helper methods
    def symlink_configs
      paths = Dir.glob("#{shared_path}/config/**/*").
                select {|p| File.file?(p) }
      paths.each do |src|
        relative_path = src.gsub(%r{.*config/},'config/')
        dest = "#{release_path}/#{relative_path}"
        # make sure the directory exist for symlink creation
        dirname = File.dirname(dest)
        FileUtils.mkdir_p(dirname) unless File.exist?(dirname)
        FileUtils.rm_rf(dest) if File.exist?(dest)
        FileUtils.ln_s(src,dest)
      end
    end

    def with(prepend)
      prev, @with = @with, prepend
      yield
      @with = prev
    end

    def run(cmd)
      cmd = "#{@with} #{cmd}"
      config.run(cmd)
    end

  end
end