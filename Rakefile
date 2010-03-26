require 'rubygems'
gem 'rspec'
require 'spec'
require 'spec/rake/spectask'

task :default => :spec

desc "Run all specs in spec directory"
Spec::Rake::SpecTask.new do |task|
  task.spec_files = FileList["spec/lib/**/*_spec.rb"]
end

namespace :spec do

  desc "Run all integration specs in spec/integration directory"
  Spec::Rake::SpecTask.new(:integration) do |task|
    task.spec_files = FileList["spec/integration/**/*_spec.rb"]
  end

end