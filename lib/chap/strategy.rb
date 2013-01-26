strategy = File.expand_path('../strategy', __FILE__)
require "#{strategy}/base"
require "#{strategy}/checkout"
Dir.glob("#{strategy}/*.rb").each do |file|
  require file
end