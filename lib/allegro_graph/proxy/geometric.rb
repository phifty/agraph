require File.expand_path(File.join(File.dirname(__FILE__), "..", "utility", "parameter_mapper"))

module AllegroGraph

  module Proxy

    # The Geometric class acts as proxy to the geo-functions of the AllegroGraph server.
    class Geometric

      attr_reader :resource

      def initialize(resource)
        @resource = resource
      end

      def path
        "#{@resource.path}/geo"
      end

      def cartesian_type(parameters = { })
        parameters = Utility::ParameterMapper.map parameters, :cartesian_type
        type = @resource.request_http :post, self.path + "/types/cartesian", :parameters => parameters, :expected_status_code => 200
        type.sub! /^.*</, "<"
        type.sub! />.*$/, ">"
        type
      end

      def spherical_type(parameters = { })
        parameters = Utility::ParameterMapper.map parameters, :spherical_type
        type = @resource.request_http :post, self.path + "/types/spherical", :parameters => parameters, :expected_status_code => 200
        type.sub! /^.*</, "<"
        type.sub! />.*$/, ">"
        type
      end

      def create_polygon(points, parameters = { })
        type = parameters.delete :type
        parameters = Utility::ParameterMapper.map parameters, :create_polygon

        raise ArgumentError, "at least three points has to defined" unless points.is_a?(Array) && points.size >= 3
        parameters[:point] = points.map{ |point| "\"%+g%+g\"^^%s" % [ point[0], point[1], type ] }

        @resource.request_json :put, self.path + "/polygon", :parameters => parameters, :expected_status_code => 204
        true
      end

    end

  end

end
