require File.join(File.dirname(__FILE__), "server")

module AllegroGraph

  class Repository

    attr_reader   :server
    attr_reader   :catalog
    attr_accessor :name

    def initialize(server_or_catalog, name, options = { })
      @catalog = server_or_catalog.is_a?(AllegroGraph::Server) ? server_or_catalog.root_catalog : server_or_catalog
      @server = @catalog.server
      @name = name
    end

    def ==(other)
      other.is_a?(self.class) && self.catalog == other.catalog && self.name == other.name
    end

    def path
      "#{@catalog.path}/repositories/#{@name}"
    end

    def exists?
      @catalog.repositories.include? self
    end

    def create!
      @server.request :put, self.path, :expected_status_code => 204
      true
    rescue ExtendedTransport::UnexpectedStatusCodeError => error
      return false if error.status_code == 400
      raise error
    end

    def create_if_missing!
      create! unless exists?
    end

    def delete!
      @server.request :delete, self.path, :expected_status_code => 200
      true
    rescue ExtendedTransport::UnexpectedStatusCodeError => error
      return false if error.status_code == 400
      raise error
    end

    def delete_if_exists!
      delete! if exists?
    end

    def size
      response = @server.request :get, self.path + "/size", :type => :text, :expected_status_code => 200
      response.to_i
    end

    def create_statement(subject, predicate, object, context = nil)
      statement = [ subject, predicate, object ]
      statement << context if context
      @server.request :post, self.path + "/statements", :body => [ statement ], :expected_status_code => 204
      true
    end

    def find_statements(options = { })
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

      @server.request :get, self.path + "/statements", :parameters => parameters, :expected_status_code => 200
    end

    def delete_statements(options = { })
      @server.request :delete, self.path + "/statements", :expected_status_code => 200
    end

  end

end