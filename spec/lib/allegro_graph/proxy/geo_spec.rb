require File.expand_path(File.join(File.dirname(__FILE__), "..", "..", "..", "spec_helper"))
require File.expand_path(File.join(File.dirname(__FILE__), "..", "..", "..", "..", "lib", "allegro_graph", "proxy", "query"))

describe AllegroGraph::Proxy::Geo do

  before :each do
    @server = AllegroGraph::Server.new :username => "test", :password => "test"
    @catalog = AllegroGraph::Catalog.new @server, "test_catalog"
    @repository = AllegroGraph::Repository.new @catalog, "test_repository"
    @geo = AllegroGraph::Proxy::Geo.new @repository
  end

  describe "path" do

    it "should return the correct path" do
      @geo.path.should == "#{@repository.path}/geo"
    end

  end

  describe "cartesian_type" do

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
