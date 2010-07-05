require 'rubygems'
gem 'rspec'
require 'spec'
require "rake/rdoctask"
require 'rake/gempackagetask'
require 'spec/rake/spectask'

task :default => :spec

specification = Gem::Specification.new do |specification|
  specification.name              = "agraph"
  specification.version           = "0.1.1"
  specification.date              = "2010-07-05"
  specification.email             = "b.phifty@gmail.com"
  specification.homepage          = "http://github.com/phifty/agraph"
  specification.summary           = "Client for the AllegroGraph 4.x graph database."
  specification.description       = "The gem provides a client for the AllegroGraph 4.x RDF graph database. Features like searching geo-spatial data, type mapping and transactions are supported."
  specification.rubyforge_project = "agraph"
  specification.has_rdoc          = true
  specification.authors           = [ "Philipp Bruell" ]
  specification.files             = [ "README.rdoc", "Rakefile" ] + Dir["{lib,spec}/**/*"]
  specification.extra_rdoc_files  = [ "README.rdoc" ]
  specification.require_path      = "lib"
end

Rake::GemPackageTask.new(specification) do |package|
  package.gem_spec = specification
end

desc "Generate the rdoc"
Rake::RDocTask.new do |rdoc|
  rdoc.rdoc_files.add [ "README.rdoc", "lib/**/*.rb" ]
  rdoc.main   = "README.rdoc"
  rdoc.title  = "Client for the AllegroGraph 4.x graph database."
end

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
