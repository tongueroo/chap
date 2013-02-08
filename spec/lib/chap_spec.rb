require 'spec_helper'

describe Chap do
  before(:each) do
    @root = File.expand_path("../../../", __FILE__)
    @system_root = "#{@root}/spec/fixtures/system_root"
  end

  describe "internal code deploy" do
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
  end

  describe "cli deploy" do
    before(:each) do
      setup_files
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

    it "should deploy code and test hook" do
      system("cd #{@root} && ./bin/chap deploy -q -c #{@system_root}/etc/chef/chap.yml")
      releases = Dir.glob("#{@system_root}/data/chapdemo/releases/*").sort
      timestamp = releases.last.split('/').last
      release_path = "#{@system_root}/data/chapdemo/releases/#{timestamp}"
      current_path = "#{@system_root}/data/chapdemo/current"
      File.exist?(release_path).should be_true
      File.exist?("#{release_path}/deploy.txt").should be_true

      # test hook deploy
      FileUtils.rm_f("#{release_path}/deploy.txt")
      File.exist?("#{release_path}/deploy.txt").should be_false
      system("cd #{@root} && ./bin/chap hook deploy -q -c #{@system_root}/etc/chef/chap.yml")
      File.exist?("#{release_path}/deploy.txt").should be_true

      # test hook restart
      FileUtils.rm_f("#{current_path}/restart.txt")
      system("cd #{@root} && ./bin/chap hook restart -q -c #{@system_root}/etc/chef/chap.yml")
      File.exist?("#{current_path}/restart.txt").should be_true
    end
  end
end