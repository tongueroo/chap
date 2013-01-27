require "pp"
require "bundler"

Bundler.require(:development)

$root = File.expand_path('../../', __FILE__)

require "#{$root}/lib/chap"

# use to overwrite the demo one created from examples/chap.json for testing
def write_chap_json
  FileUtils.mkdir_p("#{@system_root}/etc/chef")
  system("cd #{@root} && ./bin/chap setup -q -f -o #{@system_root}/etc/chef")
  # change system_root for chap.yml
  yaml = YAML.load(IO.read("#{@system_root}/etc/chef/chap.yml"))
  yaml['chap'] = @system_root + yaml['chap']
  yaml['node'] = @system_root + yaml['node']
  File.open("#{@system_root}/etc/chef/chap.yml", "w") do |file|
    data = YAML.dump(yaml)
    file.write(data)
  end
  # change system_root for chap.json
  chap = JSON.parse(IO.read("#{@system_root}/etc/chef/chap.json"))
  chap['deploy_to'] = @system_root + chap['deploy_to']
  if ENV['TIER'] == '2'
    chap['strategy'] = "checkout"
  else
    chap['strategy'] = "copy"
  end
  chap['source'] = @root + "/spec/fixtures/chapdemo"
  chap['keep'] = 2
  chap['user'] = ENV['USER']
  chap['group'] = RUBY_PLATFORM =~ /darwin/ ? 'staff' : ENV['USER']
  File.open("#{@system_root}/etc/chef/chap.json", "w") do |file|
    json = JSON.pretty_generate(chap)
    file.write(json)
  end
end