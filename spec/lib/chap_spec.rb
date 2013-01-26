require 'spec_helper'

describe Chap do
  before(:each) do
    @root = File.expand_path("../../../", __FILE__)
    @system_root = "#{@root}/spec/fixtures/system_root"
    write_chap_json

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