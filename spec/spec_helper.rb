require "pp"
require "bundler"

Bundler.require(:development)

$root = File.expand_path('../../', __FILE__)

require "#{$root}/lib/chap"

module Helpers
  attr_reader :root, :system_root
  def setup
    @root = File.expand_path("../../", __FILE__)
    @system_root = "#{@root}/spec/fixtures/system_root"
    create_chap_files
  end

  # use to overwrite the demo one created from examples/chap.json for testing
  def create_chap_files(options={})
    FileUtils.mkdir_p("#{@system_root}/etc/chef")
    system("cd #{@root} && ./bin/chap setup -q -f -o #{@system_root}/etc/chef")
    update_chap_yml(options)
    update_chap_json(options)
  end

  # change system_root for chap.yml
  def update_chap_yml(options)
    path = "#{@system_root}/etc/chef/chap.yml"
    yaml = YAML.load(IO.read(path))
    yaml['chap'] = @system_root + yaml['chap']
    yaml['node'] = @system_root + yaml['node']
    File.open("#{@system_root}/etc/chef/chap.yml", "w") do |file|
      data = YAML.dump(yaml)
      file.write(data)
    end
  end

  # change system_root for chap.json
  def update_chap_json(options)
    chap = JSON.parse(IO.read("#{@system_root}/etc/chef/chap.json"))
    chap['deploy_to'] = @system_root + chap['deploy_to']
    chap['strategy'] = ENV['TIER'] == '2' ? "checkout" : "copy"
    chap['source'] = @root + "/spec/fixtures/chapdemo"
    chap['keep'] = 2
    chap['user'] = ENV['USER']
    chap['group'] = nil
    File.open("#{@system_root}/etc/chef/chap.json", "w") do |file|
      json = JSON.pretty_generate(chap)
      file.write(json)
    end
  end

  def tier(level)
    ENV['TIER'] == level.to_s
  end
end

RSpec.configure do |c|
  c.include Helpers
end