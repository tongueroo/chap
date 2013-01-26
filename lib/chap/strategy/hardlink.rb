module Chap
  module Strategy
    class Hardlink < Checkout
      def copy
        copy = File.expand_path("../util/copy.rb", __FILE__)
        command = "#{copy} #{cached_path} #{release_path} && #{mark}"
        run command
        log "Code copied to #{release_path}".colorize(:green)
      end

    end # of HardLink
  end # of Strategy
end # of Chap
