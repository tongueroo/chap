require 'spec_helper'

describe Chap do
  before(:each) do
    @root = File.expand_path("../../../", __FILE__)
    @system_root = "#{@root}/spec/fixtures/system_root"
  end

  describe "deploy" do
    before(:each) do
      setup_files

      @chap = Chap::Runner.new(
        :quiet => true,
        :config => "#{@system_root}/etc/chef/chap.yml"
      )
      timestamp = @chap.config.timestamp
      @release_path = "#{@system_root}/data/chapdemo/releases/#{timestamp}"
    end

    it "should deploy code" do
      @chap.deploy
      File.exist?("#{@system_root}/data/chapdemo/shared").should be_true
      File.exist?(@release_path).should be_true
      File.symlink?("#{@system_root}/data/chapdemo/current").should be_true
      releases = Dir.glob("#{@system_root}/data/chapdemo/releases/*").size
      releases.should >= 1
      releases.should <= 2 # test the keep option
    end

    it "should deploy code via command line" do
      system("cd #{@root} && ./bin/chap deploy -q -c #{@system_root}/etc/chef/chap.yml")
      releases = Dir.glob("#{@system_root}/data/chapdemo/releases/*").sort
      timestamp = releases.last.split('/').last
      release_path = "#{@system_root}/data/chapdemo/releases/#{timestamp}"

      File.exist?("#{@system_root}/data/chapdemo/shared").should be_true
      File.exist?(release_path).should be_true
      File.symlink?("#{@system_root}/data/chapdemo/current").should be_true
      releases = Dir.glob("#{@system_root}/data/chapdemo/releases/*").size
      releases.should >= 1
    end
  end

  describe "s3" do
    before(:each) do
      setup_files(:s3 => true)
      @example = "#{@root}/lib/setup/chap.json"
    end

    it "should upload and download chap.json" do
      @s3 = Chap::S3.new(
        :quiet => true,
        :config => "#{@system_root}/etc/chef/chap.yml"
      )
      @s3.upload(@example)
      data = @s3.download
      download = JSON.load(data)
      example = JSON.load(IO.read(@example))
      download.should == example
    end

    it "should upload, download and update chap.json via cli" do
      system("cd #{@root} && ./bin/chap s3_upload -f #{@example} -c #{@system_root}/etc/chef/chap.yml")
      system("cd #{@root} && ./bin/chap s3_download -f #{@root}/tmp/chap.json -c #{@system_root}/etc/chef/chap.yml")
      example = JSON.load(IO.read(@example))
      result = JSON.load(IO.read("#{@root}/tmp/chap.json"))
      result.should == example
      # update
      system("cd #{@root} && ./bin/chap s3_change --variables branch:feature repo:'git@github.com:tongueroo/hello.git' -c #{@system_root}/etc/chef/chap.yml")
      system("cd #{@root} && ./bin/chap s3_download -f #{@root}/tmp/chap.json -c #{@system_root}/etc/chef/chap.yml")
      result = JSON.load(IO.read("#{@root}/tmp/chap.json"))
      result['branch'].should == 'feature'
      result['repo'].should == 'git@github.com:tongueroo/hello.git'
    end
   end if ENV['TIER'] == "2"
end