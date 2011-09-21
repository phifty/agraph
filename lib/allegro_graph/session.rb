
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

    def self.create(repository_or_server, options = nil)
      response = repository_or_server.request_http :post, repository_or_server.path + "/session", { :expected_status_code => 200, :parameters => options }
      url = response.sub(/^"/, "").sub(/"$/, "")
      server = repository_or_server.server
      new :url => url, :username => server.username, :password => server.password
    end

    private

    def credentials
      { :auth_type => :basic, :username => @username, :password => @password }
    end

  end

end
