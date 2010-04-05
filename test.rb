require 'lib/agraph'

server = AllegroGraph::Server.new :username => "test", :password => "test"

catalog = AllegroGraph::Catalog.new server, "tests"
repository = AllegroGraph::Repository.new catalog, "foo"

repository.create!

# repository = AllegroGraph::Repository.new server, "test_repository"

type = repository.geometric.cartesian_type :strip_width => 1,
                                           :x_min       => -100,
                                           :y_min       => -100,
                                           :x_max       => 100,
                                           :y_max       => 100

repository.statements.create "\"foo\"", "\"at\"", "\"+1+1\"^^#{type}"
repository.statements.create "\"bar\"", "\"at\"", "\"-2.5+3.4\"^^#{type}"
repository.statements.create "\"baz\"", "\"at\"", "\"-1+1\"^^#{type}"
repository.statements.create "\"bug\"", "\"at\"", "\"+10-2.421553215\"^^#{type}"

polygon = [ [ 0, -100 ], [ 0, 100 ], [ 100, 100 ], [ 100, -100 ] ]

repository.geometric.create_polygon polygon,
                                    :name => "right",
                                    :type => type

#url = URI "http://localhost:10035/catalogs/tests/repositories/foo/geo/polygon?resource=%22right%22&point=%22%2B0-100%22%5E%5E%3Chttp%3A//franz.com/ns/allegrograph/3.0/geospatial/cartesian/-100.0/100.0/-100.0/100.0/1.0%3E&point=%22%2B0%2B100%22%5E%5E%3Chttp%3A//franz.com/ns/allegrograph/3.0/geospatial/cartesian/-100.0/100.0/-100.0/100.0/1.0%3E&point=%22%2B100%2B100%22%5E%5E%3Chttp%3A//franz.com/ns/allegrograph/3.0/geospatial/cartesian/-100.0/100.0/-100.0/100.0/1.0%3E&point=%22%2B100-100%22%5E%5E%3Chttp%3A//franz.com/ns/allegrograph/3.0/geospatial/cartesian/-100.0/100.0/-100.0/100.0/1.0%3E"

#AllegroGraph::ExtendedTransport.request :put, url,
#                                        :auth_type            => :basic,
#                                        :username             => "test",
#                                        :password             => "test",
#                                        :expected_status_code => 204

result = repository.statements.find_inside_polygon :polygon_name  => "right",
                                                   :type          => type,
                                                   :predicate     => "\"at\""

puts result.inspect
