module Chap
  module Strategy
    # useful for specs
    class Copy < Base
      def deploy
        run("cp -RPp #{config.chap[:source]} #{release_path}")
      end
    end
  end # of Strategy
end # of Chap
