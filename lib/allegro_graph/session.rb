
module AllegroGraph

  # The Session class wrap the corresponding resource on the AllegroGraph server.
  class Session < Resource

    attr_reader :url
    attr_reader :username
    attr_reader :password

    def initialize(options = { })
      super
      @url      = options[:url]
      @username = options[:username]
      @password = options[:password]
    end

    def path
      ""
    end

    def request_http(http_method, path, options = { })
      ::Transport::HTTP.request http_method, self.url + path, credentials.merge(options)
    end

    def request_json(http_method, path, options = { })
      ::Transport::JSON.request http_method, self.url + path, credentials.merge(options)
    end

    def commit
      self.request_http :post, "/commit", :expected_status_code => 204
      true
    end

    def rollback
      self.request_http :post, "/rollback", :expected_status_code => 204
      true
    end

    def size
      response = self.request_http :get, "/size", :type => :text, :expected_status_code => 200
      response.to_i
    end

    def self.create(repository_or_server, options = { })
      path = repository_or_server.path
      raise ArgumentError, "The :store parameter is missing!" if path.empty? && !options.has_key?(:store)

      response = repository_or_server.request_http :post,
                                                   path + "/session",
                                                   { :expected_status_code => 200, :parameters => build_parameters(options) }
      url = response.sub(/^"/, "").sub(/"$/, "")
      server = repository_or_server.server
      new :url => url, :username => server.username, :password => server.password
    end

    private

    def credentials
      { :auth_type => :basic, :username => @username, :password => @password }
    end

    def self.build_parameters(options)
      parameters = { }

      store = options[:store]
      parameters[:store] = store.is_a?(Array) ? "<#{store.join('>+<')}>" : "<#{store}>" if store

      # See http://www.franz.com/agraph/support/documentation/current/http-protocol.html#sessions
      [ :autoCommit, :lifetime, :loadInitFile, :script ].each do |parameters_name|
        parameters[parameters_name] = options[parameters_name] if options.has_key?(parameters_name)
      end

      parameters
    end

  end

end
