require "chap/version"
require "yaml"
require "json"
require "colorize"
require "logger"
require "thor"
require "pp"

$:.unshift File.expand_path('../', __FILE__)
require 'mash'
require 'chap/cli'
require 'chap/task'
require 'chap/special_methods'
require 'chap/config'
require 'chap/benchmarking'
require 'chap/runner'
require 'chap/hook'
require 'chap/strategy'