require File.expand_path(File.join(File.dirname(__FILE__), "..", "..", "..", "spec_helper"))
require File.expand_path(File.join(File.dirname(__FILE__), "..", "..", "..", "..", "lib", "allegro_graph", "proxy", "query"))

describe AllegroGraph::Proxy::Query do

  before :each do
    @server = AllegroGraph::Server.new :username => "test", :password => "test"
    @catalog = AllegroGraph::Catalog.new @server, "test_catalog"
    @repository = AllegroGraph::Repository.new @catalog, "test_repository"
    @query = AllegroGraph::Proxy::Query.new @repository
  end

  describe "path" do

    it "should return the correct path" do
      @query.path.should == @repository.path
    end

  end

  describe "language=" do

    it "should take :sparql" do
      @query.language = :sparql
      @query.language.should == :sparql
    end

    it "should take :prolog" do
      @query.language = :prolog
      @query.language.should == :prolog
    end

    it "should raise a NotImplementedError on invalid language" do
      lambda do
        @query.language = :invalid
      end.should raise_error(NotImplementedError)
    end

  end

  describe "perform" do

    it "should return the sparql query result" do
      result = @query.perform "SELECT ?subject WHERE { ?subject <http://xmlns.com/foaf/0.1/knows> ?object . }"
      result.should == {
        "names"   => [ "subject" ],
        "values"  => [ [ "\"another_subject\"" ], [ "\"test_subject\"" ] ]
      }
    end

    it "should return the query result" do
      @query.language = :prolog
      result = @query.perform "(select (?subject) (q- ?subject ?predicate ?object))​"
      result.should == {
        "names"   => [ "subject" ],
        "values"  => [ [ "\"another_subject\"" ], [ "\"test_subject\"" ] ]
      }
    end

  end

end
