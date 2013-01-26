module Chap
  module Strategy
    class Git < Base
      def deploy
        checkout
        copy
      end


      def checkout

        log "Checking out repo to #{cached_path}".colorize(:green)
        cached_root = "#{shared_path}/cached-copy"
        FileUtils.mkdir_p(cached_root) unless File.exist?(cached_root)
        command =<<BASH
if [ -d #{cached_path} ]; then
  cd #{cached_path} &&  \
  git fetch -q origin && \
  git fetch --tags -q origin && \
  git reset -q --hard #{revision} && \
  git clean -q -d -x -f
else
  git clone -q #{config.chap[:repo]} #{cached_path} && \
  cd #{cached_path} && \
  git checkout -q -b deploy #{revision}
fi
BASH
        run(command)
      end

      def copy
        command =<<-BASH
cp -RPp #{cached_path} #{release_path} && \
(echo #{revision} > #{release_path}/REVISION)
BASH
        run command
        log "Code copied to #{release_path}".colorize(:green)
      end

    private

      def revision
        return @revision if @revision
        result = `git ls-remote #{config.chap[:repo]} #{config.chap[:branch]}`
        @revision = result.split(/\s/).first
        log "Fetched revision #{@revision}".colorize(:green)
        @revision
      end

    end # of Git
  end # of Strategy
end # of Chap
