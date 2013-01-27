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

    desc "s3_upload", "Upload chap.json to s3"
    long_desc <<-EOL
      Example:

      $ chap s3_upload -f chap.json
    EOL
    method_option :file, :aliases => '-f', :desc => "file to upload"
    method_option :config, :aliases => '-c', :default => '/etc/chef/chap.yml', :desc => "chap.yml config to use"
    def s3_upload
      Chap::Task.s3_upload(options)
    end

    desc "s3_download", "Download chap.json from s3"
    long_desc <<-EOL
      Example:

      $ chap s3_download -f chap.json
    EOL
    method_option :file, :aliases => '-f', :desc => "destination to save file"
    method_option :config, :aliases => '-c', :default => '/etc/chef/chap.yml', :desc => "chap.yml config to use"
    def s3_download
      Chap::Task.s3_download(options)
    end

    desc "s3_change", "Modify chap.json from s3"
    long_desc <<-EOL
      Example:

      $ chap s3_change --variables branch:feature repo:'git@github.com:tongueroo/hello.git' 
    EOL
    method_option :config, :aliases => '-c', :default => '/etc/chef/chap.yml', :desc => "chap.yml config to use"
    method_option :variables, :aliases => '-v', :type => :hash, :default => {}, :required => true
    def s3_change
      Chap::Task.s3_change(options)
    end
  end
end