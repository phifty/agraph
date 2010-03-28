require File.expand_path(File.join(File.dirname(__FILE__), "..", "spec_helper"))
require File.expand_path(File.join(File.dirname(__FILE__), "..", "..", "lib", "allegro_graph"))

describe "integration" do

  use_real_transport!

  before :each do
    @server = AllegroGraph::Server.new :username => "test", :password => "test"
    @repository = AllegroGraph::Repository.new @server, "test_repository"    
  end

  describe "basic server functions" do

    before :each do
      @server = AllegroGraph::Server.new :username => "test", :password => "test"
    end

    it "should return the server's version" do
      @server.version.should == {
        :version  => "\"4.0.1a\"",
        :date     => "\"March 10, 2010 10:23:52 GMT-0800\"",
        :revision => "\"[unknown]\""
      }
    end

  end

  describe "repository listing" do

    before :each do
      @repository.create_if_missing!
    end

    it "should provide a list of repositories" do
      @server.root_catalog.repositories.should == [ @repository ]
    end

  end

  describe "repository creation" do

    before :each do
      @repository.delete_if_exists!
    end

    it "should create the repository" do
      lambda do
        @repository.create!
      end.should change(@repository, :exists?).from(false).to(true)
    end

  end

  describe "repository deletion" do

    before :each do
      @repository.create_if_missing!
    end

    it "should delete the repository" do
      lambda do
        @repository.delete!
      end.should change(@repository, :exists?).from(true).to(false)
    end

  end

  describe "statements" do

    before :each do
      @repository.create_if_missing!
      @statements = @repository.statements
    end

    describe "creation" do

      it "should take a statement" do
        result = @statements.create "\"test_subject\"", "\"test_predicate\"", "\"test_object\"", "\"test_context\""
        result.should be_true
      end

    end

    describe "finding" do

      before :each do
        @statements.delete
        @statements.create "\"test_subject\"", "\"test_predicate\"", "\"test_object\"", "\"test_context\""
        @statements.create "\"another_subject\"", "\"test_predicate\"", "\"another_object\"", "\"test_context\""
      end

      it "should find all statements" do
        statements = @statements.find
        statements.should == [
          [ "\"test_subject\"", "\"test_predicate\"", "\"test_object\"", "\"test_context\"" ],
          [ "\"another_subject\"", "\"test_predicate\"", "\"another_object\"", "\"test_context\"" ]
        ]
      end

      it "should find statements by filter options" do
        statements = @statements.find :subject => "\"test_subject\""
        statements.should == [
          [ "\"test_subject\"", "\"test_predicate\"", "\"test_object\"", "\"test_context\"" ]
        ]
      end

    end

    describe "deletion" do

      before :each do
        @statements.create "\"test_subject\"", "\"test_predicate\"", "\"test_object\"", "\"test_context\""        
      end

      it "should delete all statements" do
        lambda do
          @statements.delete
        end.should change(@repository, :size).to(0)
      end

    end
    
  end

  describe "query bypass" do

    before :each do
      @repository.create_if_missing!

      statements = @repository.statements
      statements.create "\"test_subject\"", "<http://xmlns.com/foaf/0.1/knows>", "\"test_object\"", "\"test_context\""
      statements.create "\"another_subject\"", "<http://xmlns.com/foaf/0.1/knows>", "\"another_object\"", "\"test_context\""
    end

    context "sparql" do

      before :each do
        @repository.query.language = :sparql
      end
      
      it "should respond to queried data" do
        result = @repository.query.perform "SELECT ?subject WHERE { ?subject <http://xmlns.com/foaf/0.1/knows> ?object . }"
        result["names"].should include("subject")
        result["values"].should include([ "\"another_subject\"" ], [ "\"test_subject\"" ])
      end

    end

    context "prolog" do

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

  describe "geo" do

    before :each do
      @repository.create_if_missing!

      @geo = @repository.geo
    end

    describe "types" do

      it "should provide a cartesian type" do
        result = @geo.cartesian_type 1.0, 2.0, 20.0, 2.0, 20.0
        result.should == "\"<http://franz.com/ns/allegrograph/3.0/geospatial/cartesian/2.0/20.0/2.0/20.0/1.0>\""
      end

      it "should provide a spherical type" do
        result = @geo.spherical_type 1.0, :degree, 2.0, 20.0, 2.0, 20.0
        result.should == "\"<http://franz.com/ns/allegrograph/3.0/geospatial/spherical/degrees/2.0/20.0/2.0/20.0/1.0>\""
      end
      
    end

  end

end
