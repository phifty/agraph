require File.expand_path(File.join(File.dirname(__FILE__), "..", "spec_helper"))
require File.expand_path(File.join(File.dirname(__FILE__), "..", "..", "lib", "allegro_graph"))

describe "integration" do

  use_real_transport!

  describe "basic server functions" do

    before :each do
      @server = AllegroGraph::Server.new :username => "test", :password => "test"
    end

    it "should return the server's version" do
      @server.version.should == {
        :version  => "4.0.1a",
        :date     => "March 10, 2010 10:23:52 GMT-0800",
        :revision => "[unknown]"
      }
    end

  end

  describe "repository listing" do

    before :each do
      @server = AllegroGraph::Server.new :username => "test", :password => "test"
      @repository = AllegroGraph::Repository.new @server, "test_repository"
      @repository.create_if_missing!
    end

    it "should provide a list of repositories" do
      @server.root_catalog.repositories.should == [ @repository ]
    end

  end

  describe "repository creation" do

    before :each do
      @server = AllegroGraph::Server.new :username => "test", :password => "test"
      @repository = AllegroGraph::Repository.new @server, "test_repository"
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
      @server = AllegroGraph::Server.new :username => "test", :password => "test"
      @repository = AllegroGraph::Repository.new @server, "test_repository"
      @repository.create_if_missing!
    end

    it "should delete the repository" do
      lambda do
        @repository.delete!
      end.should change(@repository, :exists?).from(true).to(false)
    end

  end

  describe "repository size" do

    before :each do
      @server = AllegroGraph::Server.new :username => "test", :password => "test"
      @repository = AllegroGraph::Repository.new @server, "test_repository"
      @repository.create_if_missing!
    end

    it "should return the number of statements" do
      @repository.size.should == 0
    end

  end

end
