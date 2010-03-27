require File.join(File.dirname(__FILE__), "transport")
require File.join(File.dirname(__FILE__), "catalog")

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

    def request(http_method, path, options = { })
      type = options[:type] || :json
      case type
        when :text
          request_text http_method, path, options
        when :json
          request_json http_method, path, options
        else
          raise NotImplementedError, "the request type '#{type}' is not implemented"
      end
    end

    def version
      {
        :version  => self.request(:get, "/version",          :type => :text, :expected_status_code => 200),
        :date     => self.request(:get, "/version/date",     :type => :text, :expected_status_code => 200),
        :revision => self.request(:get, "/version/revision", :type => :text, :expected_status_code => 200)
      }
    end

    def catalogs
      result = [ @root_catalog ]
      catalogs = self.request :get, "/catalogs", :expected_status_code => 200
      catalogs.each do |catalog|
        id = catalog["id"]
        result << Catalog.new(self, id.sub(/^\//, "")) unless id == "/"
      end
      result
    end

    def url
      "http://#{@host}:#{@port}"
    end

    private

    def request_text(http_method, path, options)
      AuthorizedTransport.request http_method, self.url + path, credentials.merge(options)
    end

    def request_json(http_method, path, options)
      JSONTransport.request http_method, self.url + path, credentials.merge(options)
    end

    def credentials
      { :auth_type => :basic, :username => self.username, :password => self.password }
    end

  end

end
