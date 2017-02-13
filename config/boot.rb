require 'bundler'
Bundler.require

Dynamoid.configure do |config|
  config.adapter = 'aws_sdk_v2'
  config.namespace = ENV['DYNAMO_DB_NAMESPACE']
  config.warn_on_scan = true
  config.read_capacity = 5
  config.write_capacity = 5

  if ENV['RACK_ENV'] != 'production'
    host = ENV['DYNAMO_DB_HOST']
    port = ENV['DYNAMO_DB_PORT']
    config.endpoint = "http://#{host}:#{port}"
  end
end

ROOT_DIR = File.join(File.expand_path(File.dirname(__FILE__)), '..')
SOURCES_DIR = File.join(ROOT_DIR, 'lib')
ActiveSupport::Dependencies.autoload_paths = Dir[File.join(SOURCES_DIR, '**')]
