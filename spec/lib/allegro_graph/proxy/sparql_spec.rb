require File.expand_path(File.join(File.dirname(__FILE__), "..", "..", "..", "spec_helper"))
require File.expand_path(File.join(File.dirname(__FILE__), "..", "..", "..", "..", "lib", "allegro_graph", "proxy", "sparql"))

describe AllegroGraph::Proxy::SparQL do

  before :each do
    @server = AllegroGraph::Server.new :username => "test", :password => "test"
    @catalog = AllegroGraph::Catalog.new @server, "test_catalog"
    @repository = AllegroGraph::Repository.new @catalog, "test_repository"
    @sparql = AllegroGraph::Proxy::SparQL.new @repository
  end

  describe "path" do

    it "should return the correct path" do
      @sparql.path.should == @repository.path
    end

  end

  describe "perform" do

    it "should return the query result" do
      result = @sparql.perform "SELECT ?subject WHERE { ?subject <http://xmlns.com/foaf/0.1/knows> ?object . }"
      result.should == {
        "names"   => [ "subject" ],
        "values"  => [ [ "\"another_subject\"" ], [ "\"test_subject\"" ] ]
      }
    end

  end

end
