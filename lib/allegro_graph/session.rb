require File.join(File.dirname(__FILE__), "transport")
require File.join(File.dirname(__FILE__), "proxy", "statements")
require File.join(File.dirname(__FILE__), "proxy", "query")
require File.join(File.dirname(__FILE__), "proxy", "geo")
require File.join(File.dirname(__FILE__), "proxy", "mapping")

module AllegroGraph

  class Session

    attr_reader :url
    attr_reader :username
    attr_reader :password

    attr_reader :statements
    attr_reader :query
    attr_reader :geo
    attr_reader :mapping

    def initialize(options = { })
      @url      = options[:url]
      @username = options[:username]
      @password = options[:password]

      @statements = Proxy::Statements.new self
      @query      = Proxy::Query.new self
      @geo        = Proxy::Geo.new self
      @mapping    = Proxy::Mapping.new self
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
      new :url => url, :username => repository.server.username, :password => repository.server.password
    end

    private

    def credentials
      { :auth_type => :basic, :username => @username, :password => @password }
    end
    
  end

end
