module Chap
  module Strategy
    class Checkout < Base
      include Benchmarking

      def deploy
        update
        copy
      end

      def update
        log "Updating repo in #{cached_path}".colorize(:green)
        cached_root = File.dirname(cached_path)
        FileUtils.mkdir_p(cached_root) unless File.exist?(cached_root)
        if File.exist?(cached_path)
          sync
        else
          checkout
        end
      end

      def sync
        command =<<-BASH
cd #{cached_path} &&  \
git fetch -q origin && \
git fetch --tags -q origin && \
git reset -q --hard #{revision} && \
git clean -q -d -x -f
BASH
        run(command)
      end

      def checkout
        command =<<BASH
  git clone -q #{config.chap[:repo]} #{cached_path} && \
  cd #{cached_path} && \
  git checkout -q -b deploy #{revision}
BASH
        run(command)
      end

      def copy
        command = "cp -RPp #{cached_path} #{release_path} && #{mark}"
        run command
        log "Code copied to #{release_path}".colorize(:green)
      end

      benchmark :update, :copy
      
    private

      def mark
        "(echo #{revision} > #{release_path}/REVISION)"
      end

      def revision
        return @revision if @revision
        result = `git ls-remote #{config.chap[:repo]} #{config.chap[:branch]}`
        @revision = result.split(/\s/).first
        log "Fetched revision #{@revision}".colorize(:green)
        @revision
      end

    end # of RemoteCache
  end # of Strategy
end # of Chap
