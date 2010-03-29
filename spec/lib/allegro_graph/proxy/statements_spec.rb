require File.expand_path(File.join(File.dirname(__FILE__), "..", "..", "..", "spec_helper"))
require File.expand_path(File.join(File.dirname(__FILE__), "..", "..", "..", "..", "lib", "allegro_graph", "proxy", "statements"))

describe AllegroGraph::Proxy::Statements do

  before :each do
    @server = AllegroGraph::Server.new :username => "test", :password => "test"
    @catalog = AllegroGraph::Catalog.new @server, "test_catalog"
    @repository = AllegroGraph::Repository.new @catalog, "test_repository"
    @statements = AllegroGraph::Proxy::Statements.new @repository
  end

  describe "path" do

    it "should return the correct path" do
      @statements.path.should == "#{@repository.path}/statements"
    end
    
  end

  describe "create" do

    it "should create a statement" do
      result = @statements.create "\"test_subject\"", "\"test_predicate\"", "\"test_object\"", "\"test_context\""
      result.should be_true
    end

  end

  describe "find" do

    it "should find all statements" do
      result = @statements.find
      result.should == [
        [ "\"test_subject\"", "\"test_predicate\"", "\"test_object\"", "\"test_context\"" ],
        [ "\"another_subject\"", "\"test_predicate\"", "\"another_object\"", "\"test_context\"" ]
      ]
    end

    it "should find statements by filter options" do
      result = @statements.find :subject => "test_subject"
      result.should == [
        [ "\"test_subject\"", "\"test_predicate\"", "\"test_object\"", "\"test_context\"" ]
      ]
    end

  end

  describe "delete" do

    it "should delete all statements" do
      result = @statements.delete :subject => "test_subject"
      result.should be_true
    end

  end

end
