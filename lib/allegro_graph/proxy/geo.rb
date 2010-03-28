
module AllegroGraph

  module Proxy

    class Geo

      attr_reader :server
      attr_reader :repository

      def initialize(repository)
        @repository = repository
        @server = @repository.server
      end

      def path
        "#{@repository.path}/geo"
      end

      def cartesian_type(strip_width, x_min, x_max, y_min, y_max)
        parameters = {
          :stripWidth => strip_width.to_s,
          :xmin       => x_min.to_s,
          :xmax       => x_max.to_s,
          :ymin       => y_min.to_s,
          :ymax       => y_max.to_s
        }
        @server.request :post, self.path + "/types/cartesian", :parameters => parameters, :expected_status_code => 200
      end

      def spherical_type(strip_width, unit, latitude_min, latitude_max, longitude_min, longitude_max)
        parameters = {
          :stripWidth => strip_width.to_s,
          :unit       => unit.to_s,
          :latmin     => latitude_min.to_s,
          :latmax     => latitude_max.to_s,
          :longmin    => longitude_min.to_s,
          :longmax    => longitude_max.to_s
        }
        @server.request :post, self.path + "/types/spherical", :parameters => parameters, :expected_status_code => 200
      end

    end

  end

end
