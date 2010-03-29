require File.join(File.dirname(__FILE__), "transport")
require File.join(File.dirname(__FILE__), "proxy", "statements")
require File.join(File.dirname(__FILE__), "proxy", "query")
require File.join(File.dirname(__FILE__), "proxy", "geo")
require File.join(File.dirname(__FILE__), "proxy", "mapping")

module AllegroGraph

  class Federation

    attr_reader   :server
    attr_accessor :name
    attr_accessor :repository_names
    attr_accessor :repository_urls

    attr_reader :statements
    attr_reader :query
    attr_reader :geo
    attr_reader :mapping

    def initialize(server, name, options = { })
      @server, @name = server, name

      @repository_names = options[:repository_names]
      @repository_urls  = options[:repository_urls]

      @statements = Proxy::Statements.new self
      @query      = Proxy::Query.new self
      @geo        = Proxy::Geo.new self
      @mapping    = Proxy::Mapping.new self
    end

    def ==(other)
      other.is_a?(self.class) && @server == other.server && @name == other.name
    end

    def path
      "/federated/#{@name}"
    end

    def request(http_method, path, options = { })
      @server.request http_method, path, options
    end

    def exists?
      @server.federations.include? self
    end

    def create!
      parameters = { }
      parameters.merge! :repo => @repository_names if @repository_names
      parameters.merge! :url  => @repository_urls  if @repository_urls
      @server.request :put, self.path, :parameters => parameters, :expected_status_code => 204
      true
    end

    def create_if_missing!
      create! unless exists?
    end

    def delete!
      @server.request :delete, self.path, :expected_status_code => 204
      true
    end

    def delete_if_exists!
      delete! if exists?
    end

  end

end