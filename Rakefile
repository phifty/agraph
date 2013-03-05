require 'bundler/gem_tasks'
require 'rspec/core/rake_task'
require 'reek/rake/task'
require 'rdoc/task'

RSpec::Core::RakeTask.new(:spec) do |t|
  t.pattern = "spec/lib/**/*_spec.rb"
end

Rake::RDocTask.new(:spec)

task :default => :spec

Reek::Rake::Task.new do |t|
  t.fail_on_error = false
end

namespace :spec do

  desc "Run all integration specs in spec/integration directory"
  RSpec::Core::RakeTask.new(:integration) do |task|
    task.pattern = "spec/integration/**/*_spec.rb"
  end

end