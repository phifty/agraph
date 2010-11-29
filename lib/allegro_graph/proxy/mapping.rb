
module AllegroGraph

  module Proxy

    # The Mapping class acts as proxy to the data type mapping functions of the AllegroGraph server.
    class Mapping

      attr_reader :resource

      def initialize(resource)
        @resource = resource
      end

      def path
        "#{@resource.path}/mapping"
      end

      def create(type, encoding)
        parameters = { :type => type, :encoding => encoding }
        @resource.request_http :put, self.path + "/type", :parameters => parameters, :expected_status_code => 204
        true
      end

      def delete(type)
        parameters = { :type => type }
        @resource.request_http :delete, self.path + "/type", :parameters => parameters, :expected_status_code => 204
        true
      end

    end

  end

end
