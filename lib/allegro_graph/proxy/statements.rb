
module AllegroGraph

  module Proxy

    class Statements

      attr_reader :resource

      def initialize(resource)
        @resource = resource
      end

      def path
        "#{@resource.path}/statements"
      end

      def create(subject, predicate, object, context = nil)
        statement = [ subject, predicate, object ]
        statement << context if context
        @resource.request :post, self.path, :body => [ statement ], :expected_status_code => 204
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

        @resource.request :get, self.path, :parameters => parameters, :expected_status_code => 200
      end

      def delete
        @resource.request :delete, self.path, :expected_status_code => 200
      end

    end

  end

end