require File.expand_path(File.join(File.dirname(__FILE__), "..", "..", "..", "spec_helper"))
require File.expand_path(File.join(File.dirname(__FILE__), "..", "..", "..", "..", "lib", "allegro_graph", "proxy", "geometric"))

describe AllegroGraph::Proxy::Geometric do

  before :each do
    fake_transport!
    @server = AllegroGraph::Server.new :username => ENV['AG_USER'], :password => ENV['AG_PASS']
    @catalog = AllegroGraph::Catalog.new @server, "test_catalog"
    @repository = AllegroGraph::Repository.new @catalog, "test_repository"
    @geometric = AllegroGraph::Proxy::Geometric.new @repository
    @type = @geometric.cartesian_type :strip_width  => 1.0,
                                      :x_min        => 2.0,
                                      :y_min        => 2.0,
                                      :x_max        => 20.0,
                                      :y_max        => 20.0
  end

  describe "path" do

    it "should return the correct path" do
      @geometric.path.should == "#{@repository.path}/geo"
    end

  end

  describe "cartesian_type" do

    it "should provide a cartesian type" do
      result = @geometric.cartesian_type :strip_width => 1.0,
                                         :x_min       => 2.0,
                                         :y_min       => 2.0,
                                         :x_max       => 20.0,
                                         :y_max       => 20.0
      result.should == "<http://franz.com/ns/allegrograph/3.0/geospatial/cartesian/2.0/20.0/2.0/20.0/1.0>"
    end

  end

  describe "spherical_type" do

    it "should provide a spherical type" do
      result = @geometric.spherical_type :strip_width   => 1.0,
                                         :latitude_min  => 2.0,
                                         :longitude_min => 2.0,
                                         :latitude_max  => 20.0,
                                         :longitude_max => 20.0
      result.should == "<http://franz.com/ns/allegrograph/3.0/geospatial/spherical/degrees/2.0/20.0/2.0/20.0/1.0>"
    end

  end

  describe "create_cartesian_polygon" do

    before :each do
      @polygon = [ [ 2.0, 2.0 ], [ 10.0, 2.0 ], [ 10.0, 10.0 ], [ 2.0, 10.0 ] ]
    end

    it "should create a polygon" do
      result = @geometric.create_cartesian_polygon @polygon, :name => "test_polygon", :type => @type
      result.should be_true
    end

  end

  describe "create_spherical_polygon" do

    before :each do
      @polygon = [ [ 2.0, 2.0 ], [ 10.0, 2.0 ], [ 10.0, 10.0 ], [ 2.0, 10.0 ] ]
    end

    it "should create a polygon" do
      result = @geometric.create_spherical_polygon @polygon, :name => "test_polygon", :type => @type
      result.should be_true
    end

  end

end
