require File.expand_path(File.join(File.dirname(__FILE__), "..", "..", "..", "spec_helper"))
require File.expand_path(File.join(File.dirname(__FILE__), "..", "..", "..", "..", "lib", "allegro_graph", "proxy", "statements"))

describe AllegroGraph::Proxy::Statements do

  before :each do
    @server = AllegroGraph::Server.new :username => "test", :password => "test"
    @catalog = AllegroGraph::Catalog.new @server, "test_catalog"
    @repository = AllegroGraph::Repository.new @catalog, "test_repository"
    @statements = AllegroGraph::Proxy::Statements.new @repository
    @type = @repository.geometric.cartesian_type :strip_width  => 1.0,
                                                 :x_min        => 2.0,
                                                 :y_min        => 2.0,
                                                 :x_max        => 20.0,
                                                 :y_max        => 20.0
  end

  describe "path" do

    it "should return the correct path" do
      @statements.path.should == @repository.path
    end
    
  end

  describe "create" do

    it "should create a statement" do
      result = @statements.create "\"test_subject\"", "\"test_predicate\"", "\"test_object\"", "\"test_context\""
      result.should be_true
    end

  end

  describe "delete" do

    it "should delete all statements" do
      result = @statements.delete :subject => "test_subject"
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

  describe "find_inside_box" do

    it "should find objects inside a box" do
      result = @statements.find_inside_box :type      => @type,
                                           :predicate => "\"at\"",
                                           :x_min     => 8.0,
                                           :y_min     => 8.0,
                                           :x_max     => 11.0,
                                           :y_max     => 11.0
      result.should include([ "\"test_subject\"", "\"at\"", "\"+10.000000000931323+10.000000000931323\"^^<http://franz.com/ns/allegrograph/3.0/geospatial/cartesian/2.0/20.0/2.0/20.0/1.0>" ])
    end

  end

  describe "find_inside_circle" do

    it "should find objects inside a circle" do
      result = @statements.find_inside_circle :type       => @type,
                                              :predicate  => "\"at\"",
                                              :x          => 9.0,
                                              :y          => 9.0,
                                              :radius     => 2.0
      result.should include([ "\"test_subject\"", "\"at\"", "\"+10.000000000931323+10.000000000931323\"^^<http://franz.com/ns/allegrograph/3.0/geospatial/cartesian/2.0/20.0/2.0/20.0/1.0>" ])
    end

  end

  describe "find_inside_haversine" do

    it "should find objects inside a haversine" do
      result = @statements.find_inside_haversine :type      => @type,
                                                 :predicate => "\"at\"",
                                                 :latitude  => 9.0,
                                                 :longitude => 9.0,
                                                 :radius    => 200.0,
                                                 :unit      => :km
      result.should include([ "\"test_subject\"", "\"at\"", "\"+100000+0100000\"^^<http://franz.com/ns/allegrograph/3.0/geospatial/spherical/degrees/2.0/20.0/2.0/20.0/1.0>"])
    end

  end

  describe "find_inside_polygon" do

    it "should find objects inside a polygon" do
      result = @statements.find_inside_polygon :type          => @type,
                                               :predicate     => "\"at\"",
                                               :polygon_name  => "test_polygon"
      result.should include([ "\"test_subject\"", "\"at\"", "\"+10.000000000931323+10.000000000931323\"^^<http://franz.com/ns/allegrograph/3.0/geospatial/cartesian/2.0/20.0/2.0/20.0/1.0>"])
    end

  end

end
