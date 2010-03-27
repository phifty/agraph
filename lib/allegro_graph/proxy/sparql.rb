
module AllegroGraph

  module Proxy

    class SparQL

      attr_reader :server
      attr_reader :repository

      def initialize(repository)
        @repository = repository
        @server = @repository.server
      end

      def path
        @repository.path
      end

      def perform(query)
        parameters = { :query => query, :queryLn => "sparql" }
        @server.request :get, self.path, :parameters => parameters, :expected_status_code => 200
      end

    end

  end

end
