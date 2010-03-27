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
    rescue AllegroGraph::Transport::UnexpectedStatusCodeError => error
      return false if error.status_code == 400
      raise error
    end

    def create_if_missing!
      create! unless exists?
    end

    def delete!
      @server.request :delete, self.path, :expected_status_code => 200
      true
    rescue AllegroGraph::Transport::UnexpectedStatusCodeError => error
      return false if error.status_code == 400
      raise error
    end

    def delete_if_exists!
      delete! if exists?
    end

  end

end