require File.expand_path(File.join(File.dirname(__FILE__), "..", "spec_helper"))
require File.expand_path(File.join(File.dirname(__FILE__), "..", "..", "lib", "allegro_graph"))

describe "query" do

  use_real_transport!

  before :each do
    @server = AllegroGraph::Server.new :username => "test", :password => "test"
    @repository = AllegroGraph::Repository.new @server, "test_repository"

    @repository.create_if_missing!

    statements = @repository.statements
    statements.create "\"test_subject\"", "<http://xmlns.com/foaf/0.1/knows>", "\"test_object\"", "\"test_context\""
    statements.create "\"another_subject\"", "<http://xmlns.com/foaf/0.1/knows>", "\"another_object\"", "\"test_context\""
  end

  describe "sparql" do

    before :each do
      @repository.query.language = :sparql
    end

    it "should respond to queried data" do
      result = @repository.query.perform "SELECT ?subject WHERE { ?subject <http://xmlns.com/foaf/0.1/knows> ?object . }"
      result["names"].should include("subject")
      result["values"].should include([ "\"another_subject\"" ], [ "\"test_subject\"" ])
    end

  end

  describe "prolog" do

    before :each do
      @repository.query.language = :prolog
    end

    it "should respond to queried data" do
      result = @repository.query.perform "(select (?subject) (q- ?subject !<http://xmlns.com/foaf/0.1/knows> ?object))"
      result["names"].should include("subject")
      result["values"].should include([ "\"another_subject\"" ], [ "\"test_subject\"" ])
    end

  end

end
