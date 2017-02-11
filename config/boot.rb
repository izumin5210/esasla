require 'bundler'
Bundler.require

ROOT_DIR = File.join(File.expand_path(File.dirname(__FILE__)), '..')
SOURCES_DIR = File.join(ROOT_DIR, 'lib')
ActiveSupport::Dependencies.autoload_paths = Dir[File.join(SOURCES_DIR, '**')]
