
module AllegroGraph

  # The Federation class wrap the corresponding resource on the AllegroGraph server. A federation is a collection
  # of many repositories that acts like a single one. Only read access is allowed.
  class Federation < Resource

    attr_reader   :server
    attr_accessor :name
    attr_accessor :repository_names
    attr_accessor :repository_urls

    def initialize(server, name, options = { })
      super
      @server, @name = server, name

      @repository_names = options[:repository_names]
      @repository_urls  = options[:repository_urls]
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