require File.expand_path(File.join(File.dirname(__FILE__), "..", "spec_helper"))
require File.expand_path(File.join(File.dirname(__FILE__), "..", "..", "lib", "allegro_graph"))

describe "geo-spatial data" do

  use_real_transport!

  before :each do
    @server = AllegroGraph::Server.new :username => "test", :password => "test"
    @repository = AllegroGraph::Repository.new @server, "test_repository"
    @repository.create_if_missing!
    @geometric  = @repository.geometric
    @statements = @repository.statements
  end

  describe "types" do

    it "should provide a cartesian type" do
      result = @geometric.cartesian_type :strip_width => 1.0,
                                         :x_min       => 2.0,
                                         :y_min       => 2.0,
                                         :x_max       => 20.0,
                                         :y_max       => 20.0
      result.should == "<http://franz.com/ns/allegrograph/3.0/geospatial/cartesian/2.0/20.0/2.0/20.0/1.0>"
    end

    it "should provide a spherical type" do
      result = @geometric.spherical_type :strip_width   => 1.0,
                                         :latitude_min  => 2.0,
                                         :longitude_min => 2.0,
                                         :latitude_max  => 20.0,
                                         :longitude_max => 20.0
      result.should == "<http://franz.com/ns/allegrograph/3.0/geospatial/spherical/degrees/2.0/20.0/2.0/20.0/1.0>"
    end

  end

  describe "creating polygon" do

    before :each do
      @type = @geometric.cartesian_type :strip_width => 1.0,
                                        :x_min       => 2.0,
                                        :y_min       => 2.0,
                                        :x_max       => 20.0,
                                        :y_max       => 20.0
      @polygon = [ [ 2.0, 2.0 ], [ 11.0, 2.0 ], [ 11.0, 11.0 ], [ 2.0, 11.0 ] ]
    end

    it "should return true" do
      result = @geometric.create_polygon @polygon, :name => "test_polygon", :type => @type
      result.should be_true
    end

  end

  context "in a cartesian system" do

    before :each do
      @type = @geometric.cartesian_type :strip_width => 1.0,
                                        :x_min       => 2.0,
                                        :y_min       => 2.0,
                                        :x_max       => 20.0,
                                        :y_max       => 20.0
      @statements.create "\"test_subject\"", "\"at\"", "\"+10+10\"^^#{@type}"
      @statement_one = [ "\"test_subject\"", "\"at\"", "\"+10.000000000931323+10.000000000931323\"^^#{@type}"]

      @statements.create "\"another_subject\"", "\"at\"", "\"+15+15\"^^#{@type}"
      @statement_two = [ "\"another_subject\"", "\"at\"", "\"+15.000000000465661+15.000000000465661\"^^#{@type}"]
    end

    it "should find objects inside a box" do
      result = @statements.find_inside_box :type       => @type,
                                           :predicate  => "\"at\"",
                                           :x_min      => 8.0,
                                           :y_min      => 8.0,
                                           :x_max      => 11.0,
                                           :y_max      => 11.0
      result.should include(@statement_one)
      result.should_not include(@statement_two)
    end

    it "should find objects inside a circle" do
      result = @statements.find_inside_circle :type      => @type,
                                              :predicate => "\"at\"",
                                              :x         => 9.0,
                                              :y         => 9.0,
                                              :radius    => 2.0
      result.should include(@statement_one)
      result.should_not include(@statement_two)
    end

    it "should find objects inside that polygon" do
      @geometric.create_polygon [ [ 5.0, 5.0 ], [ 5.0, 12.0 ], [ 12.0, 12.0 ], [ 12.0, 5.0 ] ],
                                :name => "test_polygon",
                                :type => @type

      result = @statements.find_inside_polygon :type         => @type,
                                               :predicate    => "\"at\"",
                                               :polygon_name => "test_polygon"
      result.should include(@statement_one)
      result.should_not include(@statement_two)
    end

  end

  context "in a spherical system" do

    before :each do
      @type = @geometric.spherical_type :strip_width   => 1.0,
                                        :latitude_min  => 2.0,
                                        :longitude_min => 2.0,
                                        :latitude_max  => 20.0,
                                        :longitude_max => 20.0
      @statements.create "\"test_subject\"", "\"at\"", "\"+10.00+010.00\"^^#{@type}"
    end

    it "should find objects inside a haversine" do
      result = @statements.find_inside_haversine :type       => @type,
                                                 :predicate  => "\"at\"",
                                                 :latitude   => 9.0,
                                                 :longitude  => 9.0,
                                                 :radius     => 200.0,
                                                 :unit       => :km
      result.should include([ "\"test_subject\"", "\"at\"", "\"+100000+0100000\"^^<http://franz.com/ns/allegrograph/3.0/geospatial/spherical/degrees/2.0/20.0/2.0/20.0/1.0>"])
    end

  end

end
