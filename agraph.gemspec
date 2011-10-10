# encoding: utf-8

specification = Gem::Specification.new do |specification|
  specification.name                  = "agraph"
  specification.version               = "0.1.5"
  specification.date                  = "2011-10-10"
  specification.email                 = "b.phifty@gmail.com"
  specification.homepage              = "http://github.com/abrisse/agraph"
  specification.summary               = "Client for the AllegroGraph 4.x graph database."
  specification.description           = "The gem provides a client for the AllegroGraph 4.x RDF graph database. Features like searching geo-spatial data, type mapping and transactions are supported."
  specification.rubyforge_project     = "agraph"
  specification.has_rdoc              = true
  specification.authors               = [ "Philipp Brüll", "Aymeric Brisse" ]
  specification.files                 = [ "README.rdoc", "Rakefile" ] + Dir["{lib,spec}/**/*"]
  specification.extra_rdoc_files      = [ "README.rdoc" ]
  specification.require_path          = "lib"
  specification.required_ruby_version = ">= 1.8.7"

  specification.add_dependency "transport", ">= 1.0.0"
  specification.add_development_dependency "rspec", ">= 2"
  specification.add_development_dependency "reek", ">= 1.2"
end
