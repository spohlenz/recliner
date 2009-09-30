require 'spec/rake/spectask'
require 'cucumber/rake/task'
require 'rake/rdoctask'

task :default => :spec

Spec::Rake::SpecTask.new(:spec) do |t|
  t.libs << 'lib'
  t.spec_opts = ['--options', "#{File.expand_path(File.dirname(__FILE__))}/spec/spec.opts"]
end

namespace :spec do
  desc "Run specs in nested documenting format"
  Spec::Rake::SpecTask.new(:doc) do |t|
    t.libs << 'lib'
    t.spec_opts = ["--format", "nested", '--colour']
  end
end

Cucumber::Rake::Task.new(:features, "Run Cucumber features (except @completed and @pending)") do |t|
  t.fork = true
  t.cucumber_opts = ['--format', (ENV['CUCUMBER_FORMAT'] || 'pretty'), '-r features', '--tags ~@completed,~@pending']
end

namespace :features do
  Cucumber::Rake::Task.new(:all, "Run all Cucumber features (except @pending)") do |t|
    t.fork = true
    t.cucumber_opts = ['--format', (ENV['CUCUMBER_FORMAT'] || 'pretty'), '-r features', '--tags ~@pending']
  end
end

desc "Generate documentation"
Rake::RDocTask.new(:doc) do |rdoc|
  rdoc.rdoc_dir = 'doc'
  rdoc.options << '--line-numbers' << '--inline-source'
  rdoc.rdoc_files.include('lib')
end

desc "Report code statistics (KLOCs, etc)"
task :stats do
  require 'vendor/code_statistics'
  CodeStatistics::TEST_TYPES.replace ['Specs']
  CodeStatistics.new(['Recliner Library', 'lib'], ['Specs', 'spec']).to_s
end

begin
  require 'jeweler'
  
  Jeweler::Tasks.new do |gem|
    gem.name = "recliner"
    gem.summary = "CouchDB ORM for Ruby/Rails"
    gem.description = "Recliner is a CouchDB ORM for Ruby/Rails similar to ActiveRecord and DataMapper."
    gem.email = "sam@sampohlenz.com"
    gem.homepage = "http://github.com/spohlenz/recliner"
    gem.authors = ["Sam Pohlenz"]
    
    gem.add_dependency('rest-client', '>= 1.0.3')
    gem.add_dependency('json', '>= 1.1.9')
    gem.add_dependency('uuid', '>= 2.0.2')
  end
rescue LoadError
  puts "Jeweler not available. Install it with: sudo gem install technicalpickles-jeweler -s http://gems.github.com"
end
