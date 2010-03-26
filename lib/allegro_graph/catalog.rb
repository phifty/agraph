
module AllegroGraph

  class Catalog

    attr_reader :server
    attr_reader :name

    def initialize(server, name, options = { })
      @server = server
      @name = name
      @root = options[:root] || false
    end

    def ==(other)
      other.is_a?(self.class) && self.server == other.server && self.root? == other.root? && self.name == other.name
    end

    def url
      self.root? ? @server.url : "#{@server.url}/catalogs/#{@name}"
    end

    def root?
      !!@root
    end

    def repositories
      [ ]
    end

  end

end