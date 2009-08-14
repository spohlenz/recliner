require 'rubygems'

require 'spec/rake/spectask'
require 'cucumber/rake/task'

task :default => :spec

Spec::Rake::SpecTask.new(:spec) do |t|
  t.spec_opts = ['--options', "#{File.expand_path(File.dirname(__FILE__))}/spec/spec.opts"]
end

Cucumber::Rake::Task.new(:features) do |t|
  t.fork = true
  t.cucumber_opts = ['--format', (ENV['CUCUMBER_FORMAT'] || 'pretty'), '-r features']
end

namespace :spec do
  desc "Run specs in nested documenting format"
  Spec::Rake::SpecTask.new(:doc) do |t|
    t.spec_opts = ["--format", "nested", '--colour']
    t.spec_files = FileList['spec/**/*/*_spec.rb']
  end
end
