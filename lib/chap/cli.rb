module Chap
  class CLI < Thor
    desc "setup", "Sets up chap config files"
    long_desc "Creates chap.json, chap.yml and node.json example files."
    method_option :force, :aliases => '-f', :type => :boolean, :desc => "Overwrite existing files"
    method_option :quiet, :aliases => '-q', :type => :boolean, :desc => "Quiet commands"
    method_option :output, :aliases => '-o', :desc => "Folder which example files will be written to"
    def setup
      Chap::Task.setup(options)
    end

    desc "deploy", "Deploy application"
    long_desc <<-EOL
      Example:

      $ chap deploy

      Deploys code using settings from chap.json and node.json.  chap.json and node.json should be referenced in chap.yml.
    EOL
    method_option :quiet, :aliases => '-q', :type => :boolean, :desc => "Quiet commands"
    method_option :config, :aliases => '-c', :default => '/etc/chef/chap.yml', :desc => "chap.yml config to use"
    method_option :stop_at_symlink, :type => :boolean, :desc => "Deploy code but stop right before the symlink"
    method_option :cont_at_symlink, :type => :boolean, :desc => "Symlink and contine the deploy"
    def deploy
      Chap::Task.deploy(options)
    end

    desc "hook", "Run chap hook"
    long_desc <<-EOL
      Example:

      $ chap hook deploy

      A way to test the chap hooks
    EOL
    method_option :quiet, :aliases => '-q', :type => :boolean, :desc => "Quiet commands"
    method_option :config, :aliases => '-c', :default => '/etc/chef/chap.yml', :desc => "chap.yml config to use"
    def hook(name)
      Chap::Runner.new(options).test_hook(name)
    end

    desc "symlink", "Symlink latest timestamp release to current"
    long_desc <<-EOL
      Example:

      $ chap symlink

      Useful for testing between testing deploy and restart hooks.
    EOL
    method_option :quiet, :aliases => '-q', :type => :boolean, :desc => "Quiet commands"
    method_option :config, :aliases => '-c', :default => '/etc/chef/chap.yml', :desc => "chap.yml config to use"
    def symlink
      Chap::Runner.new(options).symlink
    end
  end
end