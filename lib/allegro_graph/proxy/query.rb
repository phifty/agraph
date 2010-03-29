
module AllegroGraph

  module Proxy

    class Query

      LANGUAGES = [ :sparql, :prolog ].freeze unless defined?(LANGUAGES)

      attr_reader :server
      attr_reader :resource
      attr_reader :language

      def initialize(resource)
        @resource = resource
        @language = :sparql
      end

      def path
        @resource.path
      end

      def language=(value)
        raise NotImplementedError, "query langauge [#{value}] is not implemented" unless LANGUAGES.include?(value.to_sym)
        @language = value.to_sym
      end

      def perform(query)
        parameters = { :query => query, :queryLn => @language.to_s }
        @resource.request :get, self.path, :parameters => parameters, :expected_status_code => 200
      end

    end

  end

end
