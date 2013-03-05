require File.expand_path(File.join(File.dirname(__FILE__), "..", "..", "..", "spec_helper"))
require File.expand_path(File.join(File.dirname(__FILE__), "..", "..", "..", "..", "lib", "allegro_graph", "proxy", "mapping"))

describe AllegroGraph::Proxy::Geometric do

  before :each do
    fake_transport!
    @server = AllegroGraph::Server.new :username => ENV['AG_USER'], :password => ENV['AG_PASS']
    @catalog = AllegroGraph::Catalog.new @server, "test_catalog"
    @repository = AllegroGraph::Repository.new @catalog, "test_repository"
    @mapping = AllegroGraph::Proxy::Mapping.new @repository
  end

  describe "path" do

    it "should return the correct path" do
      @mapping.path.should == "#{@repository.path}/mapping"
    end

  end

  describe "create" do

    it "should return true" do
      result = @mapping.create "<time>", "<http://www.w3.org/2001/XMLSchema#dateTime>"
      result.should be_true
    end

  end

  describe "delete" do

    it "should return true" do
      result = @mapping.delete "<time>"
      result.should be_true
    end

  end

end
