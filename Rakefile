require 'rubygems'
require 'spec/rake/spectask'

task :default => :spec

Spec::Rake::SpecTask.new(:spec) do |t|
  t.spec_opts = ['--options', "#{File.expand_path(File.dirname(__FILE__))}/spec/spec.opts"]
end

namespace :spec do
  desc "Run specs in nested documenting format"
  Spec::Rake::SpecTask.new(:doc) do |t|
    t.spec_opts = ["--format", "nested", '--colour']
    t.spec_files = FileList['spec/**/*/*_spec.rb']
  end
end
