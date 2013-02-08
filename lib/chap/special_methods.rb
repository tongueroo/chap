module Chap
  module SpecialMethods
    SPECIAL_METHODS = %w/deploy_to release_path current_path shared_path cached_path latest_release node chap log run/

    def self.included(base)
      base.send(:extend, ClassMethods)
      base.define_special_methods
    end

    module ClassMethods
      # delegate to the config class
      def define_special_methods
        SPECIAL_METHODS.each do |method|
          class_eval <<-EOL
            def #{method}(*args)
              @config.#{method}(*args)
            end
          EOL
        end
      end
    end
  end
end