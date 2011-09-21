
module AllegroGraph

  # The Server class provides methods to retrieve informations about a AllegroGraph server.
  class Server

    attr_reader :host
    attr_reader :port
    attr_reader :username
    attr_reader :password
    attr_reader :root_catalog

    def initialize(options = { })
      @host     = options[:host] || "localhost"
      @port     = options[:port] || "10035"
      @username = options[:username]
      @password = options[:password]

      @root_catalog = Catalog.new self, "root", :root => true
    end

    def ==(other)
      other.is_a?(self.class) && @host == other.host && @port == other.port
    end    
    
    def url
      "http://#{@host}:#{@port}"
    end
    
    def path
      ""
    end
    
    def server
      self
    end

    def request_http(http_method, path, options = { })
      ::Transport::HTTP.request http_method, (self.url + path), credentials.merge(options)
    end

    def request_json(http_method, path, options = { })
      ::Transport::JSON.request http_method, self.url + path, credentials.merge(options)
    end

    def version
      {
        :version  => self.request_http(:get, "/version",          :expected_status_code => 200),
        :date     => self.request_http(:get, "/version/date",     :expected_status_code => 200),
        :revision => self.request_http(:get, "/version/revision", :expected_status_code => 200)
      }
    end

    def catalogs
      result = [ @root_catalog ]
      catalogs = self.request_json :get, "/catalogs", :expected_status_code => 200
      catalogs.each do |catalog|
        id = catalog["id"]
        result << Catalog.new(self, id.sub(/^\//, "")) unless id == "/"
      end
      result
    end

    private

    def credentials
      { :auth_type => :basic, :username => @username, :password => @password }
    end

  end

end
