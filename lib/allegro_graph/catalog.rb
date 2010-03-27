
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

    def create!
      raise StandardError, "cannot create root catalog!" if self.root?
      @server.request :put, self.path, :expected_status_code => 201
    rescue AllegroGraph::Transport::UnexpectedStatusCodeError => error
      return false if error.status_code == 400
      raise error
    end

    def repositories
      [ ]
    end

  end

end