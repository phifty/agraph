require 'uri'
require 'cgi'
require 'net/http'
require 'base64'
require 'json'

module AllegroGraph

  # Common transport layer for http transfers.
  class Transport

    attr_reader :http_method
    attr_reader :url
    attr_reader :options
    attr_reader :headers
    attr_reader :parameters
    attr_reader :body
    attr_reader :response

    def initialize(http_method, url, options = { })
      @http_method  = http_method
      @uri          = URI.parse url
      @headers      = options[:headers]     || { }
      @parameters   = options[:parameters]  || { }
      @body         = options[:body]
    end

    def perform
      initialize_request_class
      initialize_request_path
      initialize_request
      initialize_request_body
      perform_request
    end

    private

    def initialize_request_class
      request_class_name = @http_method.capitalize
      raise NotImplementedError, "the request method #{http_method} is not implemented" unless Net::HTTP.const_defined?(request_class_name)
      @request_class = Net::HTTP.const_get request_class_name
    end

    def initialize_request_path
      serialize_parameters
      @request_path = @uri.path + @serialized_parameters
    end

    def quote_parameters
      @quoted_parameters = { }
      @parameters.each{ |key, value| @quoted_parameters[ key.to_s ] = CGI.escape(value) }
    end

    def serialize_parameters
      quote_parameters
      @serialized_parameters = if @parameters.nil? || @parameters.empty?
        ""
      else
        "?" + @quoted_parameters.collect{ |key, value| "#{key}=#{value}" }.reverse.join("&")
      end
    end
    
    def initialize_request
      @request = @request_class.new @request_path, @headers
    end
    
    def initialize_request_body
      return unless [ :post, :put ].include?(@http_method.to_sym)
      if @body
        @request.body = @body
      else
        quote_parameters
        @request.set_form_data @quoted_parameters 
      end
    end

    def perform_request
      @response = Net::HTTP.start(@uri.host, @uri.port) do |connection|
        connection.request @request
      end
    end

    def self.request(http_method, url, options = { })
      transport = new http_method, url, options
      transport.perform
      transport.response
    end

  end

  class ExtendedTransport < Transport

    # The UnexpectedStatusCodeError is raised if the :expected_status_code option is given to
    # the :request method and the responded status code is different from the expected one.
    class UnexpectedStatusCodeError < StandardError

      attr_reader :status_code
      attr_reader :message

      def initialize(status_code, message)
        @status_code, @message = status_code, message
      end

      def to_s
        "#{super} received status code #{self.status_code}" + (@message ? " [#{@message}]" : "")
      end

    end

    attr_reader :expected_status_code
    attr_reader :auth_type
    attr_reader :username
    attr_reader :password
    
    def initialize(http_method, url, options = { })
      super http_method, url, options
      @expected_status_code = options[:expected_status_code]
      @auth_type            = options[:auth_type]
      @username             = options[:username]
      @password             = options[:password]
    end

    def perform
      initialize_headers
      super
      check_status_code
      parse_response
    end

    private

    def initialize_headers
      if @auth_type == :basic
        @headers["Authorization"] = "Basic " + Base64.encode64("#{@username}:#{@password}")
      elsif !@auth_type.nil?
        raise NotImplementedError, "the given auth_type [#{@auth_type}] is not implemented"
      end
      @headers["Accept"] = "application/json"
    end

    def initialize_request_body
      super
      if @body
        @request.body = @body.to_json
        @request["Content-Type"] = "application/json"
      end
    end

    def check_status_code
      return unless @expected_status_code
      response_code = @response.code
      response_body = @response.body
      raise UnexpectedStatusCodeError.new(response_code.to_i, response_body) if @expected_status_code.to_s != response_code
    end

    def parse_response
      return nil if @response.body.nil?
      @response = JSON.parse @response.body
    rescue JSON::ParserError
      @response = @response.body.to_s
    end

  end

end
