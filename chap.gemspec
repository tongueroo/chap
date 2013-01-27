# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'chap/version'

Gem::Specification.new do |gem|
  gem.name          = "chap"
  gem.version       = Chap::VERSION
  gem.authors       = ["Tung Nguyen", "John Degner"]
  gem.email         = ["tongueroo@gmail.com", "johnbdegner@gmail.com"]
  gem.description   = %q{chef + capistrano = chap: deploy your app with either chef or capistrano}
  gem.summary       = %q{chef + capistrano = chap: deploy your app with either chef or capistrano}
  gem.homepage      = "https://github.com/tongueroo/chap"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_dependency "rake"
  gem.add_dependency "json"
  gem.add_dependency "thor"
  gem.add_dependency "colorize"
  gem.add_dependency "logger"
  gem.add_dependency "aws-sdk"

  gem.add_development_dependency 'rspec'
  gem.add_development_dependency 'guard'
  gem.add_development_dependency 'guard-rspec'
  gem.add_development_dependency 'guard-bundler'
  gem.add_development_dependency 'rb-fsevent'
  # gem.add_development_dependency 'fakefs'
end
