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

  describe "a repository" do

    before :each do
      @repository.create_if_missing!
    end
    
    it "should have a size of zero" do
      @repository.size.should == 0
    end

    it "should take a statement" do
      @repository.create_statement("\"test_subject\"", "\"test_predicate\"", "\"test_object\"", "\"test_context\"").should be_true
    end

    context "filled with statements" do

      before :each do
        @repository.delete_statements
        @repository.create_statement "\"test_subject\"", "\"test_predicate\"", "\"test_object\"", "\"test_context\""
        @repository.create_statement "\"another_subject\"", "\"test_predicate\"", "\"another_object\"", "\"test_context\""
      end

      it "should have a size of two or more" do
        @repository.size.should >= 2
      end

      it "should find all statements" do
        statements = @repository.find_statements
        statements.should == [
          [ "\"test_subject\"", "\"test_predicate\"", "\"test_object\"", "\"test_context\"" ],
          [ "\"another_subject\"", "\"test_predicate\"", "\"another_object\"", "\"test_context\"" ]
        ]
      end

      it "should find statements by filter options" do
        statements = @repository.find_statements :subject => "test_subject"
        statements.should == [
          [ "\"test_subject\"", "\"test_predicate\"", "\"test_object\"", "\"test_context\"" ]
        ]
      end

    end
    
  end

end
