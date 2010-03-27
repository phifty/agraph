
module AllegroGraph

  module Proxy

    class Statements

      attr_reader :server
      attr_reader :repository

      def initialize(repository)
        @repository = repository
        @server = @repository.server
      end

      def path
        "#{@repository.path}/statements"
      end

      def create(subject, predicate, object, context = nil)
        statement = [ subject, predicate, object ]
        statement << context if context
        @server.request :post, self.path, :body => [ statement ], :expected_status_code => 204
        true
      end

      def find(options = { })
        parameters = { }

        { :subject => :subj, :predicate => :pred, :object => :obj, :context => :context }.each do |option_key, parameter_key|
          value = options[option_key]
          parameters.merge! value.is_a?(Array) ?
                              { :"#{parameter_key}" => value[0], :"#{parameter_key}End" => value[1] } :
                              { parameter_key => value } if value
        end

        [ :offset, :limit, :infer ].each do |key|
          parameters.merge! key => options[key] if options.has_key?(key)
        end

        parameters = nil if parameters.empty?

        @server.request :get, self.path, :parameters => parameters, :expected_status_code => 200
      end

      def delete
        @server.request :delete, self.path, :expected_status_code => 200
      end

    end

  end

end