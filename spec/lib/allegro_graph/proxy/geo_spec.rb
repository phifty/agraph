require File.expand_path(File.join(File.dirname(__FILE__), "..", "..", "..", "spec_helper"))
require File.expand_path(File.join(File.dirname(__FILE__), "..", "..", "..", "..", "lib", "allegro_graph", "proxy", "query"))

describe AllegroGraph::Proxy::Geo do

  before :each do
    @server = AllegroGraph::Server.new :username => "test", :password => "test"
    @catalog = AllegroGraph::Catalog.new @server, "test_catalog"
    @repository = AllegroGraph::Repository.new @catalog, "test_repository"
    @geo = AllegroGraph::Proxy::Geo.new @repository
    @type = @geo.cartesian_type 1.0, 2.0, 2.0, 20.0, 20.0
  end

  describe "path" do

    it "should return the correct path" do
      @geo.path.should == "#{@repository.path}/geo"
    end

  end

  describe "cartesian_type" do

    it "should provide a cartesian type" do
      result = @geo.cartesian_type 1.0, 2.0, 2.0, 20.0, 20.0
      result.should == "<http://franz.com/ns/allegrograph/3.0/geospatial/cartesian/2.0/20.0/2.0/20.0/1.0>"
    end

  end

  describe "spherical_type" do

    it "should provide a spherical type" do
      result = @geo.spherical_type 1.0, :degree, 2.0, 2.0, 20.0, 20.0
      result.should == "<http://franz.com/ns/allegrograph/3.0/geospatial/spherical/degrees/2.0/20.0/2.0/20.0/1.0>"
    end

  end

  describe "create_polygon" do

    before :each do
      @polygon = [ [ 2.0, 2.0 ], [ 10.0, 2.0 ], [ 10.0, 10.0 ], [ 2.0, 10.0 ] ]
    end

    it "should create a polygon" do
      result = @geo.create_polygon "test_polygon", @type, @polygon
      result.should be_true
    end

  end

  describe "inside_box" do

    it "should find objects inside a box" do
      result = @geo.inside_box @type, "\"at\"", 8.0, 8.0, 11.0, 11.0
      result.should include([ "\"test_subject\"", "\"at\"", "\"+10.000000000931323+10.000000000931323\"^^<http://franz.com/ns/allegrograph/3.0/geospatial/cartesian/2.0/20.0/2.0/20.0/1.0>"])
    end

  end

  describe "inside_circle" do

    it "should find objects inside a circle" do
      result = @geo.inside_circle @type, "\"at\"", 9.0, 9.0, 2.0
      result.should include([ "\"test_subject\"", "\"at\"", "\"+10.000000000931323+10.000000000931323\"^^<http://franz.com/ns/allegrograph/3.0/geospatial/cartesian/2.0/20.0/2.0/20.0/1.0>"])
    end

  end

  describe "inside_haversine" do

    it "should find objects inside a haversine" do
      result = @geo.inside_haversine @type, "\"at\"", 9.0, 9.0, 200.0, :km
      result.should include([ "\"test_subject\"", "\"at\"", "\"+100000+0100000\"^^<http://franz.com/ns/allegrograph/3.0/geospatial/spherical/degrees/2.0/20.0/2.0/20.0/1.0>"])
    end

  end

end
