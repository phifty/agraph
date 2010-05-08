
module AllegroGraph

  module Proxy

    # The Statement class acts as proxy to functions that add, remove or find statements
    # in the AllegroGraph data store.
    class Statements

      attr_reader :resource

      def initialize(resource)
        @resource = resource
      end

      def path
        @resource.path
      end

      def create(subject, predicate, object, context = nil)
        statement = [ subject, predicate, object ]
        statement << context if context
        @resource.request :post, self.path + "/statements", :body => [ statement ], :expected_status_code => 204
        true
      end

      def delete(options = { })
        parameters = { }

        { :subject => :subj, :predicate => :pred, :object => :obj, :context => :context }.each do |option_key, parameter_key|
          value = options[option_key]
          parameters.merge! parameter_key => value if value
        end

        @resource.request :delete, self.path + "/statements", :parameters => parameters, :expected_status_code => 200
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

        @resource.request :get, self.path + "/statements", :parameters => parameters, :expected_status_code => 200
      end

      def find_inside_box(parameters = { })
        parameters = Utility::ParameterMapper.map parameters, :find_inside_box
        @resource.request :get, self.path + "/geo/box", :parameters => parameters, :expected_status_code => 200
      end

      def find_inside_circle(parameters = { })
        parameters = Utility::ParameterMapper.map parameters, :find_inside_circle
        @resource.request :get, self.path + "/geo/circle", :parameters => parameters, :expected_status_code => 200
      end

      def find_inside_haversine(parameters = { })
        parameters = Utility::ParameterMapper.map parameters, :find_inside_haversine
        @resource.request :get, self.path + "/geo/haversine", :parameters => parameters, :expected_status_code => 200
      end

      def find_inside_polygon(parameters = { })
        parameters = Utility::ParameterMapper.map parameters, :find_inside_polygon
        @resource.request :get, self.path + "/geo/polygon", :parameters => parameters, :expected_status_code => 200
      end

    end

  end

end