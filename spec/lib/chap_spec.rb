require 'spec_helper'

describe Chap do
  before(:each) do
    setup
  end

  after(:each) do
    FileUtils.rm_rf(system_root)
  end

  describe "internal code deploy" do
    before(:each) do
      @chap = Chap::Runner.new(
        :silence => true,
        :quiet => true,
        :config => "#{system_root}/etc/chef/chap.yml"
      )
      timestamp = @chap.config.timestamp
      @release_path = "#{system_root}/data/chapdemo/releases/#{timestamp}"
    end

    it "should deploy code" do
      @chap.deploy
      File.exist?("#{system_root}/data/chapdemo/shared").should be_true
      File.exist?(@release_path).should be_true
      File.symlink?("#{system_root}/data/chapdemo/current").should be_true
      releases = Dir.glob("#{system_root}/data/chapdemo/releases/*").size
      releases.should >= 1
    end
  end

  describe "cli deploy" do
    it "should deploy code via command line" do
      system("cd #{root} && ./bin/chap deploy -s -q -c #{system_root}/etc/chef/chap.yml")
      releases = Dir.glob("#{system_root}/data/chapdemo/releases/*").sort
      timestamp = releases.last.split('/').last
      release_path = "#{system_root}/data/chapdemo/releases/#{timestamp}"

      File.exist?("#{system_root}/data/chapdemo/shared").should be_true
      File.exist?(release_path).should be_true
      File.symlink?("#{system_root}/data/chapdemo/current").should be_true
      releases = Dir.glob("#{system_root}/data/chapdemo/releases/*").size
      releases.should >= 1
    end

    it "should deploy code and test hook" do
      system("cd #{root} && ./bin/chap deploy -s -q -c #{system_root}/etc/chef/chap.yml")
      releases = Dir.glob("#{system_root}/data/chapdemo/releases/*").sort
      timestamp = releases.last.split('/').last
      release_path = "#{system_root}/data/chapdemo/releases/#{timestamp}"
      current_path = "#{system_root}/data/chapdemo/current"
      File.exist?(release_path).should be_true
      File.exist?("#{release_path}/deploy.txt").should be_true

      # test hook deploy
      FileUtils.rm_f("#{release_path}/deploy.txt")
      File.exist?("#{release_path}/deploy.txt").should be_false
      system("cd #{root} && ./bin/chap hook deploy -q -c #{system_root}/etc/chef/chap.yml")
      File.exist?("#{release_path}/deploy.txt").should be_true

      # test hook restart
      FileUtils.rm_f("#{current_path}/restart.txt")
      system("cd #{root} && ./bin/chap hook restart -q -c #{system_root}/etc/chef/chap.yml")
      File.exist?("#{current_path}/restart.txt").should be_true
    end

    it "should deploy code stopping and continuing at symlink" do
      system("cd #{root} && ./bin/chap deploy --stop-at-symlink -s -q -c #{system_root}/etc/chef/chap.yml")
      releases = Dir.glob("#{system_root}/data/chapdemo/releases/*").sort
      timestamp = releases.last.split('/').last
      release_path = "#{system_root}/data/chapdemo/releases/#{timestamp}"
      current_path = "#{system_root}/data/chapdemo/current"
      File.exist?(release_path).should be_true
      # no current symlink
      File.exist?(current_path).should_not be_true
      releases = Dir.glob("#{system_root}/data/chapdemo/releases/*").size
      releases.should == 1
      sleep 2 if tier(2)
      # continue deploy
      system("cd #{root} && ./bin/chap deploy --cont-at-symlink -s -q -c #{system_root}/etc/chef/chap.yml")
      link = File.readlink(current_path)
      link.should == release_path
    end

    it "should symlink previous release to current" do
      system("cd #{root} && ./bin/chap deploy --stop-at-symlink -q -c #{system_root}/etc/chef/chap.yml")
      releases = Dir.glob("#{system_root}/data/chapdemo/releases/*").sort
      timestamp = releases.last.split('/').last
      release_path = "#{system_root}/data/chapdemo/releases/#{timestamp}"
      current_path = "#{system_root}/data/chapdemo/current"
      File.exist?(release_path).should be_true
      # no current symlink
      File.exist?(current_path).should_not be_true
      system("cd #{root} && ./bin/chap symlink -q -c #{system_root}/etc/chef/chap.yml")
      File.exist?(current_path).should be_true
      link = File.readlink(current_path)
      link.should == release_path
      # running twice should link to same symlink
      system("cd #{root} && ./bin/chap symlink -q -c #{system_root}/etc/chef/chap.yml")
      link = File.readlink(current_path)
      link.should == release_path
    end

    it "should only respect keep option" do
      system("cd #{root} && ./bin/chap deploy -s -q -c #{system_root}/etc/chef/chap.yml")
      sleep 1
      system("cd #{root} && ./bin/chap deploy -s -q -c #{system_root}/etc/chef/chap.yml")
      releases = Dir.glob("#{system_root}/data/chapdemo/releases/*").size
      releases.should == 2 # test the keep option
    end
  end
end