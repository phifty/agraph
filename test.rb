require 'lib/agraph'

server = AllegroGraph::Server.new :username => "test", :password => "test"

catalog = AllegroGraph::Catalog.new server, "tests"
repository = AllegroGraph::Repository.new catalog, "foo"

# repository = AllegroGraph::Repository.new server, "test_repository"

type = repository.geo.cartesian_type 1, -100, -100, 100, 100

repository.statements.create "\"phil\"", "\"at\"", "\"+1+1\"^^#{type}"
#repository.statements.create "\"bernd\"", "\"at\"", "\"+5+80\"^^#{type}"
#repository.statements.create "\"manni\"", "\"at\"", "\"+30+10\"^^#{type}"
#repository.statements.create "\"anna\"", "\"at\"", "\"+35+50\"^^#{type}"

repository.geo.create_polygon "right", type, [ [ 0, -100 ], [ 0, 100 ], [ 100, 100 ], [ 100, -100 ] ]

puts repository.geo.inside_polygon(type, "\"at\"", "right").inspect
