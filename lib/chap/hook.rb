module Chap
  class Hook
    include SpecialMethods

    attr_reader :options, :config
    def initialize(path, config)
      @path = path
      @config = config
    end

    def evaluate
      instance_eval(File.read(@path), @path)
    end

  end
end