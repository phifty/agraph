
module AllegroGraph

  # The Catalog class wrap the corresponding resource on the AllegroGraph server. A catalog can hold
  # many repositories.
  class Catalog

    attr_reader   :server
    attr_accessor :name

    def initialize(server, name, options = { })
      @server = server
      @name = name
      @root = options[:root] || false
    end

    def ==(other)
      other.is_a?(self.class) && self.server == other.server && self.root? == other.root? && self.name == other.name
    end

    def path
      self.root? ? "" : "/catalogs/#{@name}"
    end

    def root?
      !!@root
    end

    def exists?
      @server.catalogs.include? self
    end

    def create!
      @server.request_http :put, self.path, :expected_status_code => 204
      true
    rescue ::Transport::UnexpectedStatusCodeError => error
      return false if error.status_code == 400
      raise error
    end

    def create_if_missing!
      create! unless exists?
    end

    def delete!
      @server.request_http :delete, self.path, :expected_status_code => 204
      true
    rescue ::Transport::UnexpectedStatusCodeError => error
      return false if error.status_code == 400
      raise error
    end

    def delete_if_exists!
      delete! if exists?
    end

    def repositories
      repositories = @server.request_json :get, self.path + "/repositories", :expected_status_code => 200
      repositories.map { |repository| Repository.new self, repository["id"] }
    end

  end

end
