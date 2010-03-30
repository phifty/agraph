require File.expand_path(File.join(File.dirname(__FILE__), "..", "..", "..", "spec_helper"))
require File.expand_path(File.join(File.dirname(__FILE__), "..", "..", "..", "..", "lib", "allegro_graph", "utility", "parameter_mapper"))

describe AllegroGraph::Utility::ParameterMapper do

  before :each do
    @parameters = {
      :strip_width    => 10,
      :latitude_min   => 2.0,
      :longitude_min  => 2.0,
      :latitude_max   => 20.0,
      :longitude_max  => 20.0,
      :x_min          => 2,
      :y_min          => 2,
      :x_max          => 20,
      :y_max          => 20,
      :name           => "test"
    }
  end

  describe "map" do

    def do_map(method_name = :spherical_type)
      AllegroGraph::Utility::ParameterMapper.map @parameters, method_name
    end

    it "should return the mapped parameters" do
      do_map.should == {
        :stripWidth => "10",
        :unit       => "degree",
        :latmin     => "2.0",
        :longmin    => "2.0",
        :latmax     => "20.0",
        :longmax    => "20.0"
      }
    end

    it "should map only the right parameters" do
      do_map(:cartesian_type).should == {
        :stripWidth => "10",
        :xmin       => "2",
        :ymin       => "2",
        :xmax       => "20",
        :ymax       => "20"
      }
    end

    it "should modify the parameter values" do
      do_map(:create_polygon).should == {
        :resource => "\"test\""
      }
    end

  end

end
