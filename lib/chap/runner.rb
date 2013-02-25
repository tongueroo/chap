module Chap
  class Runner
    include SpecialMethods
    include Benchmarking

    attr_reader :options, :config
    def initialize(options={})
      @options = options
      @config = Config.new(options)
    end

    def deploy
      deploy_to_symlink
      deploy_from_symlink
      report_benchmarks
    end

    def deploy_to_symlink
      setup
      deploy_via_strategy
      symlink_shared
      rm_rvmrc
      hook(:deploy)
    end

    def deploy_from_symlink(use_previous=false)
      use_previous_timestamp if use_previous
      symlink_current
      hook(:restart)
      cleanup
    end

    def symlink
      use_previous_timestamp
      symlink_current
    end

    def setup
      user = config.chap[:user] || ENV['USER']
      group = config.chap[:group]
      begin
        FileUtils.mkdir_p(deploy_to)
        FileUtils.chown_R user, group, deploy_to
      rescue Exception
        # retry to create deploy_to folder with sudo
        user_group = [user,group].compact.join(':')
        raise unless system("sudo mkdir -p #{deploy_to}")
        raise unless system("sudo chown -R #{user_group} #{deploy_to}")
      end
      dirs = ["#{deploy_to}/releases"]
      dirs += shared_dirs
      dirs.each do |dir|
        FileUtils.mkdir_p(dir)
      end
    end

    def strategy
      strategy = config.strategy
      klass = Strategy.const_get(camel_case(strategy))
      @strategy ||= klass.new(:config => @config)
    end

    def deploy_via_strategy
      strategy.deploy
    end

    def camel_case(string)
      return string if string !~ /_/ && string =~ /[A-Z]+.*/
      string.split('_').map{|e| e.capitalize}.join
    end

    def symlink_shared
      shared_dirs.each do |path|
        src = path
        relative_path = path.sub("#{shared_path}/",'')
        dest = "#{release_path}/#{relative_path}"
        # make sure the directory exist for symlink creation
        dirname = File.dirname(dest)
        FileUtils.mkdir_p(dirname) unless File.exist?(dirname)
        if File.symlink?(dest)
          File.delete(dest)
        elsif File.exist?(dest)
          FileUtils.rm_rf(dest)
        end
        FileUtils.ln_s(src,dest)
      end
    end

    def symlink_current
      FileUtils.rm(current_path) if File.exist?(current_path)
      FileUtils.ln_s(release_path, current_path)
      log "Current symlink updated".colorize(:green)
    end

    def rm_rvmrc
      %w[.rvmrc .ruby-version].each do |file|
        path = "#{release_path}/#{file}"
        run "rm -f #{path}" if File.exist?(path)
      end
    end

    def cleanup
      log "Cleaning up".colorize(:green)
      remove_old_releases
      logrotate
    end

    def remove_old_releases
      dirname = File.dirname(release_path)
      releases = Dir.glob("#{dirname}/*").sort.reverse
      keep = config.chap[:keep] || 5
      delete = releases - releases[0..keep-1]
      delete.each do |old_release|
        FileUtils.rm_rf(old_release)
      end
    end

    def logrotate
      logrotate_file(config.chap_log_path)
    end

    def logrotate_timestamp
      @logrotate_timestamp ||= Time.now.strftime("%Y-%m-%d-%H-%M-%S")
    end

    def logrotate_file(log_path)
      dirname = File.dirname(log_path)
      basename = File.basename(log_path, '.log')
      archive = "#{dirname}/#{basename}-#{logrotate_timestamp}.log"
      FileUtils.cp(log_path, archive) if File.exist?(log_path)
      logs = Dir.glob("#{dirname}/#{basename}-*.log").sort.reverse
      delete = logs - logs[0..9] # keep last 10 chap logs
      delete.each do |old_log|
        FileUtils.rm_f(old_log)
      end
    end

    def shared_dirs
      dirs = config.chap[:shared_dirs] || [
        "public/system",
        "log",
        "tmp/pids"
      ]
      dirs.map! {|p| "#{shared_path}/#{p}"}
    end

    def test_hook(name)
      use_previous_timestamp
      hook(name)
    end

    def use_previous_timestamp
      timestamp = File.basename(latest_release)
      config.override_timestamp(timestamp)
    end

    def hook(name)
      log "Running hook: #{name}".colorize(:green)
      path = "#{release_path}/chap/#{name}"
      if File.exist?(path)
        Hook.new(path, @config).evaluate
      else
        log "chap/#{name} hook does not exist".colorize(:red)
      end
    end

    benchmark :setup, :symlink_shared, :rm_rvmrc, :hook, :symlink_current, :cleanup, :deploy_via_strategy

  end # eof Runner
end # eof Chap