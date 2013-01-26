strategy = File.expand_path('../strategy', __FILE__)
require "#{strategy}/base"
Dir.glob("#{strategy}/*").each do |file|
  require file
end