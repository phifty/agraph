require File.join(File.dirname(__FILE__), "transport")

module AllegroGraph

  # The Server class provides methods to retrieve informations and statistics
  # of a AllegroGraph server.
  class Server

    attr_reader :host
    attr_reader :port

    def initialize(options = { })
      @host = options[:host] || "localhost"
      @port = options[:port] || "10035"
    end

    def ==(other)
      other.is_a?(self.class) && @host == other.host && @port == other.port
    end

    def version
      self.class.version self.url
    end

    def url
      "http://#{@host}:#{@port}"
    end

    def self.version(base_url)
      {
        :version  => Transport.request(:get, base_url + "/version",          :expected_status_code => 200),
        :date     => Transport.request(:get, base_url + "/version/date",     :expected_status_code => 200),
        :revision => Transport.request(:get, base_url + "/version/revision", :expected_status_code => 200)
      }      
    end

  end

end
