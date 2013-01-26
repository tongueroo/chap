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
    def deploy
      Chap::Task.deploy(options)
    end
  end
end