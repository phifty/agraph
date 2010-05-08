
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

    def request(http_method, path, options = { })
      ExtendedTransport.request http_method, self.url + path, credentials.merge(options)
    end

    def commit
      self.request :post, "/commit", :expected_status_code => 204
      true
    end

    def rollback
      self.request :post, "/rollback", :expected_status_code => 204
      true
    end

    def self.create(repository)
      url = repository.request :post, repository.path + "/session", :expected_status_code => 200
      url.sub! /^"/, ""
      url.sub! /"$/, ""
      server = repository.server
      new :url => url, :username => server.username, :password => server.password
    end

    private

    def credentials
      { :auth_type => :basic, :username => @username, :password => @password }
    end
    
  end

end
