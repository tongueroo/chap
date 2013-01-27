module Chap
  class Config
    attr_reader :options, :node, :chap
    def initialize(options={})
      @options = options
      # preload all config files so validatation happens before deploys
      _ = yaml, chap, node
    end

    def yaml
      path = options[:config]
      if File.exist?(path)
        @yaml ||= Mash.from_hash(YAML.load(IO.read(path)))
      else
        puts "ERROR: chap.yaml config does not exist at: #{path}"
        exit 1
      end
    end

    def chap
      return @chap if @chap
      @chap = load_json(:chap)
      @chap[:release_path] = release_path
      @chap[:current_path] = current_path
      @chap[:cached_path] = cached_path
      @chap
    end

    def node
      @node ||= load_json(:node)
    end

    # the chap.json and node.json is assumed to be in th same folder as
    # chap.yml if a relative path is given
    def load_json(key)
      path = if yaml[key] =~ %r{^/} # root path given
               yaml[key]
             else # relative path
               dirname = File.dirname(options[:config])
               "#{dirname}/#{yaml[key]}"
             end
      if File.exist?(path)
        Mash.from_hash(JSON.parse(IO.read(path)))
      else
        puts "ERROR: #{key}.json config does not exist at: #{path}"
        exit 1
      end
    end

    def timestamp
      @timestamp ||= Time.now.strftime("%Y%m%d%H%M%S")
    end

    def deploy_to
      chap[:deploy_to]
    end

    # special attributes added to chap  
    def release_path
      return @release_path if @release_path
      @release_path = "#{deploy_to}/releases/#{timestamp}"
    end

    def current_path
      return @current_path if @current_path
      @current_path = "#{deploy_to}/current"
    end

    def shared_path
      return @shared_path if @shared_path
      @shared_path = "#{deploy_to}/shared"
    end

    def cached_path
      return @cached_path if @cached_path
      path = chap[:repo].split(':').last.sub('.git','')
      @cached_path = "#{shared_path}/cache/#{strategy}/#{path}"
    end

    def strategy
      chap[:strategy] || 'checkout'
    end

    def log(msg)
      puts msg unless options[:quiet]
      logger.info(msg)
    end

    def chap_log_path
      return @chap_log_path if @chap_log_path
      dir = "#{shared_path}/chap"
      FileUtils.mkdir_p(dir) unless File.exist?(dir)
      @chap_log_path = "#{dir}/chap.log"
      system("cat /dev/null > #{@chap_log_path}")
      @chap_log_path
    end

    def logger
      return @logger if @logger
      @logger = Logger.new(chap_log_path)
      # @logger.level = Logger::WARN
      @logger
    end

    def run(cmd)      
      log "Running: #{cmd}"
      cmd = "#{cmd} 2>&1" unless cmd.include?(" > ")
      out = `#{cmd}`
      log out
      raise "DeployError" if $?.exitstatus > 0
    end
  end
end