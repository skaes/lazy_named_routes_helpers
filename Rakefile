require 'bundler'
Bundler::GemHelper.install_tasks

require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'

Rake::RDocTask.new do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = 'lazy_named_routes_helpers'
  rdoc.options << '--line-numbers' << '--inline-source' << '--quiet'
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

task :default => :rdoc
