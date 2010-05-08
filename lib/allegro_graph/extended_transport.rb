require 'json'

module AllegroGraph
  
  # Extended transport layer for http transfers. Basic authorization and JSON transfers are supported.
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
      @headers["Accept"] = "application/json"
    end

    def initialize_request
      super
      if @auth_type == :basic
        @request.basic_auth @username, @password
      elsif !@auth_type.nil?
        raise NotImplementedError, "the given auth_type [#{@auth_type}] is not implemented"
      end
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
      body = @response.body
      @response = body.nil? ? nil : JSON.parse(body)
    rescue JSON::ParserError
      @response = body.to_s
    end

  end

end
