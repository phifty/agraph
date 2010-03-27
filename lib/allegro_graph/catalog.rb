require File.join(File.dirname(__FILE__), "repository")

module AllegroGraph

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
      repositories = @server.request :get, self.path + "/repositories", :expected_status_code => 200
      repositories.map { |repository| Repository.new self, repository["id"] }
    end

  end

end