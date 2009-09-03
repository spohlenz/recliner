require 'spec/rake/spectask'
require 'cucumber/rake/task'

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

desc "Report code statistics (KLOCs, etc)"
task :stats do
  require 'vendor/code_statistics'
  CodeStatistics::TEST_TYPES.replace ['Specs']
  CodeStatistics.new(['Recliner Library', 'lib'], ['Specs', 'spec']).to_s
end
