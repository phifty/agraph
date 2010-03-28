
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

      def cartesian_type(strip_width, x_min, y_min, x_max, y_max)
        parameters = {
          :stripWidth => strip_width.to_s,
          :xmin       => x_min.to_s,
          :ymin       => y_min.to_s,
          :xmax       => x_max.to_s,
          :ymax       => y_max.to_s
        }
        type = @server.request :post, self.path + "/types/cartesian", :parameters => parameters, :expected_status_code => 200
        type.sub! /^.*</, "<"
        type.sub! />.*$/, ">"
        type
      end

      def spherical_type(strip_width, unit, latitude_min, longitude_min, latitude_max, longitude_max)
        parameters = {
          :stripWidth => strip_width.to_s,
          :unit       => unit.to_s,
          :latmin     => latitude_min.to_s,
          :longmin    => longitude_min.to_s,
          :latmax     => latitude_max.to_s,
          :longmax    => longitude_max.to_s
        }
        type = @server.request :post, self.path + "/types/spherical", :parameters => parameters, :expected_status_code => 200
        type.sub! /^.*</, "<"
        type.sub! />.*$/, ">"
        type
      end

      def create_polygon(name, type, points)
        raise ArgumentError, "at least three points has to defined" unless points.is_a?(Array) && points.size >= 3
        parameters = {
          :resource => "\"#{name}\"",
          :point    => points.map{ |point| "\"%+g%+g\"^^%s" % [ point[0], point[1], type ] }
        }
        @server.request :put, self.path + "/polygon", :parameters => parameters, :expected_status_code => 204
        true
      end

      def inside_box(type, predicate, x_min, y_min, x_max, y_max)
        parameters = {
          :type       => type,
          :predicate  => predicate,
          :xmin       => x_min.to_s,
          :ymin       => y_min.to_s,
          :xmax       => x_max.to_s,
          :ymax       => y_max.to_s
        }
        @server.request :get, self.path + "/box", :parameters => parameters, :expected_status_code => 200
      end

      def inside_circle(type, predicate, x, y, radius)
        parameters = {
          :type       => type,
          :predicate  => predicate,
          :x          => x.to_s,
          :y          => y.to_s,
          :radius     => radius.to_s
        }
        @server.request :get, self.path + "/circle", :parameters => parameters, :expected_status_code => 200
      end

    end

  end

end
