module Chap
  module Strategy
    class Base
      include SpecialMethods

      attr_reader :options, :config
      def initialize(options={})
        @options = options
        @config = options[:config]
        log "Deploying via #{self.class} strategy".colorize(:green)
      end

      # should download code to the release_path
      def deploy
        raise "Must implement deploy method"
      end

    end # of Base
  end # of Strategy
end # of Chap