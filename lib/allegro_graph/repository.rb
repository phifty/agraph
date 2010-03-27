require File.join(File.dirname(__FILE__), "server")
require File.join(File.dirname(__FILE__), "proxy", "statements")

module AllegroGraph

  class Repository

    attr_reader   :server
    attr_reader   :catalog
    attr_accessor :name
    attr_reader   :statements

    def initialize(server_or_catalog, name, options = { })
      @catalog    = server_or_catalog.is_a?(AllegroGraph::Server) ? server_or_catalog.root_catalog : server_or_catalog
      @server     = @catalog.server
      @name       = name
      @statements = Proxy::Statements.new self
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

  end

end