
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

    def self.create(repository)
      response = repository.request_http :post, repository.path + "/session", :expected_status_code => 200
      url = response.sub(/^"/, "").sub(/"$/, "")
      server = repository.server
      new :url => url, :username => server.username, :password => server.password
    end

    private

    def credentials
      { :auth_type => :basic, :username => @username, :password => @password }
    end

  end

end
