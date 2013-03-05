# encoding: utf-8

specification = Gem::Specification.new do |specification|
  specification.name                  = "agraph"
  specification.version               = "0.2"
  specification.date                  = "2013-03-05"
  specification.email                 = "b.phifty@gmail.com"
  specification.homepage              = "http://github.com/phifty/agraph"
  specification.summary               = "Client for the AllegroGraph 4.x graph database."
  specification.description           = "The gem provides a client for the AllegroGraph 4.x RDF graph database. Features like searching geo-spatial data, type mapping and transactions are supported."
  specification.rubyforge_project     = "agraph"
  specification.has_rdoc              = true
  specification.authors               = [ "Philipp Brüll", "Aymeric Brisse" ]
  specification.files                 = [ "README.rdoc", "Rakefile" ] + Dir["{lib,spec}/**/*"]
  specification.extra_rdoc_files      = [ "README.rdoc" ]
  specification.require_path          = "lib"
  specification.required_ruby_version = ">= 1.8.7"

  specification.add_dependency "transport", '~> 1.0.5'
  specification.add_development_dependency "rspec", '~> 2.12'
  specification.add_development_dependency "reek", "~> 1.3"
  specification.add_development_dependency "rake", '~> 10.0'
  specification.add_development_dependency "rdoc", '~> 3.0'
  specification.add_development_dependency "dotenv", '~> 0.5'
end
