require File.expand_path(File.join(File.dirname(__FILE__), "..", "spec_helper"))
require File.expand_path(File.join(File.dirname(__FILE__), "..", "..", "lib", "allegro_graph"))

describe "federations" do

  use_real_transport!

  before :each do
    @server = AllegroGraph::Server.new :username => "test", :password => "test"
    @repository = AllegroGraph::Repository.new @server, "test_repository"
    @federation = AllegroGraph::Federation.new @server, "test_federation", :repository_names => [ @repository.name ]
  end

  it "should create a federation" do
    @federation.delete_if_exists!
    @federation.create!.should be_true
  end

  it "should list the federations" do
    @federation.create_if_missing!
    @server.federations.should include(@federation)
  end

  it "should delete a federation" do
    @federation.create_if_missing!
    @federation.delete!.should be_true
  end

end
