require File.expand_path(File.join(File.dirname(__FILE__), "..", "spec_helper"))
require File.expand_path(File.join(File.dirname(__FILE__), "..", "..", "lib", "allegro_graph"))

describe "repository" do

  use_real_transport!

  before :each do
    @server = AllegroGraph::Server.new :username => "test", :password => "test"
    @repository = AllegroGraph::Repository.new @server, "test_repository"
  end

  describe "listing" do

    before :each do
      @repository.create_if_missing!
    end

    it "should provide a list of repositories" do
      @server.root_catalog.repositories.should == [ @repository ]
    end

  end

  describe "creation" do

    before :each do
      @repository.delete_if_exists!
    end

    it "should create the repository" do
      lambda do
        @repository.create!
      end.should change(@repository, :exists?).from(false).to(true)
    end

  end

  describe "deletion" do

    before :each do
      @repository.create_if_missing!
    end

    it "should delete the repository" do
      lambda do
        @repository.delete!
      end.should change(@repository, :exists?).from(true).to(false)
    end

  end

end
