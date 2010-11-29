
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

    def repositories
      repositories = @server.request_json :get, self.path + "/repositories", :expected_status_code => 200
      repositories.map { |repository| Repository.new self, repository["id"] }
    end

  end

end
