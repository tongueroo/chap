module Chap
  module Strategy
    # useful for specs
    class Copy < Base
      include Benchmarking
      def deploy
        run("cp -RPp #{config.chap[:source]} #{release_path}")
      end

      benchmark :deploy
    end
  end # of Strategy
end # of Chap
